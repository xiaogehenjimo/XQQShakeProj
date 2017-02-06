//
//  ViewController.m
//  ShakeDemo
//
//  Created by 陈兴华 on 16/9/26.
//  Copyright © 2016年 xinghua. All rights reserved.
//

#import "ViewController.h"
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
#define CDColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]



@interface ViewController ()
{
    SystemSoundID  soundID; //自定义开始音乐
    
    SystemSoundID showSound;//结束音效
    NSTimer * _timer;
    CMMotionManager * _shake;
}

@property(nonatomic,strong)UIButton * activityBtn;
@property(nonatomic,strong)UIButton * discountBtn;
@property(nonatomic,strong)UIButton * regisBtn;

@property(nonatomic,retain)UIImageView * animationView;
@property(nonatomic,retain)UIImageView * backImageView ;

@property(nonatomic,retain)UIImageView * alertImagview;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self becomeFirstResponder];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //导航栏 左右按钮
    [self creatNavigationBarItems];
    
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
    
    [self buildUI];
    //添加一个计时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateAcc:) userInfo:nil repeats:YES];
    //暂停
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //检测到摇动
    NSLog(@"检测到摇动");
    //禁止点击按钮
    [_activityBtn setUserInteractionEnabled:NO];
    [_discountBtn setUserInteractionEnabled:NO];
    [_regisBtn setUserInteractionEnabled:NO];
    //开启定时器
    [_timer setFireDate:[NSDate distantPast]];
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //摇动取消
    NSLog(@"摇动取消");
    //禁止点击按钮
    [_activityBtn setUserInteractionEnabled:NO];
    [_discountBtn setUserInteractionEnabled:NO];
    [_regisBtn setUserInteractionEnabled:NO];
    //停止定时器
    [_timer setFireDate:[NSDate distantFuture]];
}



- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //摇动结束
    NSLog(@"摇动结束");
    //关闭计时器
    [_timer setFireDate:[NSDate distantFuture]];
    //回到开始的位置
    _animationView.frame = CGRectMake(175 * WidthScale, 400 * HeightScale, 400 * WidthScale,400 * HeightScale);
    //摇动结束后 延迟两秒显示摇动的结果
    [self performSelector:@selector(delaytime) withObject:nil afterDelay:2.0f];
    
    //添加手势，点击屏幕当前的_alertImagview消失
    UITapGestureRecognizer * tp =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    
    [[self view] addGestureRecognizer:tp];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if (event.subtype == UIEventSubtypeMotionShake) {
        [_timer setFireDate:[NSDate distantFuture]];
        //启动摇晃
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //播放声音
        AudioServicesPlaySystemSound (soundID);
        [_alertImagview removeFromSuperview];
    }
}

- (void)delaytime {
    
    [_animationView removeFromSuperview];
    
    //播放声音(摇晃结束后)
    AudioServicesPlaySystemSound (showSound);
    
    
    _alertImagview = [[UIImageView alloc]initWithFrame:CGRectMake(30 * WidthScale, 470 * HeightScale, 690 * WidthScale, 200 * HeightScale)];
    _alertImagview.backgroundColor = CDColor(38, 41, 49);
    _alertImagview.layer.cornerRadius = 10;
    _alertImagview.layer.borderWidth = 0.5;
    
    if (_activityBtn.selected == YES) {
        
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(200 * WidthScale, 0, 290 * WidthScale, 200 * HeightScale)];
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.text = @"抱歉，暂时没有活动敬请期待";
        [_alertImagview addSubview:label];
        [_backImageView addSubview:_alertImagview];
    }
    
    if (_discountBtn.selected == YES) {
        
        _alertImagview = [[UIImageView alloc]initWithFrame:CGRectMake(30 * WidthScale, 470 * HeightScale, 690 * WidthScale, 400 * HeightScale)];
        
        _alertImagview.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"coupon_bg" ofType:@"png"]];
        
        [_backImageView addSubview:_alertImagview];
    }
    
    if (_regisBtn.selected == YES) {
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(200 * WidthScale, 0, 290 * WidthScale, 200 * HeightScale)];
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.text = @"您无需再签名";
        [_alertImagview addSubview:label];
        [_backImageView addSubview:_alertImagview];
    }
    
    //取消禁止按钮的点击
    [_activityBtn setUserInteractionEnabled:YES];
    [_discountBtn setUserInteractionEnabled:YES];
    [_regisBtn setUserInteractionEnabled:YES];
}

- (void)tap{
    
    [_alertImagview removeFromSuperview];
    [self createAnimation];
}

- (void)updateAcc:(NSTimer *)timer {
    // 修改image的初始位置
    static int speedX = 10;
    // 获取当前位置
    CGRect frame = _animationView.frame;
    frame.origin.x += speedX;
    // image的frame重新赋值
    _animationView.frame = frame;
    NSLog(@"%f %f",_animationView.frame.origin.x,_animationView.frame.origin.y);
    if (_animationView.frame.origin.x > 600 * WidthScale - _animationView.frame.size.width || _animationView.frame.origin.x < 150 * WidthScale) {
        speedX *= -1;
    }
}

- (void)createAnimation {
    
    _animationView = [[UIImageView alloc]initWithFrame:CGRectMake(175 * WidthScale, 400 * HeightScale, 400 * WidthScale,400 * HeightScale)];
    _animationView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"yaoyiyao" ofType:@"png"]];;
    [_backImageView addSubview:_animationView];
    
}


