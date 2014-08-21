//
//  Fragments.m
//  MicroDown
//
//  Created by Jingkai He on 02/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "Fragments.h"

@implementation Fragments

/*
 * Preload & lazy load the blank line pattern to static memory
 */
+(NSRegularExpression *) blankLineRegex
{
    NSError *error;
    
    static NSRegularExpression *_blankLineRegex = nil;
    if (_blankLineRegex == nil) {
        _blankLineRegex = [[NSRegularExpression alloc]
                           initWithPattern:[BlankLineFragment pattern]
                           options:0
                           error:&error];
    }
    
    return _blankLineRegex;
}

/*
 * Preload & lazy load the heading pattern to static memory
 */
+(NSRegularExpression *) headingRegex
{
    NSError *error;
    
    static NSRegularExpression *_headingRegex = nil;
    if (_headingRegex == nil) {
        _headingRegex = [[NSRegularExpression alloc]
                         initWithPattern:[HeadingFragment pattern]
                         options:0
                         error:&error];
    }
    
    return _headingRegex;
}

@end
