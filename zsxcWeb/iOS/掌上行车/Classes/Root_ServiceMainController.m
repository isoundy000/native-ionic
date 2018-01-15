//
//  Root_ServiceMainController.m
//  掌上行车
//
//  Created by hyjt on 2017/5/12.
//
//

#import "Root_ServiceMainController.h"
#import "Root_ServiceCell.h"
#import "JH_UIWebView.h"
#import "JH_RuntimeTool.h"
#import "ServiceSpaceController.h"
#import <IQKeyboardManager.h>
@interface Root_ServiceMainController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation Root_ServiceMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务导航";

    //statusBar
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self _creatBackButton];
    [self _setUpAppearance];
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

//增加返回按钮
-(void)_creatBackButton{

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:0 target:self action:@selector(dismiss)];
    
}

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:^{
        //statusBar
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
}
#pragma mark - setUp
-(void)_setUpAppearance{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = YES;
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(kScreen_Width, 0)
                                                         forBarMetrics:UIBarMetricsDefault];
    //  NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName: kBaseTextColor};
    //  [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    //  [[UINavigationBar appearance] setTintColor:kBaseTextColor];
    //  [[UINavigationBar appearance] setBarTintColor: kBaseColor];
    //
    //  [[UITextField appearance] setTintColor:kBaseColor];
    
}
-(UITableView *)tableView{
    if (_tableView==nil) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}
-(NSArray *)imageData{
    
    return @[@"4@2x.png",@"service1.jpg",@"service2.jpg",@"service3.jpg"];
}
-(NSArray *)vcTitles{
    return @[@"车贷计算器",@"二手车质保",@"个人征信查询",@"二手车鉴定"];
}

#pragma mark - tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self imageData].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    Root_ServiceCell *cell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([Root_ServiceCell class]) owner:self options:nil]firstObject];
    
    cell.imgBaseImageView.image = [JH_CommonInterface LoadImageFromBundle:[self imageData][indexPath.item]];
    
    return cell;
}

#pragma mark - tableViewDataDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.view.bounds.size.width-20)*145/345;
}

#pragma mark - 选中事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        [JH_RuntimeTool runtimePush:@"SVCalculatePriceController" dic:nil nav:self.navigationController];
    }else if (indexPath.row == 1){
        JH_UIWebView *web = [[JH_UIWebView alloc] init];
        web.urlString = @"http://zb.bcbx999.com/";
        web.webTitle = [self vcTitles][indexPath.item];
        [self _pushViewController:web];
    }else{
        ServiceSpaceController *space = [[ServiceSpaceController alloc]init];
        space.vcTitle = [self vcTitles][indexPath.item];
        [self _pushViewController:space];
    }
}


@end
