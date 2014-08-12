//
//  HeadingFragment.m
//  MicroDown
//
//  Created by Jingkai He on 01/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "HeadingFragment.h"

@implementation HeadingFragment

static NSRegularExpression *regex;

+(NSString *) pattern
{
    static NSString *_pattern;
    
    if (_pattern == nil) {
        _pattern = @"\\A(#{1,6}) ([^\n]+?) *#* *(?:\n+|$)";
    }
    
    return _pattern;
}

+(void)initialize
{
    if (regex == nil) {
        regex = [NSRegularExpression
                  regularExpressionWithPattern:[self.class pattern]
                  options:0
                  error:nil];
    }
}
-(NSString *)toHTML
{
    NSString *format = @"<h%d>%@</h%d>";
    
    NSArray *arrayOfAllMatches = [regex
                                  matchesInString:self.content
                                  options:0
                                  range:NSMakeRange(0, [self.content length])];

    NSTextCheckingResult *match1 = [arrayOfAllMatches objectAtIndex:0];
    NSString *hashtag = [self.content substringWithRange:[match1 rangeAtIndex:1]];
    
    unsigned long hashtagCount = [hashtag length];
    
    NSTextCheckingResult *match2 = [arrayOfAllMatches objectAtIndex:0];
    NSString *headingContent = [self.content substringWithRange:[match2 rangeAtIndex:2]];
    NSString *renderedHeadingContent = [[[TextFragment alloc]
                                         initWithContent:headingContent]
                                        toHTML];
    
    self.content = [NSString stringWithFormat:format,
                    hashtagCount, renderedHeadingContent, hashtagCount];
    
    return self.content;
}

-(void) parse
{
    [self.document.elements addObject:self];
}
@end
