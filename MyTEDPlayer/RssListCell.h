//
//  RssListCell.h
//  MyTEDPlayer
//
//  Created by Ben G on 25.04.15.
//  Copyright (c) 2015 beng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundView.h"

@interface RssListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *poster;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet RoundView *viewForPoster;

@end
