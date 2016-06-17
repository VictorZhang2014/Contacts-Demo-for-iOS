//
//  ZRWriteContactsController.m
//  AddressBook_Demo_On_iOS
//
//  Created by Victor John on 16/6/15.
//  Copyright © 2016年 XiaoRuiGeGe. All rights reserved.
//

#import "ZRWriteContactsController.h"
#import "ZRContactsManage.h"

@interface ZRWriteContactsController()

@property (weak, nonatomic) IBOutlet UITextField *giveName;

@property (weak, nonatomic) IBOutlet UITextField *lastName;

@property (weak, nonatomic) IBOutlet UITextField *middleName;

@property (weak, nonatomic) IBOutlet UITextField *phone1;

@property (weak, nonatomic) IBOutlet UITextField *phone2;

@property (weak, nonatomic) IBOutlet UITextField *phone3;

- (IBAction)addContacter:(id)sender;

@end

@implementation ZRWriteContactsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Add Contacter";
}



- (IBAction)addContacter:(id)sender {
    
    ZRContactItem *item = [[ZRContactItem alloc] init];
    item.givenName = self.giveName.text;
    item.familyName = self.lastName.text;
    item.middleName = self.middleName.text;
    item.phoneNumbers = @[_phone1.text, _phone2.text, _phone3.text];
    if ([[ZRContactsManage contacts] addContacter:item]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"Add Contacter successful!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Failed to Add Contacter!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    }
}
@end
