//
//  NSMutableArray+EventStack.m
//  DesktopNote
//
//  Created by Jingkai He on 30/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "NSMutableArray+EventStack.h"

@implementation NSMutableArray (EventStack)

-(void)push:(id)obj
{
    [self addObject:obj];
}

-(id)pop
{
    id lastObject = [self lastObject];
    [self removeAllObjects];
    return lastObject;
}

-(BOOL)isEmpty
{
    return ([self count] == 0);
}
@end
