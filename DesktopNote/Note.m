//
//  Note.m
//  DesktopNote
//
//  Created by Jingkai He on 24/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "Note.h"

@implementation Note


- (instancetype) init
{
    self = [super init];
    
    if (self) {
        [self setTitle:@""];
        [self setContent:@""];
    }
    
    return self;
}

- (instancetype) initWithTitle: (NSString *)title content: (NSString *)content
{
    self = [super init];
    
    if (self) {
        [self setTitle:title];
        [self setContent:content];
    }
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"title: %@ \ncontent: %@", self.title, self.content];
}
@end
