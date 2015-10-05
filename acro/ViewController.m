//
//  ViewController.m
//  acro
//
//  Created by Bill Snook on 10/4/15.
//  Copyright © 2015 BillSnook. All rights reserved.
//

#import "ViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField		*inputText;
@property (strong, nonatomic) IBOutlet UIButton			*lookupButton;

@property (strong, nonatomic) IBOutlet UITableView		*responseTable;


@property (strong, nonatomic)			NSMutableArray	*longFormList;

@end


@implementation ViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	NSLog( @"Acro at start");

	self.responseTable.hidden = YES;
	self.longFormList = [NSMutableArray arrayWithCapacity: 10];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)startLookup:(id)sender {
	
	NSString *lookupText = self.inputText.text;
	NSUInteger len = [lookupText length];
	if ( len < 2 ) {
		NSLog( @"Acronym length too small: %lu", (unsigned long)len);
		
		return;
	}
		
	if ( len > 20 ) {
		NSLog( @"Acronym length too large: %lu", (unsigned long)len);
		
		return;
	}
	
	// Text entry is acceptable
	[self.inputText resignFirstResponder];
	
	NSLog( @"Sending acronym: %@", lookupText);

	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
	hud.labelText = [NSString stringWithFormat: @"Looking up '%@'...", lookupText];

	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	
	AFHTTPResponseSerializer *respSer = manager.responseSerializer;
	NSSet *respSet = respSer.acceptableContentTypes;
//	NSLog(@"response acceptable content types: %@", [respSet description]);
	NSMutableSet *newSet = [NSMutableSet setWithSet: respSet];
	[newSet addObject: @"text/plain"];
	respSer.acceptableContentTypes = newSet;

	NSDictionary *params = [NSDictionary dictionaryWithObject: lookupText forKey: @"sf"];
	[self.longFormList removeAllObjects];
	
	[manager GET:@"http://www.nactem.ac.uk/software/acromine/dictionary.py" parameters: params
		 success:^(AFHTTPRequestOperation *operation, id responseObject) {
			 // responseObject is an array
			 if ( ( responseObject != nil ) && ( [responseObject count] > 0 ) ) {
				 NSDictionary *acroDict = [responseObject objectAtIndex: 0];
				 if ( acroDict != nil ) {
					 NSArray *lfs = [acroDict objectForKey: @"lfs"];
					 // Should now be an array of dictionaries for each entry
					 if ( lfs != nil ) {
						 // Walk array entries
						 for (NSDictionary *entry in lfs) {
							 NSString *entryName = [entry objectForKey: @"lf"];
							 NSLog(@"%@", entryName);
							 [self.longFormList addObject: entryName];
							 
						 }
					 }
				 }
			 }
			 
			 
			 [MBProgressHUD hideHUDForView: self.view animated: YES];
			 [self.responseTable reloadData];
			 self.responseTable.hidden = NO;
			 
		 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			 [MBProgressHUD hideHUDForView: self.view animated: YES];
			 NSLog(@"Error: %@", error);
		 }];
	

//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		// Do something...
//		[MBProgressHUD hideHUDForView: self.view animated: YES];
//	});
	
	
	
	
	
}


#pragma mark - Table data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSLog(@"numberOfRows: %lu", (unsigned long)[self.longFormList count]);
	if ( [self.longFormList count] == 0 ) {
		return 1;
	} else {
		return [self.longFormList count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"longForm" forIndexPath: indexPath];
	if ( [self.longFormList count] > indexPath.row ) {
		cell.textLabel.text = [self.longFormList objectAtIndex: indexPath.row];
	} else {
		cell.textLabel.text = @"No entries found";
	}

	return cell;
}


#pragma mark - Table delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	NSLog(@"textFieldDidBeginEditing");

}


- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	NSLog(@"textFieldDidEndEditing");
}


@end
