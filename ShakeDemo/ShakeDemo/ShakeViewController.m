//
//  ShakeViewController.m
//  ShakeDemo
//
//  Created by XQQ on 16/9/27.
//  Copyright © 2016年 xinghua. All rights reserved.
//

#import "ShakeViewController.h"
#import <AudioToolbox/AudioToolbox.h>//手机震动
#import <QuartzCore/QuartzCore.h>//图片抖动框架
#import <CoreMotion/CoreMotion.h>//手机晃动检测

//屏幕宽高
#define iphoneWidth  [[UIScreen mainScreen] bounds].size.width
#define iphoneHeight [[UIScreen mainScreen] bounds].size.height
//屏幕适配
#define WidthScale     iphoneWidth/750.0
#define HeightScale    iphoneHeight/1335.0
//RGB
#define XQQColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
@interface ShakeViewController ()
@property(nonatomic,strong)UIButton * activityBtn;
@property(nonatomic,strong)UIButton * discountBtn;
@property(nonatomic,strong)UIButton * regisBtn;
/**动画imageView*/
@property(nonatomic,strong)UIImageView * animationView;
/**背景*/
@property(nonatomic,strong)UIImageView * backImageView;
/**摇动结束弹出的View*/
@property(nonatomic,strong)UIView       * alertView;
/**装按钮的数组*/
@property(nonatomic, strong)  NSMutableArray  *  buttonArr;
@end

@implementation ShakeViewController
{
    SystemSoundID  soundID; //自定义开始音乐
    SystemSoundID showSound;//结束音效
    NSTimer * _timer;
    CMMotionManager * _shake;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //UI
    [self initUI];
    //摇动相关
    [self setUpShake];
}
#pragma mark - 摇动的回调方法
- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_alertView) {
        [_alertView removeFromSuperview];
    }
    NSLog(@"检测到摇动");
    //禁止点击按钮
    [self buttonShouldSelected:NO];
    //开启定时器
    [_timer setFireDate:[NSDate distantPast]];
    //播放音效
    [self playSoundWithSound:soundID event:event];
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"摇动取消");
    //禁止点击按钮
    [self buttonShouldSelected:NO];
    //停止定时器
    [_timer setFireDate:[NSDate distantFuture]];

}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //摇动结束
    NSLog(@"摇动结束");
    //关闭计时器
    [_timer setFireDate:[NSDate distantFuture]];
    //回到开始的位置
    _animationView.frame = CGRectMake(175 * WidthScale, 400 * HeightScale, 400 * WidthScale,400 * HeightScale);
    //显示提示的View
    UIButton * endBtn = nil;
    for (UIButton * button in self.buttonArr) {
        if (button.isSelected) {
            endBtn = button;
        }
    }
    //延迟两秒添加提示的View
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        //把选中的按钮传递过去
        [self showAlertViewWithButton:endBtn];
        //播放音效
        [self playSoundWithSound:showSound event:event];
    });
}

#pragma mark - 添加提示的View
- (void)showAlertViewWithButton:(UIButton*)button{
    if (_alertView) {
        [_alertView removeFromSuperview];
    }
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iphoneWidth, 300)];
    _alertView.center = _animationView.center;
    _alertView.backgroundColor = [UIColor grayColor];
    //添加手势，点击屏幕当前的_alertImagview消失
    UITapGestureRecognizer * sigleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sigleTap)];
    [_alertView addGestureRecognizer:sigleTap];
    switch (button.tag - 50) {
        case 0:{//活动
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _alertView.frame.size.width, _alertView.frame.size.height)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = @"抱歉，暂时没有活动敬请期待";
            [_alertView addSubview:label];
        }
            break;
        case 1:{//优惠
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _alertView.frame.size.width, _alertView.frame.size.height)];
            imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"coupon_bg" ofType:@"png"]];
            [_alertView addSubview:imageView];
        }
            break;
        case 2:{//签到
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _alertView.frame.size.width, _alertView.frame.size.height)];
            label.numberOfLines = 0;
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"您无需再签名";
            [_alertView addSubview:label];
        }
            break;
        default:
            break;
    }
    UIWindow * window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:_alertView];
}

/**动画*/
- (void)updateAcc{
    // 修改image的初始位置
    static int speedX = 20;
    // 获取当前位置
    CGRect frame = _animationView.frame;
    frame.origin.x += speedX;
    // image的frame重新赋值
    _animationView.frame = frame;
    if (_animationView.frame.origin.x > 600 * WidthScale - _animationView.frame.size.width || _animationView.frame.origin.x < 150 * WidthScale) {
        speedX *= -1;
    }
}

