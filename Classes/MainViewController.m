//
//  MainViewController.m
//  passwordGenerator
//
//  Created by Rick Potsakis on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation MainViewController

@synthesize wordTypeTable;
@synthesize passwordField;
@synthesize numberSliderLabel;
@synthesize generateButton;
@synthesize options;
@synthesize loadedWordsByType;
@synthesize wordTypeCounts;
@synthesize wordTypes;
@synthesize numberTypes;
@synthesize lastNumberIndexPath;
@synthesize randomWord;
@synthesize defaults;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[self initializeDatabase];
	
	// get user defaults
	self.defaults = [NSUserDefaults standardUserDefaults];
	
	// Word Types Data
	NSArray *array = [[NSArray alloc] initWithObjects:@"Adjective", @"Noun", @"Verb", nil];
	self.wordTypes = array;
	[array release];
	
	// Number Types Data
	NSArray *numberArray = [[NSArray alloc] initWithObjects:@"Beginning", @"End", nil]; // removed for now @"Middle",
	self.numberTypes = numberArray;
	[numberArray release];
	
		
	// init options
	randomWord = nil;
	NSNumber *num = [NSNumber numberWithBool:NO];
	NSArray *enabled = [[NSArray alloc] initWithObjects:num, num, num, nil];
	NSMutableDictionary *odict = [NSMutableDictionary dictionaryWithObjects:enabled 
													 forKeys:self.wordTypes];
	[enabled release];
	
	// add more options
	for (NSString *key in self.numberTypes) {
		// values in foreach loop
		[odict setObject:num forKey:key];
	}
	
	NSNumber *numDigits = [NSNumber numberWithInt:3];
	[odict setObject:numDigits forKey:@"numberSliderValue"];
	
	self.options = odict;
	
	
	// init words
	self.loadedWordsByType = [NSMutableDictionary dictionaryWithCapacity:3];
	[self initWords];
	
	// init accelerator detection
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = self;
	accelerometer.updateInterval = 1.0f/60.0f;
	
	[super viewDidLoad];
}



- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	[generateButton release];
	[numberTypes release];
	[wordTypes release];
	[wordTypeTable release];
	[options release];
	[randomWord release];
	[defaults release];
	
	[passwordField release];
	[numberSliderLabel release];
	[loadedWordsByType release];
	[wordTypeCounts release];
	[lastNumberIndexPath release];
	
	
    [super dealloc];
}

#pragma mark -
#pragma mark My Button Actions

- (IBAction)showSendOptions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Copy",@"Email",@"SMS",nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}


- (IBAction)numberSliderChanged:(id)sender {
	UISlider *slider = (UISlider *)sender;
	int progressAsInt = (int)(slider.value + 0.5f);
	
	NSString *newText = [[NSString alloc] initWithFormat:@"%d", progressAsInt];
	numberSliderLabel.text = newText;
	[newText release];
	
	[self.options setObject:[NSNumber numberWithInt:progressAsInt] forKey:@"numberSliderValue"];
}

