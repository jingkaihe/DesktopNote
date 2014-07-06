//
//  Parser.m
//  MicroDown
//
//  Created by Jingkai He on 02/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "Parser.h"

@implementation Parser

-(instancetype)initWithDocument:(Document *)document
{
    self = [super init];
    
    if (self) {
        self.document = document;
    }
    
    return self;
}

- (void) parse
{
    while (_document.startLine <= _document.endLine) {
        NSInteger currentLine = _document.startLine;
        NSString *lineOfMD = [_document.arrayOfLines objectAtIndex:currentLine];
        NSRange rangeOfLine = NSMakeRange(0, [lineOfMD length]);

        NSInteger countOfBlankLineMatch = [[Fragments blankLineRegex]
                                           numberOfMatchesInString:lineOfMD
                                           options:0
                                           range:rangeOfLine];

        NSInteger countOfHeadingMatch = [[Fragments headingRegex]
                                         numberOfMatchesInString:lineOfMD
                                         options:0
                                         range:rangeOfLine];
        
        if (countOfBlankLineMatch > 0) {
            ++ _document.startLine;

            BlankLineFragment *frag = [[BlankLineFragment alloc]
                                       initWithContent: lineOfMD
                                       andDocument:_document];

            [frag parse];
        }else if (countOfHeadingMatch > 0){
            ++ _document.startLine;
            
            HeadingFragment *frag = [[HeadingFragment alloc]
                                     initWithContent: lineOfMD
                                     andDocument:_document];
            [frag parse];
        }else if ([LinedHeadingFragment
                   isHeadingWithLine:lineOfMD
                   andDocument:_document]) {
            ++ _document.startLine;
            
            LinedHeadingFragment *frag = [[LinedHeadingFragment alloc]
                                          initWithContent:lineOfMD
                                          andDocument:_document];
            [frag parse];
        }else if ([HorizontalFragment isWithLine:lineOfMD andDocument:_document]){
            ++ _document.startLine;
            
            HorizontalFragment *frag = [[HorizontalFragment alloc]
                                        initWithContent:lineOfMD
                                        andDocument:_document];
            [frag parse];
        }else if ([ListFragment isListWithLine:lineOfMD andDocument:_document] == YES){
            ++ _document.startLine;
            
            TextFragment *frag = [[TextFragment alloc]
                                  initWithContent:[ListFragment getListContentByText:lineOfMD]
                                  andDocument:_document];
            
            NSString *tag = [ListFragment getTagByText:lineOfMD];
            
            BaseFragment *lastElement = [self.document.elements lastObject];
            if ([lastElement isKindOfClass:[ListFragment class]]) {
                ListFragment *list = [self.document.elements lastObject];
                [list addListItem:frag];
            }else{
                ListFragment *list = [[ListFragment alloc] initWithDocument:_document andTag:tag];
                [list parse];
                [list addListItem:frag];
            }
        }else {
            ++ _document.startLine;

            TextFragment *frag = [[TextFragment alloc]
                                  initWithContent:lineOfMD
                                  andDocument:_document];

            BaseFragment *lastElement = [self.document.elements lastObject];
            
            if ([lastElement isKindOfClass:[ParagraphFragment class]]) {
                ParagraphFragment *le = [self.document.elements lastObject];
                [le addChildren:frag];
            }else{
                ParagraphFragment *paragraph = [[ParagraphFragment alloc]
                                                initWithContent:@""
                                                andDocument:_document];
                [paragraph addChildren:frag];
                [paragraph parse];
            }
        }
    }
}

-(NSString *) render
{
    if (_renderedString == nil) {
        NSMutableArray *arrayOfRenderedString = [[NSMutableArray alloc] init];
        for (BaseFragment *element in self.document.elements ) {
            [arrayOfRenderedString addObject: [element toHTML]];
        }
        
        _renderedString = [arrayOfRenderedString componentsJoinedByString:@"\n"];
    }
    
    return  _renderedString;
}
@end
