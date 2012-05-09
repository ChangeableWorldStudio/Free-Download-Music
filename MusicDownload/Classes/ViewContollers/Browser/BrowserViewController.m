//
//  BrowserViewController.m
//  MusicDownload
//
//  Created by Hung Tran on 17/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"
#import "UISearchBar+Extra.h"
#import "AddBookmarkViewController.h"
#import "ViewBookmarkViewController.h"
#import "RipViewController.h"

@interface BrowserViewController ()

@property (nonatomic, strong) IBOutlet  UISearchBar             *searchBar;
@property (nonatomic, strong) IBOutlet  UITextField             *textFieldAddress;
@property (nonatomic, strong) IBOutlet  UIButton                *buttonReload;
@property (nonatomic, strong) IBOutlet  UILabel                 *labelTitle;
@property (nonatomic, strong) IBOutlet  UINavigationBar         *navigationBarCancel;
@property (strong, nonatomic) IBOutlet  UIWebView               *webView;
@property (strong, nonatomic) IBOutlet  UIToolbar               *toolbarBrowser;
@property (strong, nonatomic) IBOutlet  UIActivityIndicatorView *loadingActivity;

@property (nonatomic) BrowserViewControllerCurrentType          type;

- (void)setFrameForType:(BrowserViewControllerCurrentType)type animated:(BOOL)animated;

- (IBAction)doReload:(id)sender;
- (IBAction)doCancel:(id)sender;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)goAction:(id)sender;
- (IBAction)goBookmark:(id)sender;

- (void)loadURL:(NSURL *)url;

@end


@implementation BrowserViewController

@synthesize searchBar           = _searchBar;
@synthesize textFieldAddress    = _textFieldAddress;
@synthesize labelTitle          = _labelTitle;
@synthesize navigationBarCancel = _navigationBarCancel;
@synthesize type                = _type;
@synthesize buttonReload        = _buttonReload;
@synthesize webView             = _webView;
@synthesize toolbarBrowser      = _toolbarBrowser;
@synthesize loadingActivity     = _loadingActivity;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFrameForType:BrowserViewControllerCurrentTypeNormal animated:NO];
    
    [_searchBar removeBackground];
    
    [self loadURL:[NSURL URLWithString:@"http://mp3skull.com"]];
    
    for (UIView *subview in _navigationBarCancel.subviews) {
        if (CGRectEqualToRect(subview.frame, _navigationBarCancel.bounds) || (subview.frame.size.width == 1.0f)) {
            subview.alpha = 0.0f;
            subview.hidden = YES;
        }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.searchBar = nil;
    self.textFieldAddress = nil;
    self.labelTitle = nil;
    self.navigationBarCancel = nil;
    self.buttonReload = nil;
    self.webView = nil;
    self.toolbarBrowser = nil;
    self.loadingActivity = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Actions

- (IBAction)doReload:(id)sender {
}

- (IBAction)doCancel:(id)sender {
    [_textFieldAddress resignFirstResponder];
    [_searchBar resignFirstResponder];
    
    [self setFrameForType:BrowserViewControllerCurrentTypeNormal animated:YES];
}

#pragma mark - Do Action

- (IBAction)goBack:(id)sender {
    [_webView goBack];
}

- (IBAction)goForward:(id)sender {
    [_webView goForward];
}

- (IBAction)goAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[_webView.request.URL relativeString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"RIP all mp3", @"Add bookmark", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    [actionSheet showFromToolbar:_toolbarBrowser];
}

- (IBAction)goBookmark:(id)sender {
    ViewBookmarkViewController * viewBookmarkViewController = [[ViewBookmarkViewController alloc] initWithStyle:UITableViewStyleGrouped];
    viewBookmarkViewController.delegate = self;
    [viewBookmarkViewController setBookmark:[_webView stringByEvaluatingJavaScriptFromString:@"document.title"]
                                        url:_webView.request.URL];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewBookmarkViewController];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - Set Frame For Top

- (void)setFrameForType:(BrowserViewControllerCurrentType)type animated:(BOOL)animated {
    _type = type;
    
    float paddingLeft = 5.0f;
    float searchBarWidthNormal = 86.0f;
    
    if (type == BrowserViewControllerCurrentTypeNormal) {
        //Normal
        void (^blockSetFrame)() = ^() {
            [_searchBar setFrameSizeWidth:searchBarWidthNormal];
            [_searchBar setFrameOriginX:self.view.bounds.size.width - _searchBar.bounds.size.width];
            [_navigationBarCancel setFrameOriginX:self.view.bounds.size.width];
            
            [_textFieldAddress setFrameOriginX:paddingLeft];
            [_textFieldAddress setFrameSizeWidth:self.view.bounds.size.width - _searchBar.bounds.size.width - (paddingLeft *2)];
            [_buttonReload setFrameOriginX:CGRectGetMaxX(_textFieldAddress.frame) - _buttonReload.bounds.size.width - 5.0f];
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
                _searchBar.alpha = 1.0f;
                _textFieldAddress.alpha = 1.0f;
                blockSetFrame();
            } completion:^(BOOL finished) {
            }];
        } else {
            blockSetFrame();
        }
        
    } else if(type == BrowserViewControllerCurrentTypeAddress) {
        //Enter address
        void (^blockSetFrame)() = ^() {
            [_navigationBarCancel setFrameOriginX:self.view.bounds.size.width - _navigationBarCancel.bounds.size.width];
            [_textFieldAddress setFrameSizeWidth:self.view.bounds.size.width - _navigationBarCancel.bounds.size.width - paddingLeft];
            [_buttonReload setFrameOriginX:CGRectGetMaxX(_textFieldAddress.frame) - _buttonReload.bounds.size.width - 5.0f];
        };
        if (animated) {
            [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
                _searchBar.alpha = 0.0f;
                blockSetFrame();
            } completion:^(BOOL finished) {
            }];
        } else {
            blockSetFrame();
        }
    } else {
        //Enter search
        void (^blockSetFrame)() = ^() {
            [_searchBar setFrameSizeWidth:self.view.bounds.size.width - _navigationBarCancel.bounds.size.width - paddingLeft];
            [_searchBar setFrameOriginX:paddingLeft];
            [_navigationBarCancel setFrameOriginX:self.view.bounds.size.width - _navigationBarCancel.bounds.size.width];
            [_textFieldAddress setFrameOriginX: -self.view.bounds.size.width];
            [_buttonReload setFrameOriginX: -_buttonReload.bounds.size.width];
        };
        
        blockSetFrame();
    }
}


