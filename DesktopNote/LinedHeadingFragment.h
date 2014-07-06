//
//  LinedHeadingFragment.h
//  MicroDown
//
//  Created by Jingkai He on 04/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "ParagraphFragment.h"

@interface LinedHeadingFragment : BaseFragment

@property BOOL parsed;

+ (BOOL) isHeadingWithLine: (NSString *)line andDocument: (Document *) document;

@end