- (void)dealloc {
    if (_timer != nil) {
        // 如果定时器不为空，即已经被创建，则停止该定时器，停止即销毁
        [_timer invalidate];
    }
}

#pragma mark - 创建UI界面
- (void)buildUI {
    
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
        UIButton * imagebutton = [[UIButton alloc]initWithFrame:CGRectMake((70 + 230 * i )* WidthScale ,1037 * HeightScale, 150 * WidthScale, 150 * HeightScale)];
        
        [imagebutton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle
                                                                 ]pathForResource:picArr[i] ofType:@"png"]] forState:UIControlStateNormal];
        [imagebutton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle
                                                                 ]pathForResource:selectArr[i] ofType:@"png"]] forState:UIControlStateSelected];
        [imagebutton addTarget:self action:@selector(imageselect:) forControlEvents:UIControlEventTouchUpInside];
        imagebutton.tag = 50 + i;
        //图片下方的文字显示
        UIButton * showbutton = [[UIButton  alloc]initWithFrame:CGRectMake((80 + 230 * i )* WidthScale ,1220 * HeightScale, 130 * WidthScale, 30 * HeightScale)];
        showbutton.tag = 150 + i;
        [showbutton setTitle:buttonArr[i] forState:UIControlStateNormal];
        [showbutton setTitleColor:CDColor(222, 76, 69) forState:UIControlStateSelected];
        [showbutton addTarget:self action:@selector(showselect:) forControlEvents:UIControlEventTouchUpInside];
        [_backImageView addSubview:imagebutton];
        [_backImageView addSubview:showbutton];
        //默认选中第一个按钮
        if (showbutton.tag == 150 && imagebutton.tag == 50) {
            showbutton.selected = YES;
            imagebutton.selected = YES;
            _activityBtn = showbutton;
            
            _animationView = [[UIImageView alloc]initWithFrame:CGRectMake(175 * WidthScale, 400 * HeightScale, 400 * WidthScale,400 * HeightScale)];
            _animationView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"yaoyiyao" ofType:@"png"]];;
            [_backImageView addSubview:_animationView];
        }else if (showbutton.tag == 151 && imagebutton.tag == 51){
            
            _discountBtn = showbutton;
            
        }else if(showbutton.tag == 152 && imagebutton.tag == 52){
            
            _regisBtn = showbutton;
        }
    }
    
    
}


#pragma mark - 导航栏左右按钮
-(void)creatNavigationBarItems
{
    //自定义一个（view）放在导航栏的leftBarbuttonItem上
    UIButton *backBtn = [[UIButton alloc]init];
    [backBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [backBtn sizeToFit];
    UIBarButtonItem * leftItem  = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    //监听
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //导航栏标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"摇一摇";
    self.navigationItem.titleView = titleLabel;
    
    
}

-(void)backBtnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 点击选项，选择哪种活动摇一摇
- (void)imageselect:(UIButton *)button {
    
    UIButton *showButton1 = [self.view viewWithTag:150];
    UIButton *showButton2 = [self.view viewWithTag:151];
    UIButton *showButton3 = [self.view viewWithTag:152];
    
    _discountBtn = showButton2;
    _regisBtn = showButton3;
    for(NSInteger i = 50 ;i < 53 ; i++)
    {
        UIButton * button = [self.view viewWithTag:i];
        
        button.selected = NO;
        
        
    }
    button.selected = YES;
    
    
    if (button.tag == 50) {
        
        showButton1.selected = YES;
        
        [_alertImagview removeFromSuperview];
        [_animationView removeFromSuperview];
        _animationView = [[UIImageView alloc]initWithFrame:CGRectMake(175 * WidthScale, 400 * HeightScale, 400 * WidthScale,400 * HeightScale)];
        _animationView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"yaoyiyao" ofType:@"png"]];;
        [_backImageView addSubview:_animationView];
        
    }else{
        
        showButton1.selected = NO;
    }
    if (button.tag == 51) {
        
        showButton2.selected = YES;
        [_alertImagview removeFromSuperview];
        [_animationView removeFromSuperview];
        
        [self createAnimation];
    }else{
        
        showButton2.selected = NO;
    }
    if (button.tag == 52) {
        
        showButton3.selected = YES;
        [_alertImagview removeFromSuperview];
        [_animationView removeFromSuperview];
        
        //创建摇动的图片
        [self createAnimation];
        
    }else{
        
        showButton3.selected = NO;
    }
    
    
}

- (void)showselect:(UIButton *)button {
    
    UIButton * button1 = [self.view viewWithTag:50];
    UIButton * button2 = [self.view viewWithTag:51];
    UIButton * button3 = [self.view viewWithTag:52];
    
    for(NSInteger i = 150 ;i < 153 ; i++)
    {
        UIButton * button = [self.view viewWithTag:i];
        
        
        button.selected = NO;
        
    }
    button.selected = YES;
    
    
    if (button.tag == 150) {
        
        button1.selected = YES;
        
        
    }else{
        
        button1.selected = NO;
    }
    if (button.tag == 151) {
        
        button2.selected = YES;
        
        
    }else{
        
        button2.selected = NO;
    }
    if (button.tag == 152) {
        
        button3.selected = YES;
        
        
    }else{
        
        button3.selected = NO;
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
