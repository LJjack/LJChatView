//
//  LDFmdbProvider.m
//  platform
//
//  Created by cjh on 16/7/2.
//  Copyright © 2016年 bujiong. All rights reserved.
//
#import <YYModel/YYModel.h>
#import "NSObject+LDPropertyIterator.h"

#import "LDFmdbProvider.h"

@interface LDFmdbProvider()

@property(nonatomic, assign) BOOL deepPolicy;

@property(nonatomic, strong) FMDatabaseQueue *dbQueue;

@property(nonatomic, strong) NSDictionary *objcSqliteTypeMapper;

@end

@implementation LDFmdbProvider

+ (instancetype)sharedInstance {
    static LDFmdbProvider *instance;
    static dispatch_once_t token;
    
    if (!instance) {
        dispatch_once(&token, ^{
            instance = [LDFmdbProvider new];
        });
    }
    
    return instance;
}

- (void)enableDeepPolicy {
    _deepPolicy = YES;
}

- (void)disableDeepPolicy {
    _deepPolicy = NO;
}

- (NSString *) getDbPath {
    NSString *dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"dbs"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dir]) {
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return dir;
}

/**
 * 旧表的数据导入新表，并删除旧表
 */
- (void)upgradeTable:(NSString *)tableName {
    @try {
        [_dbQueue inDatabase:^(FMDatabase *db) {
            
            // 如果表不存在，返回
            FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select count(1) as c from sqlite_master where type='table' and tbl_name = '%@'", tableName]];
            [rs next];
            if ([rs intForColumn:@"c"] != 1) {
                [rs close];
                return;
            }
            
            [rs close];
            
            // 将表名更改成新表名，然后根据模型创建最新的表，最后将旧数据导入最新的表并删除原表。
            NSString *fromTbl = [NSString stringWithFormat:@"%@_temp", tableName];
            NSString *toTbl = tableName;
            
            // 更改表名
            [db executeUpdate:@"ALTER TABLE %@ RENAME TO %@", tableName, fromTbl];
            
            // 创建新表
            Class modelClass = NSClassFromString(tableName);
            [self createTableIfNotExist:modelClass];
            
            // 获取旧表的字段，并生成insert into select 语句
            rs = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)", fromTbl]];
            NSMutableArray *fields = [NSMutableArray arrayWithCapacity:10];
            while ([rs next]) {
                [fields addObject:[rs stringForColumn:@"name"]];
            }
            [rs close];
            
            NSMutableString *sql = [[NSMutableString alloc] init];
            [sql appendFormat:@"insert into %@", toTbl];
            [sql appendString:@"("];
            
            for (NSString *field in fields) {
                [sql appendFormat:@"%@,", field];
            }
            
            [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
            [sql appendString:@")"];
            [sql appendString:@"select "];
            
            for (NSString *field in fields) {
                [sql appendFormat:@"%@,", field];
            }
            [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
            [sql appendFormat:@" from %@", fromTbl];
            
            [db executeUpdate:sql];
            [db executeUpdate:[NSString stringWithFormat:@"drop table %@", fromTbl]];
        }];
    } @catch (NSException *exception) {
        BJLog(@"升级表[%@]时发生错误,%@", tableName, exception);
        [exception raise];
    }
}

- (void)checkDbUpgradeTask:(NSString *)dbName {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dbUpgrade" ofType:@"plist"];
    NSDictionary *upgradeConfs = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSArray<NSString *> *upgradeTables = upgradeConfs[dbName];
    if (upgradeTables) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"upgrade_%@", dbName];
        NSNumber *isUpgraded = [userDefaults valueForKey:key];
        // 升级，并做记录
        if (!isUpgraded) {
            
            for (NSString *tableName in upgradeTables) {
                [self upgradeTable:tableName];
            }
            
            [userDefaults setInteger:1 forKey:key];
            [userDefaults synchronize];
        }
    }
}

