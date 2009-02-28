//
//  ARBase-KeyAndSelectorParsers.m
//  ActiveRecord
//
//  Created by Fjölnir Ásgeirsson on 8.8.2007.
//  Copyright 2007 ninja kitten. All rights reserved.
//

// These methods are described in ARBase.m
// (Basically they just parse selectors(like 'setAttribute:' or simply 'attribute')
//  or keys and return what relationships they represent)
#import "ARBase.h"
#import "ARBasePrivate.h"
#import "NSString+Inflections.h"
#import "ARRelationship.h"

@implementation ARBase (KeyAndSelectorParsers)
- (ARAttributeSelectorType)typeOfSelector:(SEL)aSelector
                            attributeName:(NSString **)outAttribute
{
    NSString *selector = NSStringFromSelector(aSelector);   
    NSScanner *scanner = [NSScanner scannerWithString:selector];
    ARAttributeSelectorType selectorType;
    NSString *type;
    if([scanner scanUpToCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet] intoString:&type])
    {
        if([type isEqualToString:@"set"])
            selectorType = ARAttributeSelectorWriter;
        else if([type isEqualToString:@"add"])
            selectorType = ARAttributeSelectorAdder;
        else if([type isEqualToString:@"remove"])
            selectorType = ARAttributeSelectorRemover;
        else
        {
            selectorType = ARAttributeSelectorReader;
            [scanner setScanLocation:0];
        }
        if(outAttribute != NULL)
        {
          // underscore attribute
          NSString *attribute = [selector substringFromIndex:[scanner scanLocation]];
					attribute = [attribute underscoredString];
          attribute = [attribute stringByReplacingOccurrencesOfString:@":" withString:@""];
          *outAttribute = attribute;
        }
    }
    else
    {
        selectorType = ARAttributeSelectorReader;
        if(outAttribute != NULL)
            *outAttribute = selector;
    }

    return selectorType;
}
- (ARRelationship *)relationshipForKey:(NSString *)key
{
	NSString *attribute = [key underscoredString];
  for(ARRelationship *relationship in self.relationships)
  {
    if([relationship respondsToKey:attribute])
      return relationship;
  }
  return nil;
}
@end
