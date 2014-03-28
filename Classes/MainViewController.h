//
//  MainViewController.h
//  passwordGenerator
//
//  Created by Rick Potsakis on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>
#import "FlipsideViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


#define kWordTypeSection 0
#define kNumberSection 1

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UITableViewDataSource, UIActionSheetDelegate, 
	MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAccelerometerDelegate>
{
	IBOutlet UITableView *wordTypeTable;
	IBOutlet UITextField *passwordField;
	IBOutlet UILabel *numberSliderLabel;
	IBOutlet UIButton *generateButton;
	NSMutableDictionary *options;
	NSMutableDictionary *loadedWordsByType;
	NSDictionary *wordTypeCounts;
	NSArray *wordTypes;
	NSArray *numberTypes;
	NSIndexPath *lastNumberIndexPath;
	
	NSMutableString *randomWord;
	sqlite3 *database;
	sqlite3 *historyDatabase;
	
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) IBOutlet UITableView *wordTypeTable;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UILabel *numberSliderLabel;
@property (nonatomic, retain) IBOutlet UIButton *generateButton;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, retain) NSMutableDictionary *loadedWordsByType;
@property (nonatomic, retain) NSDictionary *wordTypeCounts;
@property (nonatomic, retain) NSArray *wordTypes;
@property (nonatomic, retain) NSArray *numberTypes;
@property (nonatomic, retain) NSIndexPath *lastNumberIndexPath;
@property (nonatomic, retain) NSMutableString *randomWord;
@property (nonatomic, retain) NSUserDefaults *defaults;

- (IBAction)showInfo:(id)sender;
- (IBAction)numberSliderChanged:(id)sender;
- (IBAction)showSendOptions:(id)sender;
- (IBAction)generatePassword:(id)sender;
- (IBAction)scramblePassword:(id)sender;

- (void)initializeDatabase;
- (void)initWords;
- (void)getRandomWord:(NSString *)wordType;
- (void)runScramble;

- (void)displayComposerSheet;
- (void)copyPassword;

@end
