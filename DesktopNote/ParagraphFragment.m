//
//  ParagraphFragment.m
//  MicroDown
//
//  Created by Jingkai He on 05/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "ParagraphFragment.h"

@implementation ParagraphFragment

- (instancetype) init
{
    self = [super init];

    if (self) {
        self.children = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) parse
{
    [self.document.elements addObject:self];
}

- (void) addChildren: (TextFragment *)child
{
    [self.children addObject:child];
}

- (void) removeLastChild
{
    [self.children removeLastObject];
}

- (NSString *) toHTML
{
    NSMutableArray *contentOfChildren = [[NSMutableArray alloc] init];
    
    for (BaseFragment *frag in self.children) {
        [contentOfChildren addObject:[frag toHTML]];
    }
    
    self.content = [contentOfChildren componentsJoinedByString:@"<br />\n"];
    
    return [NSString stringWithFormat:@"<p>%@</p>", self.content];
}

@end
