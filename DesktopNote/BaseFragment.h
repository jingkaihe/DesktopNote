//
//  Parser.h
//  MicroDown
//
//  Created by Jingkai He on 30/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Document.h"

/*
 * Base class of the code fragment.
 */
@interface BaseFragment : NSObject

@property (copy) NSString *content;
@property (weak) Document *document; // Father node

- (instancetype) initWithContent: (NSString *)content;
- (instancetype) initWithContent: (NSString *)content andDocument: (Document *)document;

- (void) parse;
- (NSString *) toHTML;

- (NSString *) replaceContextWithRegex: (NSRegularExpression *)regex withFormat: (NSString *)format;

@end
