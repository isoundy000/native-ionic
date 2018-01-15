//
//  Root_LoginController.m
//  carFinance
//
//  Created by hyjt on 2017/4/14.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "Root_LoginController.h"
#import "JPushHelper.h"
//#import "CarFinanceAppDelegate+StartAPP.h"
//#import "UUID.h"
#import "JHLeftViewTextField.h"
@interface Root_LoginController ()

@property(nonatomic,strong)JHLeftViewTextField *accountTextField;
@property(nonatomic,strong)JHLeftViewTextField *passwordTextField;
@end

/**
 登录页面（背景图、用户名、密码、登录）
 */
@implementation Root_LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackground];
    [self _creatBackButton];
    [self _creatSubView];
    
}

//增加返回按钮
-(void)_creatBackButton{
    UIButton *btn = [UIButton new];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@44);
    }];
    [btn setImage:[UIImage imageNamed:@"button_back"] forState:0];
    [btn setTitle:@"退出" forState:0];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:kBaseTextColor forState:0];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

}
-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:^{
      //statusBar
      [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
}


-(void)addBackground{
    UIImageView *imageView = [UIImageView new];
    [self.view addSubview:imageView];
    [imageView setImage:[JH_CommonInterface LoadImageFromBundle:@"bg.jpg"]];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
}
const static CGFloat edg = 40;
/**
 创建一些子视图
 */
-(void)_creatSubView{
    UIImageView *imageView = [UIImageView new];
    [self.view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"login_icon"];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(100);
        make.centerX.equalTo(self.view);
    }];
    [self.view addSubview:self.accountTextField];
    
    [self.accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(edg);
        make.right.equalTo(self.view).with.offset(-edg);
        make.height.equalTo(@40);
        make.top.equalTo(imageView.mas_bottom).with.offset(50);
    }];
    

    [self.view addSubview:self.passwordTextField];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(edg);
        make.right.equalTo(self.view).with.offset(-edg);
        make.height.equalTo(@40);
        make.top.equalTo(self.accountTextField.mas_bottom).with.offset(20);
    }];
    
    //loginButton
    UIButton *loginBtn = [UIButton new];
    [self.view addSubview:loginBtn];
    loginBtn.backgroundColor = kBaseTextColor;
    [loginBtn setTitle:@"登录" forState:0];
    [loginBtn setTitleColor:kBaseColor forState:0];
    [loginBtn addTarget:self action:@selector(_loginAction) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.cornerRadius = 5;
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).with.offset(20);
        make.left.equalTo(self.view).with.offset(edg);
        make.right.equalTo(self.view).with.offset(-edg);
        make.height.equalTo(@40);
    }];
}

/**
 login
 */
-(void)_loginAction{
    //获取输入框文字
    [self.view endEditing:YES];
    NSString *userName = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kLogin] HTTPMethod:HttpMethodPost  showHud:YES params:@{ @"uname":userName,@"upass":password} completionHandle:^(id result) {
        
        if ([result[@"code"] isEqualToString:kSuccessCode]) {
            [MBProgressHUD MBProgressShowSuccess:YES WithTitle:@"登录成功！" view:[UIApplication sharedApplication].keyWindow];
            //保存用户信息
            [JH_FileManager setObjectToUserDefault:[NSString stringWithFormat:@"%@",result[@"userinfo"][@"uid"]] ByKey:kuserId];
            [JH_FileManager setObjectToUserDefault:[NSString stringWithFormat:@"%@",result[@"key"]] ByKey:ktoken];
            //发送通知使进入
            [[NSNotificationCenter defaultCenter]postNotificationName:kSetTabbar object:nil];
            //注册极光推送
            [self _registerJPushWithUid:result[@"userinfo"][@"uid"]];
            
        }else{
            [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
        }
    } errorHandle:^(NSError *error) {

        [self setNeedsFocusUpdate];
    }];

}

-(UITextField *)accountTextField{
    if (!_accountTextField) {
        _accountTextField              = [JHLeftViewTextField new];
        _accountTextField.placeholder  = @"请输入您的账号";
        UIImageView *icon1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_icon_1"]];
        _accountTextField.leftView = icon1;
        [_accountTextField setValue:[UIColor colorWithWhite:1 alpha:0.6] forKeyPath:@"placeholderLabel.textColor"];
    }
    
    return _accountTextField;
}
-(UITextField *)passwordTextField{
    if (!_passwordTextField) {
        _passwordTextField              = [JHLeftViewTextField new];
        _passwordTextField.placeholder  = @"请输入您的密码";
        [_passwordTextField setValue:[UIColor colorWithWhite:1 alpha:0.6] forKeyPath:@"placeholderLabel.textColor"];
        _passwordTextField.secureTextEntry = YES;
        //icon2
        UIImageView *icon2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_icon_2"]];
        _passwordTextField.leftView = icon2;
    }
    return _passwordTextField;
}

/**
 登录成功后注册极光推送

 @param uId
 */
-(void)_registerJPushWithUid:(NSString *)uId{
    //设备Id
    NSString *devId = [JPushHelper _getRegistrationID];
    @try {
        NSDictionary *data = @{
                               @"device_id":devId,
                               @"user_id":uId,
                               @"app_name":@"掌上行车"
                               };
        [JH_NetWorking requestData:kJpushLogin HTTPMethod:HttpMethodGet showHud:NO params:data completionHandle:^(id result) {
            
        } errorHandle:^(NSError *error) {
            
        }];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
    
}

@end
