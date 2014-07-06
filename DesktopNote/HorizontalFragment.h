//
//  LineFragment.h
//  MicroDown
//
//  Created by Jingkai He on 05/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "TextFragment.h"
#import "BlankLineFragment.h"

@interface HorizontalFragment : BaseFragment

@property BOOL parsed;
+ (BOOL) isWithLine: (NSString *)line andDocument: (Document *) document;

@end
