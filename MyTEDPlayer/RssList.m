//
//  RssList.m
//  MyTEDPlayer
//
//  Created by Ben G on 25.04.15.
//  Copyright (c) 2015 beng. All rights reserved.
//

#import "RssList.h"
#import "RssListCell.h"
#import "ViewController.h"
#import "RSSParser.h"
#import "UIImageView+AFNetworking.h"
#import <AVKit/AVKit.h>

@interface RssList ()

@property NSOperationQueue *queue;
@property (strong, nonatomic) NSArray *objects;
@property NSArray *categories;
@property (weak, nonatomic) IBOutlet UIButton *selectToShow;

@end

@implementation RssList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [[NSOperationQueue alloc] init];
    _objects = _data;
    [self configureView];
    
}

- (void)configureView {
    //заголовок
    self.navigationItem.title = @"TED Talks";
    //формируем список категорий
    NSMutableSet *allCategories = [NSMutableSet new];
    for (RSSItem *item in _data) {
        [allCategories addObject:item.category];
    }
    _categories = [allCategories allObjects];
    _categories = [_categories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureImageForItem:(RSSItem*)rssItem {
    rssItem.posterImage = [self imageWithUrl:rssItem.link];
}

- (UIImage *)imageWithUrl:(NSURL*)url {
    
    UIImage* thumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:url] scale:0.1];
    return thumb;
}

- (void)loadImageWithParams:(NSDictionary*)params
{
    //show activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    UIImage* thumb = [self imageWithUrl:[params objectForKey:@"url"]];
    //создаем словарь параметров
    NSDictionary *backParams = [NSDictionary dictionaryWithObjectsAndKeys:[params objectForKey:@"cell"], @"cell", thumb, @"thumb", [params objectForKey:@"indexPath"], @"indexPath", nil];
    //тут передаём его
    [self performSelectorOnMainThread:@selector(setImage:) withObject:backParams waitUntilDone:YES];
}

//устанавливаем картинку
-(void)setImage:(NSDictionary*)params {
    
    RssListCell *cell = [params objectForKey:@"cell"];
    NSIndexPath *indexPath = [params objectForKey:@"indexPath"];
    UIImage *thumb = [params objectForKey:@"thumb"];
    [cell.poster setImage:thumb]; // устанавливаем картинку
    RSSItem *item = [_objects objectAtIndex:indexPath.row];
    item.posterImage = thumb;
    
    //анимация появления картинки
    cell.viewForPoster.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cell.viewForPoster.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished) {}];
    //hide activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)selectToShow:(UIButton*)sender {
    //просмотр фидов по категориям
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Show Category", @"Show (Title)")
                                          message:@"(Если лист содержит больше одной категории, можно выбрать и проматривать одну из них)"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    alertController.view.tintColor = [UIColor redColor];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"All Talks", @"Show all Talks action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   _objects = _data;
                                   [self.tableView reloadData];
                                   self.navigationItem.title = NSLocalizedString(@"TED Talks", nil);
                                   [_selectToShow setTitle:NSLocalizedString(@"TED Talks", nil) forState:UIControlStateNormal];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    if (_categories.count != 0) {
        for (NSString *category in _categories) {
            UIAlertAction *action = [UIAlertAction
                                     actionWithTitle:category
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         _objects = [self arrayForCategory:category];
                                         [self.tableView reloadData];
                                         self.navigationItem.title = category;
                                         [_selectToShow setTitle:category forState:UIControlStateNormal];
                                     }];
            [alertController addAction:action];
        }
    }
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = sender;
        popover.sourceRect = sender.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSArray *)arrayForCategory:(NSString*)category {
    //формируем список категорий
    NSMutableArray *itemsForCategory = [NSMutableArray new];
    for (RSSItem *item in _data) {
        if ([item.category isEqualToString:category]) {
            [itemsForCategory addObject:item];
        }
    }
    NSArray *arrayForCategory = [NSArray arrayWithArray:itemsForCategory];
    
    return arrayForCategory;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RssListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    RSSItem *item = [self.data objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatDate = [NSDateFormatter new];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //более подробный стиль даты
        [formatDate setTimeStyle:NSDateFormatterMediumStyle];
        [formatDate setDateStyle:NSDateFormatterFullStyle];
        cell.title.text = item.title;
    }
    else {
        // In this case the device is an iPhone/iPod Touch.
        //стиль даты короче
        [formatDate setTimeStyle:NSDateFormatterShortStyle];
        [formatDate setDateStyle:NSDateFormatterLongStyle];
        //заголовок короче
        //удаляем имя автора из заголовка
        NSString *authorPrefix = [NSString stringWithFormat:@"%@: ",
                                  [item.author stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        if ([item.title hasPrefix:authorPrefix]) {
            cell.title.text = [item.title substringFromIndex:authorPrefix.length];
        } else {
            cell.title.text = item.title;
        }
    }
    cell.descriptionLabel.text = item.itemDescription;
    cell.dateLabel.text = [formatDate stringFromDate:item.pubDate];
    if (item.posterImage) {
        //если картинка уже загружена, используем её
        cell.poster.image = item.posterImage;
    } else {
        cell.poster.image = nil;
        //иначе загружаем в очереди
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:item.imageUrl, @"url", cell, @"cell", indexPath, @"indexPath", nil];
        //создаём экземпляр NSOperation
        NSOperation * loadOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithParams:) object:params];
        //добавляем операцию в очередь
        [self.queue addOperation:loadOperation];
        
    }
    
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass URL to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RSSItem *item = [self.data objectAtIndex:indexPath.row];
    [[segue destinationViewController] setLink:item.link];
}


@end