- (IBAction)generatePassword:(id)sender {
	BOOL wordTypePicked = NO;
	NSMutableString *tempString = [[NSMutableString alloc] init];
	//[tempString retain];
	
	/* generate random number */
	srandom(time(NULL));
	int sliderValue = [[self.options valueForKey:@"numberSliderValue"] intValue];
	int randomMax = (int)pow(10, sliderValue);
	int randomNum = random() % randomMax;
	
	// Append Number according to user selection
	//BEGIN NUMBER
	if ([[self.options valueForKey:@"Beginning"] intValue] == YES) {
		[tempString appendFormat:@"%d", randomNum];
	}
	
	/* Get a random word for each word type the user selected */
	if ([[self.options valueForKey:@"Adjective"] intValue] == YES) {
		wordTypePicked = YES;
		[self getRandomWord:@"Adjective"];
		
		if([defaults integerForKey:@"letterCaseIndex"] == kCamelSegmentIndex){
			[tempString appendString:[randomWord capitalizedString]];
		} else if([defaults integerForKey:@"letterCaseIndex"] == kUpperSegmentIndex){
			[tempString appendString:[randomWord uppercaseString]];
		} else {
			[tempString appendString:[randomWord lowercaseString]];
		}
		
	}
	
	// MIDDLE NUMBER
	if ([[self.options valueForKey:@"Middle"] intValue] == YES) {
		[tempString appendFormat:@"%d", randomNum];
	}
	
	if ([[self.options valueForKey:@"Noun"] intValue] == YES) {
		wordTypePicked = YES;
		[self getRandomWord:@"Noun"];
		
		if([defaults integerForKey:@"letterCaseIndex"] == kCamelSegmentIndex){
			[tempString appendString:[randomWord capitalizedString]];
		} else if([defaults integerForKey:@"letterCaseIndex"] == kUpperSegmentIndex){
			[tempString appendString:[randomWord uppercaseString]];
		} else {
			[tempString appendString:[randomWord lowercaseString]];
		}
	}
	
	if ([[self.options valueForKey:@"Verb"] intValue] == YES) {
		wordTypePicked = YES;
		[self getRandomWord:@"Verb"];
		
		if([defaults integerForKey:@"letterCaseIndex"] == kCamelSegmentIndex){
			[tempString appendString:[randomWord capitalizedString]];
		} else if([defaults integerForKey:@"letterCaseIndex"] == kUpperSegmentIndex){
			[tempString appendString:[randomWord uppercaseString]];
		} else {
			[tempString appendString:[randomWord lowercaseString]];
		}
	}
	
	// END NUMBER
	if ([[self.options valueForKey:@"End"] intValue] == YES) {
		[tempString appendFormat:@"%d", randomNum];
	}
	
	/* confirm options
	NSLog(@"%@", self.options); */
	
	
	if (wordTypePicked) {
		passwordField.text = tempString;
		[tempString release];
		//generateButton.enabled = YES;
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Word Type Needed"
														message:@"Please select at least one word type"
													   delegate:nil
											  cancelButtonTitle:@"Oops"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}

// scrambles password text field
- (IBAction)scramblePassword:(id)sender {
	// scramble letters
	[self runScramble];
}

- (void)runScramble {
	NSMutableString *dyingString = [[NSMutableString alloc] initWithString:passwordField.text];
	NSMutableString *liveString = [[NSMutableString alloc] init];
	
	// play sound
	if ([defaults boolForKey:@"sounds"]) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"scramble" ofType:@"wav"];
		SystemSoundID soundID;
		AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundID);
		AudioServicesPlaySystemSound(soundID);
	}
	
	srandom(time(NULL));
	while ([dyingString length] > 0) {
		
		int randomIndex = random() % [dyingString length];
		[liveString appendFormat:@"%c", [dyingString characterAtIndex:randomIndex]];
		
		// remove char
		NSRange indexRange = NSMakeRange(randomIndex, 1);
		[dyingString deleteCharactersInRange:indexRange];
		
		//NSLog(@"%d dying: %@", randomIndex, dyingString);
	}
	//NSLog(@"scrambled: %@", liveString);
	
	passwordField.text = liveString;
	
	[liveString release];
	[dyingString release];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == kWordTypeSection) {
		return [wordTypes count];
	} else {
		return [numberTypes count];
	}

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * WordTypesCellIdentifier = @"WordTypesCellIdentifier";
	NSString *rowString = [[NSString alloc] init];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WordTypesCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:WordTypesCellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	if ([indexPath section] == kWordTypeSection) {
		rowString = [wordTypes objectAtIndex:row];
	} else {
		rowString = [numberTypes objectAtIndex:row];
	}

	
	cell.textLabel.text = rowString;
	[rowString release];
	
	return cell;
}


#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
	NSNumber *optionOn = [NSNumber numberWithBool:YES];
	NSNumber *optionOff = [NSNumber numberWithBool:NO];
	
	if (section == kWordTypeSection) {
		if (newCell.accessoryType == UITableViewCellAccessoryNone){
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			
			[self.options setObject:optionOn forKey:newCell.textLabel.text];
		} else {
			newCell.accessoryType = UITableViewCellAccessoryNone;
			
			[self.options setObject:optionOff forKey:newCell.textLabel.text];
		}
	} else {
		int oldRow = [lastNumberIndexPath row];
		int newRow = [indexPath row];
		
		if (newRow != oldRow || lastNumberIndexPath == nil) {
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastNumberIndexPath];
			if (oldCell != nil) {
				oldCell.accessoryType = UITableViewCellAccessoryNone;
				[self.options setObject:optionOff forKey:oldCell.textLabel.text];
			}
			
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			[self.options setObject:optionOn forKey:newCell.textLabel.text];
			
			lastNumberIndexPath = indexPath;
		} else {
			newCell.accessoryType = UITableViewCellAccessoryNone;
			[self.options setObject:optionOff forKey:newCell.textLabel.text];
			
			lastNumberIndexPath = nil;
		}

	}

	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
    // The header for the section
	if (section == kWordTypeSection) {
		return @"Word Types";
	} else {
		return @"Include Numbers";
	}

	
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	
    // The header for the section 
	if (section == kWordTypeSection) {
		return @"";
	} else {
		return @"";
	}

	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 30;
}

#pragma mark -
#pragma mark Database Methods

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
	// The database is stored in the application bundle
	NSString *path = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"sqlite"];
	
	// Open the database. The database was prepared outside the application.
	if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
		// even tho the open failed, call close to properly clean up resources
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open words database with message '%s'.", sqlite3_errmsg(database));
		// additional error handling, as appropriate...
	}
}

