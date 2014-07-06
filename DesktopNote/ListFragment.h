//
//  ListFragment.h
//  MicroDown
//
//  Created by Jingkai He on 05/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "TextFragment.h"

@interface ListFragment : BaseFragment

@property NSMutableArray *list;
@property NSString *tag;

+(BOOL) isListWithLine: (NSString *)line andDocument: (Document *)document;

+(NSString *)getTagByText: (NSString *)text;
+(NSString *)getListContentByText: (NSString *)text;

- (instancetype) initWithDocument:(Document *)document andTag: (NSString*)tag;
- (void)addListItem: (TextFragment *) frag;

@end
