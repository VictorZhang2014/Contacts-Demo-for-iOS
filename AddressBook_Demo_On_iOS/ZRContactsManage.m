//
//  ZRContactsManage.m
//  AddressBook_Demo_On_iOS
//
//  Created by Victor John on 6/15/16.
//  Copyright © 2016 XiaoRuiGeGe. All rights reserved.
//

#import "ZRContactsManage.h"
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>
#import <UIKit/UIKit.h>
#import <ContactsUI/ContactsUI.h>

#define SystemVersion [[UIDevice currentDevice].systemVersion floatValue]
#define iOSAbove9 (SystemVersion >= 9.0)
#define iOSAbove8 (SystemVersion >= 8.0)
#define iOSAbove7 (SystemVersion >= 7.0)

typedef void(^SelectOnePersonCompletion)(NSString*, NSString*);


/*
 It is a delegate events class.
 */
@interface ZRDelegateController : UIViewController<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>

@property (nonatomic, copy) void(^SelectOnePersonCompletion)(NSString*, NSString*);

@end

@implementation ZRDelegateController

/**
 * Selection contacter from Contacts is Starting.
 */
#pragma mark - ABPeoplePickerNavigationControllerDelegate events
//Available on iOS 8.0
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString *phoneNO;
    if (ABMultiValueGetCount(phone) > 0) {
        phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, 1);
    }
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if (self.SelectOnePersonCompletion) {
        self.SelectOnePersonCompletion(@"", phoneNO);
    }
}

//Available on iOS 7.0
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString *phoneNO;
    if (ABMultiValueGetCount(phone) > 0) {
        phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, 1);
    } 
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
  
    if (self.SelectOnePersonCompletion) {
        self.SelectOnePersonCompletion([NSString stringWithFormat:@"%@ %@ %@", firstName, middleName, lastName], phoneNO);
    }
    return YES;
}

#pragma mark - CNContactPickerDelegate events
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    NSString *number = [contact.phoneNumbers firstObject].value.stringValue;
    if (self.SelectOnePersonCompletion) {
        self.SelectOnePersonCompletion([NSString stringWithFormat:@"%@ %@ %@", contact.givenName, contact.middleName, contact.familyName], number);
    }
}
/*
 * Selection Contacter from Contacts is Ended.
 **/


@end

@class ZRContactItem;

@interface ZRContactsManage()
@property (nonatomic, strong) ZRDelegateController *delegateController;

@property (nonatomic, assign) ABAddressBookRef addressBook;
@end

@implementation ZRContactsManage

- (ZRDelegateController *)delegateController
{
    if (!_delegateController) {
        _delegateController = [[ZRDelegateController alloc] init];
    }
    return _delegateController;
}

+ (instancetype)contacts
{
    static ZRContactsManage *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[ZRContactsManage alloc] init];
    });
    return manage;
}

- (void)selectContacter:(UIViewController *)viewController completion:(void (^)(NSString *, NSString *))completion 
{
    self.delegateController.SelectOnePersonCompletion = completion;
    if (iOSAbove9) {
        CNContactPickerViewController * contact = [[CNContactPickerViewController alloc] init];
        contact.delegate = self.delegateController;
        [viewController presentViewController:contact animated:YES completion:nil];
    } else {
        ABPeoplePickerNavigationController *nav = [[ABPeoplePickerNavigationController alloc] init];
        nav.peoplePickerDelegate = self.delegateController;
        [viewController presentViewController:nav animated:YES completion:nil];
        ;
    }
}

- (NSArray<ZRContactItem *>*)getAllContacter:(NSString *__autoreleasing *)error
{
    if (iOSAbove9) {
        return [self getAllContactsAboveiOS9:error];
    } else {
        return [self getAllContactsBeneathiOS9:error];
    }
}

