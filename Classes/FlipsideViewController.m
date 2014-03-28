//
//  FlipsideViewController.m
//  passwordGenerator
//
//  Created by Rick Potsakis on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize soundsSwitch;
@synthesize shakeSwitch;
@synthesize letterCaseSegment;

- (void)viewDidLoad {
    [super viewDidLoad];
   // self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	soundsSwitch.on = [defaults boolForKey:@"sounds"];
	shakeSwitch.on = [defaults boolForKey:@"useShake"];
	
	[self.letterCaseSegment setSelectedSegmentIndex: [defaults integerForKey:@"letterCaseIndex"]];
}


- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)letterCaseSegmentChanged:(id)sender {
		
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
}

- (void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:soundsSwitch.on forKey:@"sounds"];
	[defaults setBool:shakeSwitch.on forKey:@"useShake"];
	[defaults setInteger:letterCaseSegment.selectedSegmentIndex forKey:@"letterCaseIndex"];
	
	[super viewWillDisappear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	[soundsSwitch release];
	[shakeSwitch release];
	[letterCaseSegment release];
	
	
    [super dealloc];
}



@end
