//
//  RSSDetailViewController.h
//  RSSFeedReader
//
//  Created by Dadanov Alexey on 24.12.16.
//  Copyright © 2016 Dadanov Alexey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *url;

@end
