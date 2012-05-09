//
//  BrowserViewController.h
//  MusicDownload
//
//  Created by Hung Tran on 17/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef enum BrowserViewControllerCurrentType {
    BrowserViewControllerCurrentTypeNormal,
    BrowserViewControllerCurrentTypeAddress,
    BrowserViewControllerCurrentTypeSearch
} BrowserViewControllerCurrentType;

@interface BrowserViewController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@end
