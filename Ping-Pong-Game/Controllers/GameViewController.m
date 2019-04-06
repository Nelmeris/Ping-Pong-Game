//
//  GameViewController.m
//  Ping-Pong-Game
//
//  Created by Artem Kufaev on 10/03/2019.
//  Copyright © 2019 Artem Kufaev. All rights reserved.
//

#import "GameViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define HALF_SCREEN_WIDTH SCREEN_WIDTH / 2
#define HALF_SCREEN_HEIGHT SCREEN_HEIGHT / 2
#define MAX_SCORE 6

#define MIN_AI_SPEED 3
#define MAX_AI_SPEED 15

#define MIN_BALL_SPEED 3
#define MAX_BALL_SPEED 10

@interface GameViewController ()

@property (strong, nonatomic) UIImageView *paddleTop;
@property (strong, nonatomic) UIImageView *paddleBottom;
@property (strong, nonatomic) UIView *gridView;
@property (strong, nonatomic) UIView *ball;
@property (strong, nonatomic) UITouch *topTouch;
@property (strong, nonatomic) UITouch *bottomTouch;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) float dx;
@property (nonatomic) float dy;
@property (nonatomic) float ballSpeed;
@property (nonatomic) float iSpeed;
@property (nonatomic) float oldISpeed;
@property (nonatomic) float newISpeed;
@property (strong, nonatomic) UILabel *scoreTop;
@property (strong, nonatomic) UILabel *scoreBottom;
@property (nonatomic) CGPoint paddleTopOldPosition;
@property (nonatomic) CGPoint paddleBottomOldPosition;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureController];
    [self configureGrid];
    [self configurePaddleTop];
    [self configurePaddleBottom];
    [self configureBall];
    [self configureScoreTop];
    [self configureScoreBottom];
}

- (void)newGame {
    [self reset];
    
    _scoreTop.text = @"0";
    _scoreBottom.text = @"0";
    
    [self displayMessage:@"Готовы к игре?"];
}

- (int)gameOver {
    if ([_scoreTop.text intValue] >= MAX_SCORE) return 1;
    if ([_scoreBottom.text intValue] >= MAX_SCORE) return 2;
    return 0;
}

- (void)start {
    _ball.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES];
    }
    _ball.hidden = NO;
}

- (void)reset {
    if ((arc4random() % 2) == 0) {
        _dx = -1;
    } else {
        _dx = 1;
    }
    
    if (_dy != 0) {
        _dy = -_dy;
    } else if ((arc4random() % 2) == 0) {
        _dy = -1;
    } else {
        _dy = 1;
    }
    
    _ball.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);
    
    _ballSpeed = MIN_BALL_SPEED;
    _paddleTopOldPosition = _paddleTop.center;
    _paddleBottomOldPosition = _paddleBottom.center;
    _iSpeed = fabs(cos(_ball.center.x));
    _newISpeed = _iSpeed;
    _oldISpeed = _iSpeed;
}

- (void)stop {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _ball.hidden = YES;
}

- (void)animate {
    _ball.center = CGPointMake(_ball.center.x + _dx * _ballSpeed, _ball.center.y + _dy * _ballSpeed);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"SSS"];
    long milliseconds = [[formatter stringFromDate:_timer.fireDate] integerValue];
    if (milliseconds / 100 == 0) {
        _oldISpeed = _iSpeed;
        _newISpeed = fabs(cos(_ball.center.x));
    }
    _iSpeed += (_newISpeed - _oldISpeed) / 60;
    int scalar = (_ball.center.x - _paddleTop.center.x) / fabs(_ball.center.x - _paddleTop.center.x);
    float newPosition = _paddleTop.center.x + MIN(fabs(_ball.center.x - _paddleTop.center.x) / 25 * _iSpeed, MAX_AI_SPEED) * scalar;
    _paddleTop.center = CGPointMake(newPosition, _paddleTop.center.y);
    
    [self checkCollision:CGRectMake(0, 0, 20, SCREEN_HEIGHT) X:fabs(_dx) Y:0];
    [self checkCollision:CGRectMake(SCREEN_WIDTH, 0, 20, SCREEN_HEIGHT) X:-fabs(_dx) Y:0];
    if ([self checkCollision:_paddleTop.frame X:(_ball.center.x - _paddleTop.center.x) / 32.0 Y:1] ||
        [self checkCollision:_paddleBottom.frame X:(_ball.center.x - _paddleBottom.center.x) / 32.0 Y:-1]) {
        [self increaseSpeed];
    }
    if (milliseconds / 5 == 0) {
        _paddleTopOldPosition = _paddleTop.center;
        _paddleBottomOldPosition = _paddleBottom.center;
    }
    [self goal];
}

