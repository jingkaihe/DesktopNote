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
    
    // Persistence delegation
    id delegate = [[NSApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];

    self.selectedNote = [self.notes lastObject];
    
    [self.contentField setString:self.selectedNote.content];
    
    [self.contentField setDelegate:self];
    // [self.contentField setRichText:YES];
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.notes count];
}

- (id) tableView: (NSTableView *) tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Note *note = [self.notes objectAtIndex:row];
    NSString *title = note.title;
    
    return title;
}

-(NSMutableArray *)notes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *notes = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    _notes = [NSMutableArray arrayWithArray:notes];
    
    // NSLog(@" ---- %ld ----", (unsigned long)[_notes count]);
    
    if ([_notes count] == 0) {
        Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
        
        note.title = @"Hello";
        note.content = @"World";
        
        [self.managedObjectContext save:nil];
    }
    
    return _notes;
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
    
    [self.contentField setString:note.content];

    self.selectedNote = note;
}

-(IBAction)save:(id)sender
{
    NSLog(@"Saving note...");
    
    NSString *title = [self getPlainTitle:self.contentField.string];
    NSString *content = self.contentField.string;
    
    if (self.selectedNote) {
        self.selectedNote.title = title;
        self.selectedNote.content = content;
        
        [self.managedObjectContext save:nil];
        
        [self.managedObjectContext
         refreshObject:self.selectedNote mergeChanges:YES];
        
        [self.tableView reloadData];
    }

}

-(IBAction)new:(id)sender
{
    NSLog(@"New note...");
    Note *note = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Note"
                  inManagedObjectContext:self.managedObjectContext];
    
    note.title = @"";
    note.content = @"";
    [self.managedObjectContext save:nil];

    [self.managedObjectContext
     refreshObject:self.selectedNote mergeChanges:YES];
    
    self.contentField.string = @"";
    
    self.selectedNote = [self.notes lastObject];
}

-(IBAction)delete:(id)sender
{
    NSLog(@"Delete note...");
    
    if (!self.selectedNote) {
        return;
    }
    
    [self.managedObjectContext deleteObject:self.selectedNote];
    [self.managedObjectContext save:nil];
    
    [self.managedObjectContext
     refreshObject:self.selectedNote mergeChanges:YES];
    
    [self.tableView reloadData];
}

- (IBAction)export:(id)sender
{
    if (!self.selectedNote) {
        return;
    }
    
    NSRect webRect = [[[[self.webView mainFrame] frameView] documentView] frame];
    NSData *pdfData = [[[[self.webView mainFrame] frameView] documentView] dataWithPDFInsideRect:webRect];
    
    PDFDocument *document = [[PDFDocument alloc] initWithData:pdfData];
    
    NSString *currentUserHomeDirectory = NSHomeDirectory();
    NSString *fileName = [NSString stringWithFormat: @"%@/Desktop/%@.pdf", currentUserHomeDirectory, self.selectedNote.title];
    
    [document writeToFile:fileName];
}

- (IBAction)insertImage:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    NSArray *arrayOfAllowedFileType = @[@"jpg", @"png", @"gif"];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowedFileTypes:arrayOfAllowedFileType];
    [openPanel setAllowsMultipleSelection:YES];
    
    if ([openPanel runModal] == NSOKButton) {
        NSArray *files = [openPanel URLs];
        
        for (NSURL *file in files) {
            NSLog(@"File Path: %@", [file path]);
            
            NSString *filePath = [file path];
            
            NSInteger insertPoint =
            [[[self.contentField selectedRanges]
              objectAtIndex:0] rangeValue].location;
            
            NSString *insertMarkdown = [NSString
                                        stringWithFormat:@"![file://%@](Enter your comment)", filePath];
            if (insertPoint) {
                [self.contentField insertText:insertMarkdown];
            }
        }
    }
}

- (NSString *)getPlainTitle: (NSString *)content
{
    NSArray *contentArray = [content
                             componentsSeparatedByString:@"\n"];
    
    for (NSString *markdownTitle in contentArray) {
        Document *doc = [[Document alloc]
                         initWithContent:markdownTitle];
        
        Parser *parser = [[Parser alloc] initWithDocument:doc];
        [parser parse];
        
        NSString *title = [parser render];
        NSRange r;
        while ((r = [title rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
            title = [title stringByReplacingCharactersInRange:r withString:@""];
        }
        
        if (title.length > 0) {
            return title;
        }
    }
    
    return @"No Title";
}
@end
