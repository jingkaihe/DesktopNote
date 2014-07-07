//
//  BlankLineFragment.m
//  MicroDown
//
//  Created by Jingkai He on 30/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "BlankLineFragment.h"

@implementation BlankLineFragment

+(NSString *)pattern
{
    static NSString *_pattern = nil;
    
    if (_pattern == nil) {
        _pattern = @"(\\A\\s*$)";
    }
    
    return _pattern;
}

-(NSString *) toHTML
{
    return @"";

}

-(void) parse
{
    [self.document.elements addObject:self];
}

@end
