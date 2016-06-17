//
//  ZRContactsManage.h
//  AddressBook_Demo_On_iOS
//
//  Created by Victor John on 6/15/16.
//  Copyright © 2016 XiaoRuiGeGe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController;
@class ZRContactItem;

@interface ZRContactsManage : NSObject

+ (instancetype)contacts;

/*
 * Select a phone number of person from Contacts
 * @param viewController , which is presented controller
 */
- (void)selectContacter:(UIViewController *)viewController completion:(void(^)( NSString * name, NSString * number))completion;

/*
 * Get all contacters from Contacts.
 * @param error 
 * @return Return all contacters array , instead of nil.
 **/
- (NSArray<ZRContactItem *>*)getAllContacter:(NSString **)error;

/*
 * Delete specific contacters
 * @param contactItem is based on contact's info
 **/
- (BOOL)deleteContacter:(ZRContactItem *)contactItem error:(NSError **)error;

/*
 * Add a contacter to Contacts
 * @param contactItem is a contacter essential information
 **/
- (BOOL)addContacter:(ZRContactItem *)contactItem;

@end


@interface ZRContactItem : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *familyName;

@property (nonatomic, copy) NSString *givenName;

@property (nonatomic, copy) NSString *middleName;

@property (nonatomic, strong) NSArray *email;

@property (nonatomic, strong) NSArray *address;

@property (nonatomic, strong) NSArray *phoneNumbers;

@end

