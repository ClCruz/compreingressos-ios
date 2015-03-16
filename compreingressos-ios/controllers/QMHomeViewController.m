//
//  QMHomeViewController.m
//  compreingressos-ios
//
//  Created by Robinson Nakamura on 3/16/15.
//  Copyright (c) 2015 QPRO Mobile. All rights reserved.
//

#import "QMHomeViewController.h"
#import "QMGenreCell.h"
#import "QMWebViewController.h"

static NSString *const kCompreIngressosURL = @"http://www.compreingressos.com/espetaculos";
static NSDictionary *kIconsForGenres;
NSArray *kGenres;

@interface QMHomeViewController ()

@end

@implementation QMHomeViewController {
    
    IBOutlet UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    kIconsForGenres = @{
                       @"Perto de Mim": @"png",
                       @"Comédia": @"comedia.png",
                       @"Show": @"show.png"
    };
    kGenres = [kIconsForGenres allKeys];
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QMWebViewController *controller = segue.destinationViewController;
    [controller setUrl:kCompreIngressosURL];
    NSString *genre = sender;
    [controller setTitle:genre];
    [self configureNextViewBackButtonWithTitle:@"Voltar"];
    [super prepareForSegue:segue sender:sender];
}

- (void)configureNextViewBackButtonWithTitle:(NSString *)title {
    UIBarButtonItem *nextViewBackButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:nil
                                                                          action:nil];
    [self.navigationItem setBackBarButtonItem:nextViewBackButton];
}

#pragma mark -
#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [kGenres count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMGenreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMGenreCell" forIndexPath:indexPath];
    NSString *genre = kGenres[indexPath.row];
    [cell.titleLabel setText:genre];
    NSLog(genre);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *genre = kGenres[indexPath.row];
    [self performSegueWithIdentifier:@"webviewSegue" sender:genre];
}

@end
