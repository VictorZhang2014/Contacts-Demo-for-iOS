//
//  ZRGetContactsController.m
//  AddressBook_Demo_On_iOS
//
//  Created by Victor John on 16/6/15.
//  Copyright © 2016年 XiaoRuiGeGe. All rights reserved.
//

#import "ZRGetContactsController.h"
#import "ZRContactsManage.h"

@interface ZRGetContactsController()

@property (nonatomic, strong) NSArray *data;

@end

@implementation ZRGetContactsController

- (NSArray *)data
{
    if (!_data) {
        _data = [[NSArray alloc] init];
        NSString *error;
        NSArray *t = [[ZRContactsManage contacts] getAllContacter:&error];
        _data = t;
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Message below:" message:error delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    return _data;
} 

- (void)viewDidLoad
{
    [super viewDidLoad];
        self.navigationItem.title = @"Get All Contacter";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reused_id = @"reused_id";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reused_id];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reused_id];
    }
    
    ZRContactItem *item = [self.data objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.text = [item.phoneNumbers firstObject];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@", item.givenName, item.middleName, item.familyName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
