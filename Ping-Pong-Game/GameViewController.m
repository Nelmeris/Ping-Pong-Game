//
//  ViewController.m
//  Ping-Pong-Game
//
//  Created by Artem Kufaev on 10/03/2019.
//  Copyright © 2019 Artem Kufaev. All rights reserved.
//

#import "GameViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define HALF_SCREEN_WIDTH SCREEN_WIDTH/2
#define HALF_SCREEN_HEIGHT SCREEN_HEIGHT/2
#define MAX_SCORE 6

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewConfiguration];
    [self gridConfiguration];
    [self paddleTopConfiguration];
    [self paddleBottomConfiguration];
    [self ballConfiguration];
    [self scoreTopConfiguration];
    [self scoreBottomConfiguration];
}

- (void)viewConfiguration {
    self.view.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:135.0/255.0 blue:191.0/255.0 alpha:1.0];
}

- (void)gridConfiguration {
    _gridView = [[UIView alloc] initWithFrame:CGRectMake(0, HALF_SCREEN_HEIGHT - 2, SCREEN_WIDTH, 4)];
    _gridView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_gridView];
}

- (void)paddleTopConfiguration {
    _paddleTop = [[UIImageView alloc] initWithFrame:CGRectMake(30, 40, 90, 60)];
    _paddleTop.image = [UIImage imageNamed:@"paddleTop"];
    _paddleTop.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_paddleTop];
}

- (void)paddleBottomConfiguration {
    _paddleBottom = [[UIImageView alloc] initWithFrame:CGRectMake(30, SCREEN_HEIGHT - 90, 90, 60)];
    _paddleBottom.image = [UIImage imageNamed:@"paddleBottom"];
    _paddleBottom.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_paddleBottom];
}

- (void)ballConfiguration {
    _ball = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 10, self.view.center.y - 10, 20, 20)];
    _ball.backgroundColor = [UIColor whiteColor];
    _ball.layer.cornerRadius = 10;
    _ball.hidden = YES;
    [self.view addSubview:_ball];
}

- (void)scoreTopConfiguration {
    _scoreTop = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, HALF_SCREEN_HEIGHT - 70, 50, 50)];
    _scoreTop.textColor = [UIColor whiteColor];
    _scoreTop.text = @"0";
    _scoreTop.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightLight];
    
    CGRect frame = _scoreTop.frame;
    frame.origin.y -= _scoreTop.font.lineHeight;
    _scoreTop.frame = frame;
    
    _scoreTop.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_scoreTop];
}

- (void)scoreBottomConfiguration {
    _scoreBottom = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, HALF_SCREEN_HEIGHT + 70, 50, 50)];
    _scoreBottom.textColor = [UIColor whiteColor];
    _scoreBottom.text = @"0";
    _scoreBottom.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightLight];
    _scoreBottom.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_scoreBottom];
}


@end