- (void)initWithDbName:(NSString *)dbName {
    NSString *dbPath = [[self getDbPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", dbName]];
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    _objcSqliteTypeMapper = @{@"NSString": @"VARCHAR(256)",
                              @"NSDate": @"TIMESTAMP",
                              @"NSNumber": @"INTEGER",
                              @"int": @"INTEGER",
                              @"long": @"INTEGER",
                              @"short": @"INTEGER",
                              @"NSInteger": @"INTEGER",
                              @"NSUInteger": @"INTEGER",
                              @"BOOL": @"BOOLEAN",
                              @"float": @"FLOAT",
                              @"double": @"DOUBLE"
                              };
    
    // 检查数据库升级情况
    [self checkDbUpgradeTask:dbName];
}

- (NSDictionary *)getRelatedModelClasses:(Class)modelClass {
    if ([(id<LDFmdbProvider>)modelClass respondsToSelector:@selector(dbRelationContainerPropertyGenericClass)]) {
        return [(id<LDFmdbProvider>)modelClass dbRelationContainerPropertyGenericClass];
    }
    return nil;
}
#pragma mark - 插入或更新

- (NSInteger)save:(NSArray *)models {
    return [self saveImpl:models];
}

#pragma mark - 查询

- (id)queryByKey:(Class)modelClass primaryKeyValue:(NSNumber *)keyValue {
    NSArray * array = [self queryByKey:modelClass sqlDict:@{[self getPrimaryKey:modelClass]:keyValue}];
    if (array.count) {
        return array.firstObject;
    }
    return nil;
}

- (NSArray *)queryByKey:(Class)modelClass sqlDict:(NSDictionary *)sqlDict {
    
    return [self queryMore:modelClass sqlDict:sqlDict sortKeys:nil];
}

- (NSArray *)queryMore:(Class)modelClass sqlDict:(NSDictionary *)sqlDict sortKeys:(NSArray *)sortKeys {
   
    NSMutableString *mSQL = [NSMutableString stringWithFormat:@"select * from %@ where ",[self getTableName:modelClass]];
    if (sqlDict && ![sqlDict isEqualToDictionary:@{}]) {
        [mSQL appendString:[self toStringWithDict:sqlDict]];
    } else {
        mSQL =[mSQL stringByReplacingOccurrencesOfString:@"where" withString:@""].mutableCopy;
    }
    
    NSString *sortKey;
    if (!sortKeys || !sortKeys.count) {
        sortKey = [self getPrimaryKey:modelClass];
    } else {
        sortKey = [sortKeys componentsJoinedByString:@","];
    }
    [mSQL appendString:[NSString stringWithFormat:@" ORDER BY %@ ", sortKey]];
    
    
    __block NSArray *result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [self queryImpl:db modelClass:modelClass sql:mSQL withArgumentsInArray:nil];
    }];
    return result;
}
- (id)querySingledModel:(Class)modelClass sql:(NSString *)sql withArgumentsInArray:(NSArray *)args {
    __block NSArray *result ;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [self queryImpl:db modelClass:modelClass sql:sql withArgumentsInArray:args];
    }];
    
    if (result.count) {
        return result.firstObject;
    } else {
        return nil;
    }
}

- (NSArray *)queryMore:(Class)modelClass sql:(NSString *)sql {
    __block NSArray *result ;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [self queryImpl:db modelClass:modelClass sql:sql withArgumentsInArray:nil];
    }];
    
    return result;
}

#pragma mark - 删除

- (BOOL)deleteByKey:(Class)modelClass primaryKeyValue:(NSNumber *)keyValue {
    
    NSString *primaryKey = [self getPrimaryKey:modelClass];
    return [self deleteMoreModel:modelClass sqlDict:@{primaryKey:keyValue}];
}



- (BOOL)deleteMoreModel:(Class)modelClass sqlDict:(NSDictionary *)sqlDict {
    NSAssert(sqlDict, @"删除数据库内容的条件字典不能为空");
    NSArray *modelArray = [self queryMore:modelClass sqlDict:sqlDict sortKeys:nil];
    
    NSMutableString *mSQL = [NSMutableString stringWithFormat:@"delete from %@ where ",[self getTableName:modelClass]];
    
    [mSQL appendString:[self toStringWithDict:sqlDict]];
    
    if (_deepPolicy) {
        NSDictionary<NSString *, Class> *classes = [self getRelatedModelClasses:modelClass];
        // 获取关联的模型类
        [classes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class _Nonnull obj, BOOL * _Nonnull stop) {
            for (id model in modelArray) {
                NSString *primaryKey = [self getPrimaryKey:modelClass];
                
                id keyValue = [model valueForKey:primaryKey];
                [self deleteByModel:obj key:[self getForeignKey:obj] keyValue:keyValue];
            }
        }];
    }
   
    return [self executeUpdate:mSQL];
    
}

- (BOOL)executeUpdate:(NSString*)sql {
    
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    
    return result;
}

#pragma mark - Private Methods