- (void)initWords {
	sqlite3_stmt *statement;
	NSString *sql;// = [[NSString alloc] init];
	NSString *randomString;// = [[NSString alloc] init];
	NSMutableArray *wordArray;// = [[NSMutableArray alloc] init];
		
	for (int i = 0; i < [self.wordTypes count]; i++) {
		wordArray = [[NSMutableArray alloc] init];
		sql = [NSString stringWithFormat:@"SELECT DISTINCT trim(word) FROM %@s WHERE word <> '' ORDER BY word", [self.wordTypes objectAtIndex:i]];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: Failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			// add to dict of words
			randomString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			[wordArray addObject:randomString];
		}
		sqlite3_finalize(statement);
		
		[self.loadedWordsByType setObject:wordArray forKey:[self.wordTypes objectAtIndex:i]];
		[wordArray release];
	}
}


- (void)getRandomWord:(NSString *)wordType {
	srandom(time(NULL));
	
	NSMutableArray *myarray = [[NSMutableArray alloc] init];
	//[myarray retain];
	
	[myarray setArray:[self.loadedWordsByType objectForKey:wordType]];
	
	int randomPK = random() % [myarray count];
	randomWord = [myarray objectAtIndex:randomPK];
	[myarray release];
}

#pragma mark -
#pragma mark Mail Methods

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
	
    [picker setSubject:@"Important Secret"];
	
		
    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat:@"New Password: %@", self.passwordField.text];
    [picker setMessageBody:emailBody isHTML:NO];
	
    // Show composer
    [self presentModalViewController:picker animated:YES];
	
    [picker release];
	
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the alert user with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {   
	NSString *emailResult = [[NSString alloc] init];
	
    // Notifies users about errors associated with the interface
    switch (result)
	
    {
        case MFMailComposeResultCancelled:
            emailResult = @"Mail message has been cancelled";
            break;
        case MFMailComposeResultSaved:
            emailResult = @"Mail message has been saved";
            break;
        case MFMailComposeResultSent:
            emailResult = @"Mail message has been sent";
            break;
        case MFMailComposeResultFailed:
            emailResult = @"Mail has failed!";
            break;
        default:
            emailResult = @"Mail was not sent";
            break;
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending Email"
													message:emailResult 
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
    [self dismissModalViewControllerAnimated:YES];
	[emailResult release];
}


#pragma mark -
#pragma mark SMS Methods

// Displays an SMS composition interface inside the application. 
- (void)displaySMSComposerSheet {
	
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
	
	NSString *smsBody = [NSString stringWithFormat:@"New Password: %@", self.passwordField.text];
	picker.body = smsBody;
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	NSString *smsResult = [[NSString alloc] init];
    
    // Notifies users about errors associated with the interface
    switch (result) {
        case MessageComposeResultCancelled:
			smsResult = @"SMS sending has been cancelled";
            break;
			
        case MessageComposeResultSent:
            smsResult = @"SMS has been sent";
            break;
			
        case MessageComposeResultFailed:
            smsResult = @"SMS sending failed";
            break;
			
        default:
            smsResult = @"SMS was not sent";
            break;
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending SMS"
													message:smsResult 
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
    [self dismissModalViewControllerAnimated:YES];
	[smsResult release];
}

#pragma mark -
#pragma mark Copy Methods

- (void)copyPassword {
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	gpBoard.string = self.passwordField.text;
}


#pragma mark -
#pragma mark ActionSheet Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	// 0 - copy, 1 - email, 2 - sms
	
	if ([self.passwordField.text length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Password!"
														message:@"Generate a password first."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		switch (buttonIndex) {
			case 0:
				[self copyPassword];
				break;
			case 1:
				[self displayComposerSheet];
				break;
			case 2:
				[self displaySMSComposerSheet];
				break;
			default:
				break;
		}
	}
}

#pragma mark -
#pragma mark Accelerometer Delegates

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	static NSInteger shakeCount = 0;
	static NSDate *shakeStart;
	
	NSDate *now = [[NSDate alloc] init];
	NSDate *checkDate = [[NSDate alloc] initWithTimeInterval:1.5f sinceDate:shakeStart];
	
	if ([now compare:checkDate] == NSOrderedDescending || shakeStart == nil) {
		shakeCount = 0;
		[shakeStart release];
		shakeStart = [[NSDate alloc] init];
	}
	[now release];
	[checkDate release];
	
	if (passwordField.text.length != 0 && [defaults boolForKey:@"useShake"]) {
		if (fabsf(acceleration.x) > 2.0
			|| fabsf(acceleration.y) > 2.0
			|| fabsf(acceleration.z) > 2.0) {
			shakeCount++;
			if (shakeCount > 4) {
				[self runScramble];
				//NSLog(@"I felt something");
				
				shakeCount = 0;
				[shakeStart release];
				shakeStart = [[NSDate alloc] init];
			}
		}
	}
	
}

@end
