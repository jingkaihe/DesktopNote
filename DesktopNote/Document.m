//
//  Document.m
//  MicroDown
//
//  Created by Jingkai He on 01/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "Document.h"

@implementation Document

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        self.arrayOfLines = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/*
 * Initialise by the content
 * parameters: content - NSString
 */
- (instancetype) initWithContent: (NSString *)content
{
    self = [super init];
    
    if (self) {
        // initialise the parameters of document
        self.arrayOfLines = [[NSMutableArray alloc] init];
        
        NSError *error = error;
        
        self.arrayOfLines = [NSMutableArray
                             arrayWithArray:[content componentsSeparatedByString:@"\n"]];
        
        self.inBlock = NO;
        self.startLine = 0;
        self.endLine = [self.arrayOfLines count] - 1;
        
        self.elements = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/*
 * Override the description method
 */
- (NSString *) description
{
    NSString *resultArray = [self.arrayOfLines componentsJoinedByString:@"\n"];
    NSString *result = [NSString stringWithFormat:@"%@\nStartLine: %ld\nEndLine: %ld",
                        resultArray, (long)self.startLine, (long)self.endLine];
    
    return result;
}


@end