#pragma mark - 查询
- (NSArray *)queryImpl:(FMDatabase *)db modelClass:(Class)modelClass
            sql:(NSString *)sql withArgumentsInArray:(NSArray *)args {
    
    NSMutableArray *result = [NSMutableArray array];
    
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:args];
    while ([rs next]) {
        
        if ([modelClass isSubclassOfClass:[NSNumber class]]) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            id v = [formatter numberFromString:[rs stringForColumnIndex:0]];
            [result addObject:v];
        } else if ([modelClass isSubclassOfClass:[NSString class]]) {
            [result addObject:[rs stringForColumnIndex:0]];
        } else {
            id model = [modelClass yy_modelWithDictionary:[rs resultDictionary]];
            if (model) {
                [result addObject:model];
                NSString *primaryKey = [self getPrimaryKey:modelClass];
                // 如果存在关联关系，则再查询关联的数据 TODO 嵌套打开ResultSet可能有问题
                NSDictionary<NSString *, id> *relatedClasses = [self getRelatedModelClasses:modelClass];
                [relatedClasses enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull redClass, BOOL * _Nonnull stop) {
                    
                    NSString *foreignKey = [self getForeignKey:redClass];
                    
                        NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where %@=%@", [self getTableName:redClass], foreignKey, [model valueForKey:primaryKey]];
                        NSArray *relatedModels = [self queryImpl:db modelClass:relatedClasses[key] sql:sql withArgumentsInArray:nil];
                        
                        // 将结果设置到对应属性中
                        [model setValue:relatedModels forKey:key];
                }];
                
            } else {
                BJLog(@"ORM执行失败，yymodel无法将记录转换成模型");
            }
        }
    }
    
    [rs close];
    
    return result;
}

#pragma mark 插入或更新
- (NSInteger)saveImpl:(NSArray *)models {
    if (!models || models.count == 0) {
        return 0;
    }
    __block NSUInteger changeCount = 0;
    for (id model in models) {
        [self createTableIfNotExist:[model class]];
        
        NSString *primaryName = [self getPrimaryKey:[model class]];
        BOOL isUpdate = [self isUpdateState:model primaryName:primaryName];
        NSString *sql = [self constructSql:[model class] isUpdate:isUpdate primaryName:primaryName];
        
        BJLog(@"generated sql is: %@.", sql);
        
        NSDictionary *dict = [self modelToDictionary:model].copy;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:sql withParameterDictionary:dict];
            
            if (!isUpdate) {
                // 将最新的主键更新到主键
                NSString *keySql = [NSString stringWithFormat:@"select last_insert_rowid() from %@", [self getTableName:[models.firstObject class]]];
                
                FMResultSet *rs = [db executeQuery:keySql];
                if ([rs next]) {
                    NSNumber *kv = @([rs longLongIntForColumnIndex:0]);
                    [model setValue:kv forKey:primaryName];
                    [rs close];
                } else {
                    BJLog(@"无法获取插入数据的主键值");
                }
            }
            
            changeCount += [db changes];
        }];
        
        // 保留关联的数据库
        if (_deepPolicy) {
            NSDictionary<NSString *, id> *relatedClasses = [self getRelatedModelClasses:[model class]];
            if (relatedClasses.count) {
                [relatedClasses enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    id values = [model valueForKey:key];
                    if ([values isKindOfClass:[NSArray class]]) {
                        if ([values count]) {
                            changeCount += [self saveImpl:values];
                        }
                    } else {
                        changeCount += [self saveImpl:@[values]];
                    }
                    
                }];
            }
        }
    }
    
    
    return changeCount;
}

#pragma mark 删除
- (BOOL)deleteByModel:(Class)modelClass
                  key:(NSString *)key
             keyValue:(NSNumber *)keyValue {
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = %@", [self getTableName:modelClass], key, keyValue];
    return [self executeUpdate:sql];
}

