//
//  ViewController.m
//  AddressBook_Demo_On_iOS
//
//  Created by Victor John on 6/15/16.
//  Copyright © 2016 XiaoRuiGeGe. All rights reserved.
//

#import "ViewController.h"
#import "ZRContactsManage.h"

@interface ViewController ()
- (IBAction)selectContacter:(UIButton *)sender;
- (IBAction)getContacter:(UIButton *)sender;
- (IBAction)writeContacter:(UIButton *)sender;
- (IBAction)deleteContacter:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

//Select one contacter from contacts
- (IBAction)selectContacter:(UIButton *)sender {
    [[ZRContactsManage contacts] selectContacter:self completion:^(NSString *name, NSString *number) {
        NSLog(@"name = %@, number = %@", name, number);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Your Selection below:" message:[NSString stringWithFormat:@"Name: %@ \n Phone: %@.", name, number] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

- (IBAction)getContacter:(UIButton *)sender {
}

- (IBAction)writeContacter:(UIButton *)sender {
}

- (IBAction)deleteContacter:(UIButton *)sender {
}
@end