- (NSArray *)getAllContactsAboveiOS9:(NSString *__autoreleasing *)error
{
    NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusAuthorized) {
        *error = [NSString stringWithFormat:@"Grant this application to access your Contacts, please!"];
        return nil;
    }
    
    NSError *errors;
    CNContactStore * contactStore = [[CNContactStore alloc] init];
    CNContactFetchRequest * contactRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:[self contactKeys]];
    [contactStore enumerateContactsWithFetchRequest:contactRequest error:&errors usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        ZRContactItem *item = [[ZRContactItem alloc] init];
        item.identifier = contact.identifier;
        item.givenName = [self isnil:contact.givenName];
        item.familyName = [self isnil:contact.familyName];
        item.middleName = [self isnil:contact.middleName];
        
        NSMutableArray *phoneList = [[NSMutableArray alloc] init];
        for (CNLabeledValue<CNPhoneNumber*>* label in contact.phoneNumbers) {
            [phoneList addObject:label.value.stringValue];
        }
        item.phoneNumbers = phoneList;
        
        NSMutableArray *emailList = [[NSMutableArray alloc] init];
        for (CNLabeledValue<NSString*>* label in contact.emailAddresses) {
            [emailList addObject:label.value];
        }
        item.email = emailList;
        
        NSMutableArray *addressList = [[NSMutableArray alloc] init];
        for (CNLabeledValue<CNPostalAddress*>* label in contact.postalAddresses) {
            CNPostalAddress *addr = label.value;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[@"street"] = addr.street;
            dic[@"city"] = addr.city;
            dic[@"state"] = addr.state;
            dic[@"postalCode"] = addr.postalCode;
            dic[@"country"] = addr.country;
            dic[@"countryCode"] = addr.ISOCountryCode;
            [addressList addObject:dic];
        }
        item.address = addressList;
        
        [contactArray addObject:item];
    }];
    *error = errors.userInfo;
    return contactArray;
}

- (NSArray *)getAllContactsBeneathiOS9:(NSString *__autoreleasing *)err
{
    __block NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    
    //1.Create Address Book instance.
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    self.addressBook = book;
    
    //2.Request to access the Address Book
    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
        if(granted){
            //Access Success
            NSArray * allPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(book);
            
            for (int i = 0; i < allPeople.count; i++) {
                ABRecordRef alPeople = (__bridge ABRecordRef)(allPeople[i]);
                
                ZRContactItem *item = [[ZRContactItem alloc] init];
                NSString *firstName = (__bridge NSString *)ABRecordCopyValue(alPeople, kABPersonFirstNameProperty);
                NSString *middleName = (__bridge NSString *)ABRecordCopyValue(alPeople, kABPersonMiddleNameProperty);
                NSString *lastName = (__bridge NSString *)ABRecordCopyValue(alPeople, kABPersonLastNameProperty);
                 
                
                ABMultiValueRef phone = ABRecordCopyValue(alPeople, kABPersonPhoneProperty);
                CFArrayRef phoneArray = ABMultiValueCopyArrayOfAllValues(phone);
                NSMutableArray *phoneList = [[NSMutableArray alloc] init];
                if (phoneArray) {
                    CFIndex phoneCount = CFArrayGetCount(phoneArray);
                    for (CFIndex j = 0 ; j < phoneCount; j++) {
                        CFStringRef mobile = ABMultiValueCopyValueAtIndex(phone, j);
                        [phoneList addObject:(__bridge NSString *)mobile];
                        CFRelease(mobile);
                    }
                }
                if (phoneArray) CFRelease(phoneArray);
                if (phone) CFRelease(phone);
                
                ABMultiValueRef email = ABRecordCopyValue(alPeople, kABPersonEmailProperty);
                CFArrayRef emailArray = ABMultiValueCopyArrayOfAllValues(email);
                NSMutableArray *emailList = [[NSMutableArray alloc] init];
                if (emailArray) {
                    CFIndex emailCount = CFArrayGetCount(emailArray);
                    for (CFIndex j = 0 ; j < emailCount; j++) {
                        CFStringRef mail = ABMultiValueCopyValueAtIndex(email, j);
                        [emailList addObject:(__bridge NSString *)mail];
                        CFRelease(mail);
                    }
                }
                if (emailArray) CFRelease(emailArray);
                if (email) CFRelease(email);
                
                ABMultiValueRef address = ABRecordCopyValue(alPeople, kABPersonAddressProperty);
                CFArrayRef addrArray = ABMultiValueCopyArrayOfAllValues(address);
                NSMutableArray *addrList = [[NSMutableArray alloc] init];
                if (addrArray) { 
                    CFDictionaryRef dic = CFArrayGetValueAtIndex(addrArray, 0);
                    NSString *city = (__bridge NSString *)CFDictionaryGetValue(dic, kABPersonAddressCityKey);
                    NSString *CountryCode = (__bridge NSString *)CFDictionaryGetValue(dic, kABPersonAddressCountryCodeKey);
                    NSString *Country = (__bridge NSString *)CFDictionaryGetValue(dic, kABPersonAddressCountryKey);
                    NSString *State = (__bridge NSString *)CFDictionaryGetValue(dic, kABPersonAddressStateKey);
                    NSString *Street = (__bridge NSString *)CFDictionaryGetValue(dic, kABPersonAddressStreetKey);
                    NSString *ZIP = (__bridge NSString *)CFDictionaryGetValue(dic, kABPersonAddressZIPKey);
                    
                    NSMutableDictionary *dic1 = [[NSMutableDictionary alloc] init];
                    dic1[@"street"] = Street;
                    dic1[@"city"] = city;
                    dic1[@"state"] = State;
                    dic1[@"postalCode"] = ZIP;
                    dic1[@"country"] = Country;
                    dic1[@"countryCode"] = CountryCode;
                    [addrList addObject:dic1];
                    
                    CFRelease(dic);
                }
                if (addrArray) CFRelease(addrArray);
                if (address) CFRelease(address);
                
                item.givenName = [self isnil:firstName];
                item.familyName = [self isnil:lastName];
                item.middleName = [self isnil:middleName];
                item.phoneNumbers = phoneList;
                item.email = emailList;
                item.address = addrList;
                [contactArray addObject:item];
            
                if (alPeople) CFRelease(alPeople);
            }
        }else{
            //Access denied.
            *err = @"Grant this application to access your Contacts, please! ";
            NSLog(@"%@", *err);
        }
        //Release book instance
//        if (book)
//            CFAutorelease(book);
    });
    return contactArray;
}