- (BOOL)isUpdateState:(id)model primaryName:(NSString *)primaryName {
    id value = [model valueForKey:primaryName];
    if (!value) {
        // 没有id，表示新增
        return NO;
    } else {
        // 有id，但没有在表中，也表示新增
        id resultModel = [self queryByKey:[model class] primaryKeyValue:value];
        if (resultModel) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (NSString *)constructSql:(Class)modelClass
                  isUpdate:(BOOL)isUpdate
               primaryName:(NSString *)primaryName {
    const char *tableName = class_getName(modelClass);
    //忽略属性
    NSArray<NSString *> *dbIgnoreArray = nil;
    if ([modelClass respondsToSelector:@selector(dbIgnoreProperty)]) {
        dbIgnoreArray = [(id<LDFmdbProvider>)modelClass dbIgnoreProperty];
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:
                            isUpdate ? @"update %s set " : @"insert into %s (", tableName];
    NSMutableString *insertPlaceholders = [NSMutableString string];
    
    [modelClass iterateProperty:^BOOL(NSString *name, NSString *typeName, NSInteger count) {
        
        if ([primaryName isEqualToString:name] && isUpdate) {
            return YES;
        }
        
        if ([dbIgnoreArray containsObject:name]) {
            return YES;
        }
        
        // 数据字段类型
        NSString *fieldType = _objcSqliteTypeMapper[typeName];
        if (!fieldType) {
            return YES;
        }
        
        if (isUpdate) {
            [sql appendFormat:@"%@=:%@,", name, name];
        } else {
            [sql appendFormat:@"%@,", name];
            [insertPlaceholders appendFormat:@":%@,", name];
        }
        
        return YES;
    }];
    
    // 移除最后一个,
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    
    if (isUpdate) {
        [sql appendFormat:@" where %@=:%@", primaryName, primaryName];
    } else {
        [insertPlaceholders deleteCharactersInRange:NSMakeRange(insertPlaceholders.length - 1, 1)];
        [sql appendFormat:@") values (%@)", insertPlaceholders];
    }
    
    return sql;
}

- (NSMutableDictionary*)modelToDictionary:(id)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [[model class] iterateProperty:^BOOL(NSString *name, NSString *typeName, NSInteger count) {
        
        id value = [model valueForKey:name];
        
        if (value == nil) {
            value = [NSNull null];
        }
        
        [dict setObject:value forKey:name];
        
        return YES;
    }];
    
    return dict;
}


/**
 * 如果表不存在，根据模型创建之
 */
- (void)createTableIfNotExist:(Class)modelClass {
    NSString *tableName = [self getTableName:modelClass];    
    NSMutableString *ddl = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", tableName];
    
    //------- 协议 -----
    //关联
    NSDictionary<NSString *, id> *dbRelationDict = [self getRelatedModelClasses:modelClass];
    //忽略属性
    NSArray<NSString *> *dbIgnoreArray = nil;
    if ([modelClass respondsToSelector:@selector(dbIgnoreProperty)]) {
        dbIgnoreArray = [(id<LDFmdbProvider>)modelClass dbIgnoreProperty];
    }
    //主键
    NSString *primaryKey = [self getPrimaryKey:modelClass];
    
    
    
    __weak typeof(self) weakSelf = self;
    [modelClass iterateProperty:^BOOL(NSString *name, NSString *typeName, NSInteger count) {
        
        // 无类型属性 id
        if (!typeName) {
            return YES;
        }
        // 忽略
        if (dbIgnoreArray && [dbIgnoreArray containsObject:name]) {
            return YES;
        }
        
        // 主键
        if ([name isEqualToString:primaryKey]) {
            if ([typeName isEqualToString:@"NSNumber"]) {
                [ddl appendFormat:@"[%@] INTEGER PRIMARY KEY AUTOINCREMENT,", name];
            } else {
                [NSException raise:@"不支持的主键类型，目前只支持NSNumber" format:@"主键类型:%@", typeName];
            }
        } else {
            // 字段属性
            NSString *fieldType = _objcSqliteTypeMapper[typeName];
            if (fieldType) {
                // 字段名
                [ddl appendFormat:@"[%@] %@,", name, fieldType];
            } else {
                // 如果存在关联关系，同时创建关联表
                    if (dbRelationDict) {
                        Class class = dbRelationDict[name];
                        if (class) {
                            [weakSelf createTableIfNotExist:class];
                        }
                    } else {
                    return YES;
                }
            }
        }
        
        return YES;
    }];
    
    [ddl deleteCharactersInRange:NSMakeRange(ddl.length - 1, 1)];
    [ddl appendString:@")"];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:ddl];
    }];
}



- (NSString *)toStringWithDict:(NSDictionary *)dict {
    NSMutableString *mSQL = [NSMutableString string];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key containsString:@"self."]) {
            key = [key stringByReplacingOccurrencesOfString:@"self." withString:@""];
        }
        if ([key containsString:@"_"]) {
            key = [key stringByReplacingOccurrencesOfString:@"_" withString:@""];
        }
        if ([obj isKindOfClass:[NSString class]]) {
            [mSQL appendFormat:@"%@='%@',",key,obj];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            [mSQL appendFormat:@"%@=%@,",key,obj];
        }else {
            NSAssert(NO, @"没有处理此类型%@",[obj class]);
        }
        
        
    }];
    [mSQL deleteCharactersInRange:NSMakeRange(mSQL.length - 1, 1)];
    return mSQL.copy;
}

- (NSString *)getTableName:(Class)modelClass {
    return @(class_getName(modelClass));
}

- (NSString *)getPrimaryKey:(Class)modelClass {
    NSString *primaryKey = [(id<LDFmdbProvider>)modelClass dbPrimaryKey];
    NSAssert(primaryKey, @"主键不能为空");
    return primaryKey;
}

- (NSString *)getForeignKey:(Class)modelClass {
    NSString *foreignKey = [(id<LDFmdbProvider>)modelClass dbForeignKey];
    NSAssert(foreignKey, @"外键不能为空");
    return foreignKey;
}
@end