- (void)increaseSpeed {
    float paddleSpeed;
    if (_dy > 0) {
        paddleSpeed = sqrtf(powf(_paddleTop.center.x - _paddleTopOldPosition.x, 2) + powf(_paddleTop.center.y - _paddleTopOldPosition.y, 2)) / 30;
    } else {
        paddleSpeed = sqrtf(powf(_paddleBottom.center.x - _paddleBottomOldPosition.x, 2) + powf(_paddleBottom.center.y - _paddleBottomOldPosition.y, 2)) / 30;
    }
    
    _ballSpeed = MAX(MIN(paddleSpeed, MAX_BALL_SPEED), MIN_BALL_SPEED);
}

- (BOOL)checkCollision: (CGRect)rect X:(float)x Y:(float)y {
    if (CGRectIntersectsRect(_ball.frame, rect)) {
        if (x != 0) _dx = x;
        if (y != 0) _dy = y;
        return YES;
    }
    return NO;
}

- (BOOL)goal {
    if (_ball.center.y < 0 || _ball.center.y >= SCREEN_HEIGHT) {
        int s1 = [_scoreTop.text intValue];
        int s2 = [_scoreBottom.text intValue];
        
        if (_ball.center.y < 0) ++s2; else ++s1;
        _scoreTop.text = [NSString stringWithFormat:@"%u", s1];
        _scoreBottom.text = [NSString stringWithFormat:@"%u", s2];
        
        int gameOver = [self gameOver];
        if (gameOver) {
            [self displayMessage:[NSString stringWithFormat:@"Вы %@", (gameOver % 2 == 0) ? @"выиграли!" : @"проиграли!"]];
        } else {
            [self reset];
        }
        
        return YES;
    }
    return NO;
}

- (void)displayMessage:(NSString *)message {
    [self stop];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ping Pong" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if ([self gameOver]) {
            [self newGame];
            return;
        }
        [self reset];
        [self start];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        if (_bottomTouch == nil && point.y > HALF_SCREEN_HEIGHT) {
            _bottomTouch = touch;
            _paddleBottom.center = CGPointMake(point.x, point.y);
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        if (touch == _bottomTouch) {
            if (point.y < HALF_SCREEN_HEIGHT) {
                _paddleBottom.center = CGPointMake(point.x, HALF_SCREEN_HEIGHT);
                return;
            }
            _paddleBottom.center = point;
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (touch == _bottomTouch) {
            _bottomTouch = nil;
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - View stats

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    [self newGame];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self resignFirstResponder];
}

#pragma mark - Configures

- (void)configureController {
    [self.view setBackgroundColor:[UIColor colorWithRed:100.0/255.0 green:135.0/255.0 blue:191.0/255.0 alpha:1.0]];
}

- (void)configureGrid {
    _gridView = [[UIView alloc] initWithFrame:CGRectMake(0, HALF_SCREEN_HEIGHT - 2, SCREEN_WIDTH, 4)];
    _gridView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_gridView];
}

- (void)configurePaddleTop {
    _paddleTop = [[UIImageView alloc] initWithFrame:CGRectMake(30, 40, 90, 60)];
    _paddleTop.image = [UIImage imageNamed:@"paddleTop"];
    _paddleTop.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_paddleTop];
}

- (void)configurePaddleBottom {
    _paddleBottom = [[UIImageView alloc] initWithFrame:CGRectMake(30, SCREEN_HEIGHT - 90, 90, 60)];
    _paddleBottom.image = [UIImage imageNamed:@"paddleBottom"];
    _paddleBottom.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_paddleBottom];
}

- (void)configureBall {
    _ball = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 10, self.view.center.y - 10, 20, 20)];
    _ball.backgroundColor = [UIColor whiteColor];
    _ball.layer.cornerRadius = 10;
    _ball.hidden = YES;
    [self.view addSubview:_ball];
}

- (void)configureScoreTop {
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

- (void)configureScoreBottom {
    _scoreBottom = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, HALF_SCREEN_HEIGHT + 70, 50, 50)];
    _scoreBottom.textColor = [UIColor whiteColor];
    _scoreBottom.text = @"0";
    _scoreBottom.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightLight];
    _scoreBottom.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_scoreBottom];
}

@end
