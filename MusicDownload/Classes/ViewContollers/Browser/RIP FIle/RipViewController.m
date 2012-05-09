//
//  RipViewController.m
//  MusicDownload
//
//  Created by Hung Tran on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RipViewController.h"
#import "HUDView.h"

@interface RipViewController ()

@property (nonatomic, strong)               NSString        *htmlString;
@property (nonatomic, strong)               NSArray         *arrayMp3Link;

@property (nonatomic, strong) IBOutlet      UITableView     *tableView;

@property (nonatomic, strong)               HUDView         *hubView;


- (IBAction)doDownload:(id)sender;
- (IBAction)close:(id)sender;


@end


@implementation RipViewController

@synthesize htmlString  = _htmlString;
@synthesize arrayMp3Link= _arrayMp3Link;
@synthesize tableView   = _tableView;
@synthesize hubView     = _hubView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHtmlContent:(NSString *)html {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.htmlString = html;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hubView = [[HUDView alloc] initWithFrame:self.view.bounds];
    _hubView.allowUserInteractions = YES;
    [self.view addSubview:_hubView];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_hubView showWithIndicatorAndText:@"Ripping files" animated:YES];
    
    //Rip mp3
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *regexStr =  @"(<a.* href=[\"'])(.*\\.mp[34][^\"]*)[\"'](.*</a>)";
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&error];
        
        if (((regex == nil) && (error != nil)) || _htmlString == nil){
            DLog(@"Error");
        } else {
            NSMutableArray *listUrl = [NSMutableArray array];
            
            [regex enumerateMatchesInString:_htmlString 
                                    options:0 
                                      range:NSMakeRange(0, _htmlString.length) 
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                     if (result != nil){
                                         // iterate ranges
                                         
                                         for (int i = 0; i < [result numberOfRanges]; i++) {
                                             NSRange range = [result rangeAtIndex:i];
                                             DLog(@"%d,%d group #%d: %@", range.location, range.length, i, (range.length == 0 ? @"--" : [_htmlString substringWithRange:range]));
                                             if (i == 2) {
                                                 if ([[_htmlString substringWithRange:range] hasSuffix:@".mp3"]) {
                                                     [listUrl addObject:[_htmlString substringWithRange:range]];
                                                     //DLog(@"%@", [_htmlString substringWithRange:range]);
                                                 }
                                             }
                                             
                                             // Text a
                                             // Title href
                                             // Name file
                                         }
                                     } else {
                                         DLog(@"NULL");
                                     }
                
            }];
            
            self.arrayMp3Link = [NSArray arrayWithArray:listUrl];
        }
            
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [_hubView hideAnimated];
        });
    });
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.hubView = nil;
    self.tableView = nil;
    self.htmlString = nil;
    self.arrayMp3Link = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_arrayMp3Link) {
        return [_arrayMp3Link count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LabelCellIdentifier = @"cell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LabelCellIdentifier];
    }
    
    if (indexPath.row <= [_arrayMp3Link count]) {
        cell.textLabel.text = [_arrayMp3Link objectAtIndex:indexPath.row];
    }
    return cell;
}


#pragma mark - Actions

- (IBAction)doDownload:(id)sender {
    
}

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


@end
