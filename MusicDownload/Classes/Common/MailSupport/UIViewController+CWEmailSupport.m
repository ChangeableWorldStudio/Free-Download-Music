//
//  UIViewController+NABEmailSupport.m
//  Manhattan
//
//  Created by NAB NAB on 1/9/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>

#import "UIViewController+CWEmailSupport.h"
#import <MessageUI/MFMailComposeViewController.h>

@implementation UIDevice(machine)

- (NSString *)machine
{
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *machine =  [NSString stringWithCString:name encoding:NSUTF8StringEncoding];//[NSString stringWithCString:name];
	
	// Done with this
	free(name);
	
	return machine;
}

@end


@implementation UIViewController(NABEmailSupport)

- (void)displaySupportComposerSheetForAppname:(NSString *)appName delegate:(id)delegate {
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil){
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]){
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            
            mailController.mailComposeDelegate = delegate;
            
            [mailController setSubject:[NSString stringWithFormat:@"Feedback for %@", appName]];
            
            // Set up recipients
#warning change
            NSArray *toRecipients = [NSArray arrayWithObject:@"imedicsoft@gmail.com"]; 
            
            [mailController setToRecipients:toRecipients];
            
            UIDevice *device = [UIDevice currentDevice];
            
            NSString *deviceTypeCode = [device machine];
            NSString *deviceType = nil;
            
            if ([deviceTypeCode caseInsensitiveCompare:@"iPhone1,1"]==NSOrderedSame) {
                deviceType =@"iPhone";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPhone1,2"]==NSOrderedSame) {
                deviceType =@"iPhone 3G";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPhone2,1"]==NSOrderedSame) {
                deviceType =@"iPhone 3GS";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPhone3,1"]==NSOrderedSame) {
                deviceType =@"iPhone 4";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPhone4,1"]==NSOrderedSame) {
                deviceType =@"iPhone 4S";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPod1,1"]==NSOrderedSame) {
                deviceType =@"iPod 1st Gen";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPod2,1"]==NSOrderedSame) {
                deviceType =@"iPod 2nd Gen";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPod3,1"]==NSOrderedSame) {
                deviceType =@"iPod 3rd Gen";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPod4,1"]==NSOrderedSame) {
                deviceType =@"iPod 4th Gen";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPad1,1"]==NSOrderedSame) {
                deviceType =@"iPad";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPad2,1"]==NSOrderedSame) {
                deviceType =@"iPad 2";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPad2,3"]==NSOrderedSame) {
                deviceType =@"iPad 2 3G (CDMA)";
            }
            else if ([deviceTypeCode caseInsensitiveCompare:@"iPad2,2"]==NSOrderedSame) {
                deviceType =@"iPad 2 3G (GSM)";
            }
            
            NSString *deviceVersion = device.systemVersion;
            
            // Get country name
            NSLocale *locale = [NSLocale currentLocale];
            NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
            NSString *country = [locale displayNameForKey: NSLocaleCountryCode value:countryCode];
        
            // Fill out the email body text
            NSString *emailBody = [NSString stringWithFormat:@"Hi support team,\n\n<Problems/Bugs/Inquiries>\n\nCountry: %@\nDevice: %@\nApp Name: %@ %@\nFirmware version: %@\n\nThank you, ", country, deviceType, appName, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], deviceVersion];
            
            [mailController setMessageBody:emailBody isHTML:NO];
            
            [self presentModalViewController:mailController animated:YES]; 
		}
	}
}

- (void)displaySupportComposerSheetForAppname:(NSString *)appName {
    [self displaySupportComposerSheetForAppname:appName delegate:self];
}

#pragma mark - Share Mail

- (void)displayShareMailComposerSheetForAppname:(NSString *)appName {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil){
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]){
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            
            mailController.mailComposeDelegate = (id)self;
            
            [mailController setSubject:[NSString stringWithFormat:@"[SHARE APP] - %@", appName]];
            #warning change
            NSString *emailBody = @"Check out app at link: \n\n http://itunes.apple.com/app/human-anatomy-liver/id518655339?ls=1&mt=8";
            [mailController setMessageBody:emailBody isHTML:NO];
            
            [self presentModalViewController:mailController animated:YES]; 
		}
	}
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send Mail Status" message:@"a" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	switch (result)
	{
		case MFMailComposeResultCancelled:
			alertView.message = @"Sent mail canceled!";			
			[alertView show];
			break;
		case MFMailComposeResultSaved:
			alertView.message = @"Sent mail saved!";		
			[alertView show];			
			break;
		case MFMailComposeResultSent:
			alertView.message = @"Mail sent!";
			[alertView show];						
			break;
		case MFMailComposeResultFailed:
			alertView.message = @"Sent mail failed!";
			[alertView show];						
			break;
		default:
			alertView.message = @"Sent mail failed!";
			[alertView show];
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}

@end