- (NSString *)isnil:(NSString *)str
{
    return str ? str : @"";
}

- (BOOL)deleteContacter:(ZRContactItem *)contactItem error:(NSError *__autoreleasing *)error
{
    __block NSError *err;
    if (iOSAbove9) {
        
        CNContactStore * contactStore = [[CNContactStore alloc] init];
        CNContactFetchRequest * contactRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:[self contactKeys]];
        [contactStore enumerateContactsWithFetchRequest:contactRequest error:&err usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            if([contact.familyName isEqualToString:contactItem.familyName] &&
               [contact.middleName isEqualToString:contactItem.middleName] &&
               [contact.givenName isEqualToString:contactItem.givenName]) {
                
                CNLabeledValue<CNPhoneNumber*>* number1 = [contact.phoneNumbers firstObject];
                CNPhoneNumber *phone = number1.value;
                NSString *number2 = [contactItem.phoneNumbers firstObject];
                if ([phone.stringValue isEqualToString:number2]) {
                    CNSaveRequest *deleteRequest = [[CNSaveRequest alloc] init];
                    [deleteRequest deleteContact:(CNMutableContact *)[contact mutableCopy]];
                    CNContactStore *deletestore = [[CNContactStore alloc] init];
                    [deletestore executeSaveRequest:deleteRequest error:nil];
                    *stop = YES;
                }
            }
        }];
        
    } else {
        
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        
        ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
            if(granted){
                //Access Success
                NSArray * allPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(book);
                
                for (int i = 0; i < allPeople.count; i++) {
                    ABRecordRef alPeople = (__bridge ABRecordRef)(allPeople[i]);
                    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(alPeople, kABPersonFirstNameProperty);
                    NSString *middleName = (__bridge NSString *)ABRecordCopyValue(alPeople, kABPersonMiddleNameProperty);
                    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(alPeople, kABPersonLastNameProperty);
                    
                    if([[self isnil:lastName] isEqualToString:contactItem.familyName] &&
                       [[self isnil:middleName] isEqualToString:contactItem.middleName] &&
                       [[self isnil:firstName] isEqualToString:contactItem.givenName]) {
                    
                        ABMultiValueRef phone = ABRecordCopyValue(alPeople, kABPersonPhoneProperty);
                        CFArrayRef phoneArray = ABMultiValueCopyArrayOfAllValues(phone);
                        NSString *mob = [[NSString alloc] init];
                        if (phoneArray) {
                            CFIndex phoneCount = CFArrayGetCount(phoneArray);
                            for (CFIndex j = 0 ; j < phoneCount; ) {
                                CFStringRef mobile = ABMultiValueCopyValueAtIndex(phone, j);
                                mob = (__bridge NSString *)mobile;
                                CFRelease(mobile);
                                break;
                            }
                        }
                        if (phoneArray) CFRelease(phoneArray);
                        if (phone) CFRelease(phone);
                        
                        if ([mob isEqualToString:[contactItem.phoneNumbers firstObject]]) {
                            ABAddressBookRemoveRecord(book, alPeople, NULL);
                            ABAddressBookSave(book, NULL);
                            if (alPeople) CFRelease(alPeople);
                            break;
                        }
                    }
                }
            }
        });
        
    }
    
    if (err) {
        *error = err;
        return NO;
    }
    return YES;
}

