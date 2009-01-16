//
//  ARBase+Finders.m
//  ActiveRecord
//
//  Created by Fjölnir Ásgeirsson on 14.8.2007.
//  Copyright 2007 ninja kitten. All rights reserved.
//

#import "ARBase+Finders.h"


@implementation ARBase (Finders)
+ (NSArray *)find:(ARFindSpecification)idOrSpecification 
{
  return [self find:idOrSpecification
         connection:[self defaultConnection]];
}
+ (NSArray *)find:(ARFindSpecification)idOrSpecification select:(NSString *)selectSQL
{
  return [self find:idOrSpecification
             select:selectSQL
         connection:[self defaultConnection]];
}
+ (NSArray *)find:(ARFindSpecification)idOrSpecification connection:(id<ARConnection>)aConnection
{
  return [self find:idOrSpecification
             select:@"id"
             filter:nil 
							 join:nil
              order:nil
              limit:0
         connection:aConnection];
}
+ (NSArray *)find:(ARFindSpecification)idOrSpecification select:(NSString *)selectSQL connection:(id<ARConnection>)aConnection
{
  return [self find:idOrSpecification
             select:selectSQL
             filter:nil 
							 join:nil
              order:nil
              limit:0
         connection:aConnection];
}
+ (NSArray *)find:(ARFindSpecification)idOrSpecification 
           filter:(NSString *)whereSQL 
						 join:(NSString *)joinSQL
            order:(NSString *)orderSQL
            limit:(NSUInteger)limit
{
  return [self find:idOrSpecification
             select:@"id"
             filter:whereSQL 
							 join:joinSQL
              order:orderSQL
              limit:limit
         connection:[self defaultConnection]];
}
+ (NSArray *)find:(ARFindSpecification)idOrSpecification 
           select:(NSString *)selectSQL 
           filter:(NSString *)whereSQL 
						 join:(NSString *)joinSQL
            order:(NSString *)orderSQL
            limit:(NSUInteger)limit
{
  return [self find:idOrSpecification
             select:selectSQL 
             filter:whereSQL 
							 join:joinSQL
              order:orderSQL
              limit:limit
         connection:[self defaultConnection]];
}
+ (NSArray *)find:(ARFindSpecification)idOrSpecification
           filter:(NSString *)whereSQL 
						 join:(NSString *)joinSQL
            order:(NSString *)orderSQL 
            limit:(NSUInteger)limit
       connection:(id<ARConnection>)aConnection
{
  return [self find:idOrSpecification
             select:@"id"
             filter:whereSQL 
							 join:joinSQL
              order:orderSQL
              limit:limit
         connection:aConnection];
}
+ (NSArray *)find:(ARFindSpecification)idOrSpecification
           select:(NSString *)selectSQL 
           filter:(NSString *)whereSQL 
						 join:(NSString *)joinSQL
            order:(NSString *)orderSQL 
            limit:(NSUInteger)limit
       connection:(id<ARConnection>)aConnection
{
	NSArray *ids = [self findIds:idOrSpecification
												select:selectSQL 
												filter:whereSQL 
													join:joinSQL
												 order:orderSQL
												 limit:limit
										connection:aConnection];
  
  NSMutableArray *models = [NSMutableArray array];
  for(NSDictionary *match in ids)
  {
    NSUInteger id = [[match objectForKey:@"id"] unsignedIntValue];
    if ( [selectSQL isEqualToString:@"id"] == YES )
      [models addObject:[[[self alloc] initWithConnection:aConnection id:id] autorelease]];
    else
      [models addObject:[[[self alloc] initWithConnection:aConnection id:id readCache:match] autorelease]];
  }
  return models;
}

+ (NSArray *)findIds:(ARFindSpecification)idOrSpecification
							filter:(NSString *)whereSQL 
								join:(NSString *)joinSQL
							 order:(NSString *)orderSQL 
							 limit:(NSUInteger)limit
					connection:(id<ARConnection>)aConnection
{
	return [self findIds:idOrSpecification
												select:@"id" 
												filter:whereSQL 
													join:joinSQL
												 order:orderSQL
												 limit:limit
										connection:aConnection];
}
+ (NSArray *)findIds:(ARFindSpecification)idOrSpecification
							select:(NSString *)selectSQL 
							filter:(NSString *)whereSQL 
								join:(NSString *)joinSQL
							 order:(NSString *)orderSQL 
							 limit:(NSUInteger)limit
					connection:(id<ARConnection>)aConnection
{
  NSMutableString *query;
  if ( [selectSQL isEqualToString:@"id"] )
    query = [NSMutableString stringWithFormat:@"SELECT id FROM %@", [self tableName]];
  else
    query = [NSMutableString stringWithFormat:@"SELECT id, %@ FROM %@", selectSQL, [self tableName]];
	if(joinSQL)
		[query appendFormat:@" %@", joinSQL];
	
  switch(idOrSpecification)
  {
    case ARFindFirst:
			if(limit == 0)
				[query appendString:@" LIMIT 1"];
      break;
    case ARFindAll:
      break;
    default:
      [query appendString:@" WHERE id=:id"];
      break;
  }
  if(idOrSpecification == ARFindFirst || idOrSpecification == ARFindAll)
  {
    if(whereSQL != nil)
      [query appendFormat:@" WHERE %@", whereSQL];
    if(orderSQL != nil)
      [query appendFormat:@" ORDER BY %@", orderSQL];
  }
  else
  {
    if(whereSQL != nil)
      [query appendFormat:@" AND %@", whereSQL];
    if(orderSQL != nil)
      [query appendFormat:@" ORDER %@", orderSQL];
  }
  if(limit > 0)
    [query appendFormat:@" LIMIT %d", limit];
  
  NSArray *matches = [aConnection executeSQL:query
                               substitutions:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInteger:idOrSpecification], @"id", nil]];
  return matches;
}


#pragma mark -
#pragma mark convenience accessors
+ (NSArray *)findAll
{
  return [self find:ARFindAll];
}

+ (id)first
{
	return [self find:ARFindFirst];
}
+ (id)last
{
	NSArray *ret = [self find:ARFindFirst filter:nil join:nil order:@"id DESC" limit:1];
	if(ret && [ret count] > 0)
		return [ret objectAtIndex:0];
	return nil;
}
@end