/**设置按钮是否可选*/
- (void)buttonShouldSelected:(BOOL)shouldSelect{
    for (UIButton * button in self.buttonArr) {
        button.userInteractionEnabled = shouldSelect;
    }
}

#pragma mark - activity
- (void)bottomDidSel:(UIButton*)button{
    //设置所有的按钮为非选中状态
    for (UIButton * button in self.buttonArr) {
        button.selected = NO;
    }
    //设置当前点击的按钮为选中状态
     button.selected = !button.isSelected;
}
//点击了提示的View 退出提示的View
- (void)sigleTap{
    [UIView animateWithDuration:1.f animations:^{
        [_alertView removeFromSuperview];
    } completion:^(BOOL finished) {
        //设置按钮可点
        [self buttonShouldSelected:YES];
    }];
}
#pragma mark - setter&getter
- (void)setUpShake{
    //1.很简单，你只需要让这个Controller本身支持摇动
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    //2.同时让他成为第一相应者
    [self becomeFirstResponder];
    //3.自定义摇一摇音乐
    //找到音频文件的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shake"ofType:@"wav"];
    //根据音频文件自定义音乐
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    //摇一摇结果的音效
    NSString * showsound = [[NSBundle mainBundle]pathForResource:@"show" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:showsound], &showSound);
   
}

/**UI*/
- (void)initUI{
    //背景
    //1.背景图片视图
    _backImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    _backImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"app_bg" ofType:@"jpg"]];
    _backImageView.contentMode = UIViewContentModeScaleToFill;
    [_backImageView setUserInteractionEnabled:YES];
    [self.view addSubview:_backImageView];
    //2.下方的三个button(摇活动 优惠 签到)
    NSArray * picArr = @[@"active_white",@"Discount_white",@"sign_white"];
    NSArray * selectArr = @[@"active_red",@"Discount_red",@"Sign_red"];
    NSArray * buttonArr = @[@"摇活动",@"摇优惠",@"摇签到"];
    for (int i = 0; i < picArr.count; i++) {
        UIButton * bottomBtn = [[UIButton alloc]initWithFrame:CGRectMake((70 + 230 * i )* WidthScale ,1037 * HeightScale, 150 * WidthScale, 150 * HeightScale)];
        [bottomBtn setImage:[UIImage imageNamed:picArr[i]] forState:UIControlStateNormal];
        [bottomBtn setImage:[UIImage imageNamed:selectArr[i]] forState:UIControlStateSelected];
        bottomBtn.tag = 50 + i;
        [bottomBtn addTarget:self action:@selector(bottomDidSel:) forControlEvents:UIControlEventTouchUpInside];
        [bottomBtn setTitle:buttonArr[i] forState:UIControlStateNormal];
        [bottomBtn setTitle:buttonArr[i] forState:UIControlStateSelected];
        [bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bottomBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        bottomBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, bottomBtn.titleLabel.bounds.size.width);
        bottomBtn.titleEdgeInsets = UIEdgeInsetsMake(bottomBtn.imageView.bounds.size.height + 30, - bottomBtn.imageView.bounds.size.width - bottomBtn.titleLabel.bounds.size.width, 0, 0);
        [self.buttonArr addObject:bottomBtn];
        [_backImageView addSubview:bottomBtn];
        if (i == 0) {
            _activityBtn = bottomBtn;
            bottomBtn.selected = YES;
        }else if (i == 1){
            _discountBtn = bottomBtn;
        }else if (i == 2){
            _regisBtn = bottomBtn;
        }
    }
    //3.创建背景的动画View
    _animationView = [[UIImageView alloc]initWithFrame:CGRectMake(175 * WidthScale, 400 * HeightScale, 400 * WidthScale,400 * HeightScale)];
    _animationView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"yaoyiyao" ofType:@"png"]];;
    [_backImageView addSubview:_animationView];
    
    
    //添加一个计时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateAcc) userInfo:nil repeats:YES];
    //暂停
    [_timer setFireDate:[NSDate distantFuture]];
}
/**播放音效*/
- (void)playSoundWithSound:(SystemSoundID)sound event:(UIEvent*)event{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if (event.subtype == UIEventSubtypeMotionShake) {
        //启动摇晃
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //播放声音
        AudioServicesPlaySystemSound (sound);
    }
}
- (NSMutableArray *)buttonArr{
    if (!_buttonArr) {
        _buttonArr = @[].mutableCopy;
    }
    return _buttonArr;
}

- (void)dealloc {
    if (_timer != nil) {
        // 如果定时器不为空，即已经被创建，则停止该定时器，停止即销毁
        [_timer invalidate];
    }
}
@end
