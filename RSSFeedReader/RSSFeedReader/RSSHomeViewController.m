//
//  ViewController.m
//  RSSFeedReader
//
//  Created by Dadanov Alexey on 24.12.16.
//  Copyright © 2016 Dadanov Alexey. All rights reserved.
//
//  example URL: http://images.apple.com/main/rss/hotnews/hotnews.rss

#import "RSSHomeViewController.h"
#import "RSSDetailViewController.h"

@interface RSSHomeViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSString *element;
    NSMutableArray *filteredContentList;
    BOOL isSearching;
    
    IBOutlet UISearchBar *searchBar;
}
@end

@implementation RSSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    feeds = [[NSMutableArray alloc] init];
}

- (IBAction)refreshCells:(id)sender {
    NSLog(@"refresh");
    [feeds removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - text Field

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Done");
    NSURL *url = [NSURL URLWithString:_urlTextField.text];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    [textField resignFirstResponder];

    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    NSLog(@"clear");
  
    [feeds removeAllObjects];
    [self.tableView reloadData];
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isSearching) {
        return [filteredContentList count];
    }
    return [feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    //cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];
    
    if(!isSearching) {
        cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];
    } else {
        cell.textLabel.text = [filteredContentList objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];

        [feeds addObject:[item copy]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
        [[segue destinationViewController] setUrl:string];
    }
}

#pragma mark - searchBar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.tableView resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length == 0) {
        isSearching = NO;
    } else {
        isSearching = YES;
        filteredContentList = [[NSMutableArray alloc]init];
        for (NSString *str in [feeds mutableSetValueForKey:@"title"]) {
            
            NSRange stringRange = [str rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if(stringRange.location != NSNotFound) {
                [filteredContentList addObject:str];
            }
        }
    }
    [self.tableView reloadData];
}

@end