- (BOOL)addContacter:(ZRContactItem *)contactItem
{
    if (iOSAbove9) { 
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.givenName = contactItem.givenName;
        contact.familyName = contactItem.familyName;
        contact.middleName = contactItem.middleName;

        NSMutableArray* phones = [NSMutableArray new];
        for(NSString* phone in contactItem.phoneNumbers) {
            if (phone.length <= 0) {
                continue;
            }
            CNPhoneNumber *mobileNumber = [[CNPhoneNumber alloc] initWithStringValue:phone];
            CNLabeledValue *mobilePhone = [[CNLabeledValue alloc] initWithLabel:@"Phone" value:mobileNumber];
            [phones addObject:mobilePhone];
        }
        contact.phoneNumbers = [NSArray arrayWithArray:phones];
        
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
        [saveRequest addContact:contact toContainerWithIdentifier:nil];
        CNContactStore *store = [[CNContactStore alloc] init];
        NSError *error = nil;
        [store executeSaveRequest:saveRequest error:&error];
        if (error) {
            return NO;
        }
        return YES;
    } else {
        
        if(ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return NO;
        
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        ABRecordRef people = ABPersonCreate();
        
        CFStringRef firstName = (__bridge CFStringRef)contactItem.givenName;
        CFStringRef lastName = (__bridge CFStringRef)contactItem.familyName;
        CFStringRef middleName = (__bridge CFStringRef)contactItem.middleName;
        
        ABRecordSetValue(people, kABPersonFirstNameProperty, firstName, NULL);
        ABRecordSetValue(people, kABPersonLastNameProperty, lastName, NULL);
        ABRecordSetValue(people, kABPersonMiddleNameProperty, middleName, NULL);
        
        ABMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        for (NSString *mobile in contactItem.phoneNumbers) {
            if (mobile.length <= 0) {
                continue;
            }
            ABMultiValueAddValueAndLabel(phone, (__bridge CFStringRef)mobile, kABPersonPhoneIPhoneLabel, NULL);
        }
        ABRecordSetValue(people, kABPersonPhoneProperty, phone, NULL);
        
        ABAddressBookAddRecord(book, people, NULL);
        ABAddressBookSave(book, NULL);
        
        if (lastName)
            CFRelease(lastName);
        if (firstName)
            CFRelease(firstName);
        if (middleName)
            CFRelease(middleName); 
        if (people)
            CFRelease(people);
        if (book)
            CFRelease(book);
        return YES;
    } 
}

- (void)dealloc
{
    //Release book instance
    if (self.addressBook)
        CFRelease(self.addressBook);
}

- (NSArray*)contactKeys
{
    return @[CNContactNamePrefixKey,
             CNContactGivenNameKey,
             CNContactMiddleNameKey,
             CNContactFamilyNameKey,
             CNContactPreviousFamilyNameKey,
             CNContactNameSuffixKey,
             CNContactNicknameKey,
             CNContactPhoneticGivenNameKey,
             CNContactPhoneticMiddleNameKey,
             CNContactPhoneticFamilyNameKey,
             CNContactOrganizationNameKey,
             CNContactDepartmentNameKey,
             CNContactJobTitleKey,
             CNContactBirthdayKey,
             CNContactNonGregorianBirthdayKey,
             CNContactNoteKey,
             CNContactImageDataKey,
             CNContactThumbnailImageDataKey,
             CNContactImageDataAvailableKey,
             CNContactTypeKey,
             CNContactPhoneNumbersKey,
             CNContactEmailAddressesKey,
             CNContactPostalAddressesKey,
             CNContactDatesKey,
             CNContactUrlAddressesKey,
             CNContactRelationsKey,
             CNContactSocialProfilesKey,
             CNContactInstantMessageAddressesKey];
}
@end


@implementation ZRContactItem

@end



