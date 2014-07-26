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

static NSString *autolinkPattern = @"<((http|https|ftp)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+)>";
static NSString *autolinkFormat = @"<a href=\"%@\">%@</a>";

static NSString *inlineLinkPattern = @"\\[(.+?)\\]\\s*\\((.+?)\\)";
static NSString *inlineLinkFormat = @"<a href=\"%@\">%@</a>";

static NSString *referenceLinkPattern = @"\\[(.+?)\\]\\s*\\[(.+?)\\]";
static NSString *referenceLinkFormat = @"<a href=\"%@\">%@</a>";


static NSString *youtubeVideoPattern = @"\\!v\\[(.+?)\\]\\s*\\[(([0-9]+?)x([0-9]+?)){0,1}\\]";
static NSString *youtubeVideoFormat = @"<iframe width='%@' height='%@' src='%@' frameborder='0' allowfullscreen></iframe>";

static NSString *inlineImagePattern = @"\\!\\[(.+?)\\]\\s*\\((.+?)\\s*(\\=([0-9]+?)x([0-9]+?)){0,1}\\)";
static NSString *inlineImageFormat = @"<img src=\"%@\" width=\"%@\" height=\"%@\" alt=\"%@\" />";

static NSString *referenceImagePattern = @"\\!\\[(.+?)\\]\\s*\\[(.+?)\\s*(\\=([0-9]+?)x([0-9]+?)){0,1}\\]";
static NSString *referenceImageFormat = @"<img src=\"%@\" width=\"%@\" height=\"%@\" alt=\"%@\" />";

static NSString *boldPattern = @"\\*([^\n\\ ][^\n]+?[^\n\\ ])\\*";
static NSString *boldFormat = @"<strong>%@</strong>";

static NSString *italicPattern = @"\\*\\*([^\n\\ ][^\n]+?[^\n\\ ])\\*\\*";
static NSString *italicFormat = @"<em>%@</em>";

static NSString *delPattern = @"~~([^\n\\ ][^\n]+?[^\n\\ ])~~";
static NSString *delFormat = @"<del>%@</del>";

@implementation TextFragment

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
    
    self.content = [self replaceContextWithPattern:emailPattern withFormat:emailFormat];
    self.content = [self replaceContextWithPattern:autolinkPattern withFormat:autolinkFormat];

    self.content = [self replaceContextWithPattern:delPattern withFormat:delFormat];

    self.content = [self replaceContextWithPattern:italicPattern withFormat:italicFormat];
    self.content = [self replaceContextWithPattern:boldPattern withFormat:boldFormat];

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
    NSError *error = error;
    
    NSRegularExpression * regex = [NSRegularExpression
                                   regularExpressionWithPattern:referenceImagePattern
                                   options:0
                                   error:&error];
    
    self.content = [regex
                    stringByReplacingMatchesInString:self.content
                    options:0
                    range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:referenceImageFormat, @"$1", @"$4",@"$5", @"$2"]];
}

- (void) convertInlineLink
{
    NSError *error = error;
    
    NSRegularExpression * regex = [NSRegularExpression
                                   regularExpressionWithPattern:inlineLinkPattern
                                   options:0
                                   error:&error];
    
    self.content = [regex
                    stringByReplacingMatchesInString:self.content
                    options:0 range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:inlineLinkFormat, @"$2", @"$1"]];
}

- (void) convertReferenceLink
{
    NSError *error = error;
    
    NSRegularExpression * regex = [NSRegularExpression
                                   regularExpressionWithPattern:referenceLinkPattern
                                   options:0
                                   error:&error];
    
    self.content = [regex
                    stringByReplacingMatchesInString:self.content
                    options:0
                    range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:referenceLinkFormat, @"$2", @"$1"]];
}

- (void) convertYoutubeVideo
{
    NSError *error = error;
    
    NSRegularExpression * regex = [NSRegularExpression
                                   regularExpressionWithPattern:youtubeVideoPattern
                                   options:0
                                   error:&error];
    
    self.content = [regex
                    stringByReplacingMatchesInString:self.content
                    options:0
                    range:NSMakeRange(0, [self.content length])
                    withTemplate:[NSString stringWithFormat:youtubeVideoFormat, @"$3", @"$4", @"$1"]];
}
@end
