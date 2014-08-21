//
//  TextFragment.m
//  MicroDown
//
//  Created by Jingkai He on 03/07/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "TextFragment.h"

static NSString *emailPattern = @"<([A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4})>";
static NSString *emailFormat = @"<a href=\"mailto:%@\" target=\"_top\">%@</a>";
static NSRegularExpression *emailRegex;

static NSString *autolinkPattern = @"<((http|https|ftp)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+)>";
static NSString *autolinkFormat = @"<a href=\"%@\">%@</a>";
static NSRegularExpression *autolinkRegex;

static NSString *inlineLinkPattern = @"\\[(.+?)\\]\\s*\\((.+?)\\)";
static NSString *inlineLinkFormat = @"<a href=\"%@\">%@</a>";
static NSRegularExpression *inlineLinkRegex;

static NSString *referenceLinkPattern = @"\\[(.+?)\\]\\s*\\[(.+?)\\]";
static NSString *referenceLinkFormat = @"<a href=\"%@\">%@</a>";
static NSRegularExpression *referenceLinkRegex;

static NSString *youtubeVideoPattern = @"\\!v\\[(.+?)\\]\\s*\\[(([0-9]+?)x([0-9]+?)){0,1}\\]";
static NSString *youtubeVideoFormat = @"<iframe width='%@' height='%@' src='%@' frameborder='0' allowfullscreen></iframe>";
static NSRegularExpression *youtubeVideoRegex;

static NSString *inlineImagePattern = @"\\!\\[(.+?)\\]\\s*\\((.+?)\\s*(\\=([0-9]+?)x([0-9]+?)){0,1}\\)";
static NSString *inlineImageFormat = @"<img src=\"%@\" width=\"%@\" height=\"%@\" alt=\"%@\" />";
static NSRegularExpression *inlineImageRegex;

static NSString *referenceImagePattern = @"\\!\\[(.+?)\\]\\s*\\[(.+?)\\s*(\\=([0-9]+?)x([0-9]+?)){0,1}\\]";
static NSString *referenceImageFormat = @"<img src=\"%@\" width=\"%@\" height=\"%@\" alt=\"%@\" />";
static NSRegularExpression *referenceImageRegex;

static NSString *boldPattern = @"\\*([^\n\\ ][^\n]+?[^\n\\ ])\\*";
static NSString *boldFormat = @"<strong>%@</strong>";
static NSRegularExpression *boldRegex;

static NSString *italicPattern = @"\\*\\*([^\n\\ ][^\n]+?[^\n\\ ])\\*\\*";
static NSString *italicFormat = @"<em>%@</em>";
static NSRegularExpression *italicRegex;

static NSString *delPattern = @"~~([^\n\\ ][^\n]+?[^\n\\ ])~~";
static NSString *delFormat = @"<del>%@</del>";
static NSRegularExpression *delRegex;

@implementation TextFragment

/*
 * Lazy pre-load all the patterns to static memory.
 * Once load, won't need load anymore.
 */
+(void) initialize
{
    if (!emailRegex) {
        emailRegex = [NSRegularExpression
         regularExpressionWithPattern:emailPattern
         options:0
         error:nil];
    }

    if (!autolinkRegex) {
        autolinkRegex = [NSRegularExpression
                      regularExpressionWithPattern:autolinkPattern
                      options:0
                      error:nil];
    }
    
    if (!inlineLinkRegex) {
        inlineLinkRegex = [NSRegularExpression
                           regularExpressionWithPattern:inlineLinkPattern
                           options:0
                           error:nil];
    }
    
    if (!referenceLinkRegex) {
        referenceLinkRegex = [NSRegularExpression
                              regularExpressionWithPattern:referenceLinkPattern
                              options:0
                              error:nil];
    }
    
    if (!youtubeVideoRegex) {
        youtubeVideoRegex = [NSRegularExpression
                             regularExpressionWithPattern:youtubeVideoPattern
                             options:0
                             error:nil];
    }
    
    if (!inlineImageRegex) {
        inlineImageRegex = [NSRegularExpression
                            regularExpressionWithPattern:inlineImagePattern
                            options:0
                            error:nil];
    }
    
    if (!referenceImageRegex) {
        referenceImageRegex = [NSRegularExpression
                               regularExpressionWithPattern:referenceImagePattern
                               options:0
                               error:nil];
    }
    
    if (!boldRegex) {
        boldRegex = [NSRegularExpression
                     regularExpressionWithPattern:boldPattern
                     options:0
                     error:nil];
    }
    
    if (!italicRegex) {
        italicRegex = [NSRegularExpression
                       regularExpressionWithPattern:italicPattern
                       options:0
                       error:nil];
    }
    
    if (!delRegex) {
        delRegex = [NSRegularExpression
                    regularExpressionWithPattern:delPattern
                    options:0
                    error:nil];
    }
}

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        self.parsed = NO;
    }
    
    return self;
}

- (void) parse
{
    [self.document.elements addObject:self];
}

- (NSString *) toHTML
{
    if (self.parsed == YES) {
        return self.content;
    }
    
    self.parsed = YES;
    [self plainConvert];
    
    return self.content;
}

- (void) plainConvert
{
    [self convertYoutubeVideo];
    
    [self convertInlineImage];
    [self convertReferenceImage];
    
    [self convertInlineLink];
    [self convertReferenceLink];
    
    self.content = [self replaceContextWithRegex:emailRegex withFormat:emailFormat];
    self.content = [self replaceContextWithRegex:autolinkRegex withFormat:autolinkFormat];
    
    self.content = [self replaceContextWithRegex:delRegex withFormat:delFormat];
    
    self.content = [self replaceContextWithRegex:italicRegex withFormat:italicFormat];
    self.content = [self replaceContextWithRegex:boldRegex withFormat:boldFormat];
    
}

- (void) convertInlineImage
{
    NSError *error = error;
    
    NSRegularExpression * regex = [NSRegularExpression
                                   regularExpressionWithPattern:inlineImagePattern
                                   options:0
                                   error:&error];
    
    self.content = [regex
                    stringByReplacingMatchesInString:self.content
                    options:0
                    range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:inlineImageFormat, @"$1", @"$4",@"$5", @"$2"]];
}

- (void) convertReferenceImage
{
    self.content = [referenceImageRegex
                    stringByReplacingMatchesInString:self.content
                    options:0
                    range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:referenceImageFormat, @"$1", @"$4",@"$5", @"$2"]];
}

- (void) convertInlineLink
{
    self.content = [inlineLinkRegex
                    stringByReplacingMatchesInString:self.content
                    options:0 range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:inlineLinkFormat, @"$2", @"$1"]];
}

- (void) convertReferenceLink
{
    self.content = [referenceLinkRegex
                    stringByReplacingMatchesInString:self.content
                    options:0
                    range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:referenceLinkFormat, @"$2", @"$1"]];
}

- (void) convertYoutubeVideo
{
    self.content = [youtubeVideoRegex
                    stringByReplacingMatchesInString:self.content
                    options:0
                    range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:youtubeVideoFormat, @"$3", @"$4", @"$1"]];
}
@end
