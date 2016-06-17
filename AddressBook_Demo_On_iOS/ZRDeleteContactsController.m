//
//  ZRDeleteContactsController.m
//  AddressBook_Demo_On_iOS
//
//  Created by Victor John on 6/16/16.
//  Copyright © 2016 XiaoRuiGeGe. All rights reserved.
//

#import "ZRDeleteContactsController.h"
#import "ZRContactsManage.h"

@interface ZRDeleteContactsController()
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation ZRDeleteContactsController

- (NSMutableArray *)data
{
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
        NSString *error;
        _data = (NSMutableArray *)[[ZRContactsManage contacts] getAllContacter:&error];
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
    self.navigationItem.title = @"Delete Contacter";
    self.tableView.scrollEnabled = NO;
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
    cell.showsReorderControl = YES;
    cell.detailTextLabel.text = [item.phoneNumbers firstObject];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@", item.givenName, item.middleName, item.familyName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Note" message:@"Are you sure want to delete this person of this row?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ZRContactItem *item = [self.data objectAtIndex:indexPath.row];
            NSError *error;
            if ([[ZRContactsManage contacts] deleteContacter:item error:&error]) {
                NSLog(@"Delete Successful!");
            }
            [self.data removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        
//    }];
//    
//    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        
//    }];
//    action1.backgroundColor = [UIColor grayColor];
//    
//    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"点赞" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        
//    }];
//    action2.backgroundColor = [UIColor purpleColor];
//    
//   return @[action0,action1, action2];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
