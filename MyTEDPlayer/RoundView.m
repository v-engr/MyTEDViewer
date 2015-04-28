//
//  RoundView.m
//  MyTEDPlayer
//
//  Created by Ben G on 26.04.15.
//  Copyright (c) 2015 beng. All rights reserved.
//

#import "RoundView.h"

@implementation RoundView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = rect.size.height / 2.0;
    self.layer.masksToBounds = YES;
}


@end
