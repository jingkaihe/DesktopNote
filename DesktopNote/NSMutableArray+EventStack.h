//
//  NSMutableArray+EventStack.h
//  DesktopNote
//
//  Created by Jingkai He on 30/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (EventStack)

-(void)push:(id)obj;
-(id)pop;
-(BOOL)isEmpty;

@end
