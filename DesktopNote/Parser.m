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
    // Iterate each line of the document
    while (_document.startLine <= _document.endLine) {
        NSInteger currentLine = _document.startLine;
        NSString *lineOfMD = [_document.arrayOfLines objectAtIndex:currentLine];
        NSRange rangeOfLine = NSMakeRange(0, [lineOfMD length]);

        // pre-recognise the blank line pattern
        NSInteger countOfBlankLineMatch = [[Fragments blankLineRegex]
                                           numberOfMatchesInString:lineOfMD
                                           options:0
                                           range:rangeOfLine];
        
        // Pre-recognise the heading pattern
        NSInteger countOfHeadingMatch = [[Fragments headingRegex]
                                         numberOfMatchesInString:lineOfMD
                                         options:0
                                         range:rangeOfLine];
        
        if (countOfBlankLineMatch > 0) {
            // Blank line pattern
            ++ _document.startLine;

            BlankLineFragment *frag = [[BlankLineFragment alloc]
                                       initWithContent: lineOfMD
                                       andDocument:_document];

            [frag parse];
        }else if (countOfHeadingMatch > 0){
            // Heading pattern
            ++ _document.startLine;
            
            HeadingFragment *frag = [[HeadingFragment alloc]
                                     initWithContent: lineOfMD
                                     andDocument:_document];
            [frag parse];
        }else if ([LinedHeadingFragment
                   isHeadingWithLine:lineOfMD
                   andDocument:_document]) {
            // Another heading pattern
            ++ _document.startLine;
            
            LinedHeadingFragment *frag = [[LinedHeadingFragment alloc]
                                          initWithContent:lineOfMD
                                          andDocument:_document];
            [frag parse];
        }else if ([HorizontalFragment isWithLine:lineOfMD andDocument:_document]){
            // Break line pattern
            ++ _document.startLine;
            
            HorizontalFragment *frag = [[HorizontalFragment alloc]
                                        initWithContent:lineOfMD
                                        andDocument:_document];
            [frag parse];
        }else if ([ListFragment isListWithLine:lineOfMD andDocument:_document] == YES){
            // List pattern
            ++ _document.startLine;
            
            TextFragment *frag = [[TextFragment alloc]
                                  initWithContent:[ListFragment getListContentByText:lineOfMD]
                                  andDocument:_document];
            
            NSString *tag = [ListFragment getTagByText:lineOfMD];
            
            BaseFragment *lastElement = [self.document.elements lastObject];
            if ([lastElement isKindOfClass:[ListFragment class]]) {
                // insert the current node to the previous, if the previous node is also a list
                ListFragment *list = [self.document.elements lastObject];
                [list addListItem:frag];
            }else{
                // else create a new list node
                ListFragment *list = [[ListFragment alloc] initWithDocument:_document andTag:tag];
                [list parse];
                [list addListItem:frag];
            }
        }else {
            // parsing the paragraph
            ++ _document.startLine;

            TextFragment *frag = [[TextFragment alloc]
                                  initWithContent:lineOfMD
                                  andDocument:_document];

            BaseFragment *lastElement = [self.document.elements lastObject];
            
            if ([lastElement isKindOfClass:[ParagraphFragment class]]) {
                // insert the current node to the previous, if the previous node is also a pragraph
                ParagraphFragment *le = [self.document.elements lastObject];
                [le addChildren:frag];
            }else{
                // else create a new paragraph node
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
        NSInteger elementsCount = self.document.elements.count;
        NSInteger processorCount = [[NSProcessInfo processInfo] processorCount];

        NSMutableArray *arrayOfRenderedString = [NSMutableArray arrayWithCapacity:elementsCount];
        for (int i = 0; i < elementsCount; ++i) {
            [arrayOfRenderedString addObject:@""];
        }
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_t group = dispatch_group_create();
        
        NSInteger dispatchingBlock = elementsCount < processorCount ?
            elementsCount : (elementsCount / processorCount);
        NSInteger startingElementIndex = 0;
        
        while (startingElementIndex < elementsCount) {
            dispatch_group_async(group, queue, ^{

                for (NSInteger i = startingElementIndex;
                     i < elementsCount && i < startingElementIndex + dispatchingBlock;
                     ++ i) {

                    arrayOfRenderedString[i] = [self.document.elements[i] toHTML];
                }
            });
            startingElementIndex += dispatchingBlock;
        }
        
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

        _renderedString = [arrayOfRenderedString componentsJoinedByString:@"\n"];
    }
    
    return  _renderedString;
}
@end
