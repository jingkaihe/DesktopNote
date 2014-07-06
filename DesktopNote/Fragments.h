//
//  Fragments.h
//  MicroDown
//
//  Created by Jingkai He on 01/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BlankLineFragment.h"
#import "HeadingFragment.h"
#import "LinedHeadingFragment.h"
#import "HorizontalFragment.h"
#import "ParagraphFragment.h"
#import "TextFragment.h"
#import "ListFragment.h"

@interface Fragments : NSObject

+(NSRegularExpression *) blankLineRegex;
+(NSRegularExpression *) headingRegex;

@end
