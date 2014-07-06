//
//  ParagraphFragment.h
//  MicroDown
//
//  Created by Jingkai He on 05/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "TextFragment.h"

@interface ParagraphFragment : BaseFragment

@property NSMutableArray *children;

- (void) addChildren: (TextFragment *)child;
- (void) removeLastChild;

@end
