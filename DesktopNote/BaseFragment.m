//
//  Parser.m
//  MicroDown
//
//  Created by Jingkai He on 30/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "BaseFragment.h"

@implementation BaseFragment

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        self.content = @"hello world";
    }
    
    return self;
    
}

- (instancetype) initWithContent:(NSString *)content andDocument:(Document *)document
{
    self = [self init];
    
    if (self) {
        self.content = content;
        self.document = document;
    }
    
    return self;
}

- (instancetype) initWithContent: (NSString *)content
{
    self = [self init];
    
    if (self) {
        self.content = content;
    }
    
    return self;
}

- (NSString *) replaceContextWithRegex: (NSRegularExpression *)regex withFormat: (NSString *)format
{
    return [regex
            stringByReplacingMatchesInString:self.content
            options:0
            range:NSMakeRange(0, [self.content length])
            withTemplate:[NSString stringWithFormat:format, @"$1", @"$1"]];
}

-(NSString *) toHTML
{
    return @"Not implemented Error";
}

-(void) parse
{
    [NSException raise:@"Not implemented Error" format:@"parse method is not implemented"];
}

- (NSString *) description
{
    return self.content;
}
@end
