//
//  NoteController.m
//  DesktopNote
//
//  Created by Jingkai He on 24/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "NoteController.h"

@implementation NoteController

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self.tableView setDelegate:self];
    
    self.selectedNote = [self.notes firstObject];
    [self.titleTextField setStringValue: self.selectedNote.title];
    [self.contentField setString:self.selectedNote.content];
    
    [self.contentField setDelegate:self];
    [self.contentField setRichText:YES];
    [[self.contentField textStorage] setFont:[NSFont fontWithName:@"Lucida Grande" size:14.0]];

    WebPreferences *webPrefs = [WebPreferences
                                standardPreferences];
    
    [webPrefs setUserStyleSheetEnabled:YES];

    [webPrefs setUserStyleSheetLocation:[[NSBundle mainBundle]
                                         URLForResource:@"markdown"
                                         withExtension:@"css"]];
    
    //Set your webview's preferences
    [self.webView setPreferences:webPrefs];
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    if ([notification object] == self.contentField) {
        
        Document *doc = [[Document alloc]
                         initWithContent:self.contentField.string];
        
        Parser *parser = [[Parser alloc] initWithDocument:doc];
        [parser parse];
        
        [[self.webView mainFrame]
         loadHTMLString:[parser render] baseURL:nil];
    }
}

-(NSMutableArray *)notes
{
    if (! _notes) {
        _notes = [NSMutableArray array];
        
        Note *note = [[Note alloc] initWithTitle:@"Example" content:@"Hello World!"];

        [_notes addObject:note];
    }
    
    return _notes;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.notes count];
}

- (id) tableView: (NSTableView *) tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Note *note = [self.notes objectAtIndex:row];
    NSString *title = note.title;
    
    return title;
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
    
    NSInteger row = [self.tableView selectedRow];
    
    if (row == -1) {
        return;
    }
    
    Note *note = [self.notes objectAtIndex:row];
    
    Document *doc = [[Document alloc] initWithContent:note.content];
    Parser *parser = [[Parser alloc] initWithDocument:doc];
    [parser parse];
    
    [[self.webView mainFrame]
     loadHTMLString:[parser render] baseURL:nil];
    
    [self.titleTextField setStringValue: note.title];
    [self.contentField setString:note.content];

    self.selectedNote = note;
}

-(IBAction)save:(id)sender
{
    NSLog(@"Saving note...");
    
    NSString *title = self.titleTextField.stringValue;
    NSString *content = self.contentField.string;
    
    if (self.selectedNote) {
        self.selectedNote.title = title;
        self.selectedNote.content = content;
    }

    [self.tableView reloadData];
}

-(IBAction)new:(id)sender
{
    NSLog(@"New note...");
    Note *note = [[Note alloc] init];
    [self.notes addObject:note];
    
    self.titleTextField.stringValue = @"";
    self.contentField.string = @"";
    
    self.selectedNote = note;
}

@end
