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

    // selected note
    self.selectedNote = [self.notes lastObject];
    
    // initialise the content
    [self.contentField setString:self.selectedNote.content];
    
    // delegate the content to itself
    [self.contentField setDelegate:self];

    // set the font and font size
    [[self.contentField textStorage] setFont:[NSFont fontWithName:@"Lucida Grande" size:14.0]];

    // Loading the stylesheet
    WebPreferences *webPrefs = [WebPreferences
                                standardPreferences];
    
    [webPrefs setUserStyleSheetEnabled:YES];

    [webPrefs setUserStyleSheetLocation:[[NSBundle mainBundle]
                                         URLForResource:@"markdown"
                                         withExtension:@"css"]];
    
    // Set your webview's preferences
    [self.webView setPreferences:webPrefs];
    
    // Insert the timer to the main thread
    [[NSRunLoop mainRunLoop] addTimer:self.timer
                              forMode:NSRunLoopCommonModes];
}

/*
 * Lazy load the timer
 */
-(NSTimer *) timer
{
    double timeInterval = 2.0;
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(renderContent:) userInfo:nil repeats:YES];
    }
    return _timer;
}

// Lazy load the rendering stack
-(NSMutableArray *) renderingStack
{
    if (!_renderingStack) {
        _renderingStack = [[NSMutableArray alloc] init];
    }
    return _renderingStack;
}

// Realtime rendering feature
-(void)renderContent:(NSTimer *)timer
{
    if ([self.renderingStack isEmpty]) {
        return;
    }
    
    // Remove all other elements in the rendering stack
    NSString *content = [self.renderingStack pop];
    
    // Dispatching the rendering work to the thread pool
    dispatch_async(self.renderingQueue, ^{
        Document *doc = [[Document alloc]
                         initWithContent:content];
        
        Parser *parser = [[Parser alloc] initWithDocument:doc];
        [parser parse];
        
        // After the computation intense work done, join the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self.webView mainFrame]
             loadHTMLString:[parser render] baseURL:nil];
        });
    });
}

// Lazy load the rendering queue
-(dispatch_queue_t) renderingQueue
{
    if (!_renderingQueue) {
        _renderingQueue = dispatch_queue_create("rendering queue", NULL);
    }
    return _renderingQueue;
}

// Text view change listener
- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    if ([notification object] == self.contentField) {
        [self.renderingStack push:self.contentField.string];
    }
}

// Delegate the number of rows to the controller
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.notes count];
}

// Delegate the table cell object
- (id) tableView: (NSTableView *) tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Note *note = [self.notes objectAtIndex:row];
    NSString *title = note.title;
    
    return title;
}

// Fetching notes from the database, saving it to the array
-(NSMutableArray *)notes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *notes = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    _notes = [NSMutableArray arrayWithArray:notes];
    
    // if there are no notes, create a "hello world" example
    if ([_notes count] == 0) {
        Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
        
        note.title = @"Hello";
        note.content = @"World";
        
        [self.managedObjectContext save:nil];
    }
    
    return _notes;
}

/*
 * Action of note selection changed
 */
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

// Save the content to database
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

// Create a new note editing env
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

// Delete a certain note
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
    
    // Dirty method. Refresh the notes array. Since the life cycle is not end.
    [self.tableView reloadData];
}

// Action that export the content to PDF
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

// Insert image from local directory to the app.
- (IBAction)insertImage:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    // Restrict the file format
    NSArray *arrayOfAllowedFileType = @[@"jpg", @"png", @"gif"];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowedFileTypes:arrayOfAllowedFileType];
    [openPanel setAllowsMultipleSelection:YES];
    
    if ([openPanel runModal] == NSOKButton) {
        NSArray *files = [openPanel URLs];
        
        for (NSURL *file in files) {
            
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

// Get the title of note. As the title is not explicitly specified.
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