#pragma mark - Stuff

- (void)loadURL:(NSURL *)url {
    if (!url) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _textFieldAddress.text = url.relativeString;
        
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    });
    
}

- (void)addBookmark {
    AddBookmarkViewController * addBookmarkViewController = [[AddBookmarkViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [addBookmarkViewController setBookmark:[_webView stringByEvaluatingJavaScriptFromString:@"document.title"]
                                       url:_webView.request.URL];
    addBookmarkViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addBookmarkViewController];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:navController animated:YES];
}


#pragma mark - Bookmark delegates

- (void)openThisURL:(NSURL *)url {
    [self loadURL:url];
}


- (void)dismissViewBookmMarkViewController:(ViewBookmarkViewController *)viewController {
    [viewController dismissModalViewControllerAnimated:YES];
}


#pragma mark - Add Bookmark Delegate

- (void)dismissAddBookmMarkViewController:(AddBookmarkViewController *)viewController {
    [viewController dismissModalViewControllerAnimated:YES];
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] scheme] isEqual:@"http"] &&  [[[request URL] pathExtension] isEqualToString:@"mp3"]) {
        DLog(@"mp3");
        return NO;
    }
    
   // DLog(@"%@", [[request URL] relativeString]);
    if (_loadingActivity.isHidden) {
        [_loadingActivity startAnimating];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_loadingActivity stopAnimating];    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_loadingActivity stopAnimating];
}


#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self addBookmark];
    } else if (buttonIndex == 0) {
        NSString *html = [_webView stringByEvaluatingJavaScriptFromString: 
                          @"document.body.innerHTML"];
        
        RipViewController *ripController = [[RipViewController alloc] initWithNibName:@"RipViewController" bundle:nil andHtmlContent:html];
        [self presentModalViewController:ripController animated:YES];
    }
    
}


#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setFrameForType:BrowserViewControllerCurrentTypeAddress animated:YES];    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loadURL:[NSURL URLWithString:_textFieldAddress.text]];
    
    [_textFieldAddress resignFirstResponder];
    
    return YES;
}

#pragma mark - UISearchBar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;  
}  


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self setFrameForType:BrowserViewControllerCurrentTypeSearch animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self loadURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.google.com/search?q=%@", _searchBar.text] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [_searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
}


@end
