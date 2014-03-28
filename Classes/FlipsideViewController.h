//
//  FlipsideViewController.h
//  passwordGenerator
//
//  Created by Rick Potsakis on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define kLowerSegmentIndex 0
#define kCamelSegmentIndex 1
#define kUpperSegmentIndex 2

// Variables needed in both views
#define kFilename @"words.sqlite" // name of db file with ext

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	
	IBOutlet UISwitch *soundsSwitch;
	IBOutlet UISwitch *shakeSwitch;
	IBOutlet UISegmentedControl *letterCaseSegment;
	
	sqlite3 *database;
	
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) UISwitch *soundsSwitch;
@property (nonatomic, retain) UISwitch *shakeSwitch;
@property (nonatomic, retain) UISegmentedControl *letterCaseSegment;

- (IBAction)done:(id)sender;
- (IBAction)letterCaseSegmentChanged:(id)sender;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

