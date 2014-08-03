//
//  LineFragment.m
//  MicroDown
//
//  Created by Jingkai He on 05/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "HorizontalFragment.h"

static NSString *pattern = @"\\A[\\*=]{3,}\\s*";

@implementation HorizontalFragment

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        self.parsed = NO;
    }
    
    return self;
}

+ (BOOL) isWithLine:(NSString *)line andDocument:(Document *)document
{
    NSError *error;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:pattern
                                  options:0
                                  error:&error];
    
    BOOL regexMatch = [[regex
                        matchesInString:line
                        options:0
                        range:NSMakeRange(0, [line length])] count] > 0;
    
    if (!regexMatch) {
        return NO;
    }
    
    BaseFragment *element = document.elements.lastObject;
    
    return [element isKindOfClass:[BlankLineFragment class]] || !element;
}

- (void) parse
{
    [self toHTML];
    [self.document.elements addObject:self];
}

- (NSString *) toHTML
{
    if (self.parsed == YES) {
        return self.content;
    }
    
    [self.document.elements removeLastObject];
    
    self.content = @"<hr />";
    self.parsed = YES;
    
    return self.content;
    
}
@end
