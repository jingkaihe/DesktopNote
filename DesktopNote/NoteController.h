//
//  NoteController.h
//  DesktopNote
//
//  Created by Jingkai He on 24/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

@interface NoteController : NSObject <NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic, weak) IBOutlet NSTextField *titleTextField;
@property (nonatomic, strong) IBOutlet NSTextView *contentField;

@property (nonatomic, weak) IBOutlet NSButton *saveButton;

@property (nonatomic, copy) NSMutableArray *notes;
@property (nonatomic, weak) Note *selectedNote;
@end
