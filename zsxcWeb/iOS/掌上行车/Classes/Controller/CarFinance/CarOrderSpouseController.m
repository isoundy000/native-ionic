//
//  CarOrderSpouseController.m
//  掌上行车
//
//  Created by hyjt on 2017/5/8.
//
//

#import "CarOrderSpouseController.h"

@interface CarOrderSpouseController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@end

@implementation CarOrderSpouseController

static const CGFloat menuHeight = 40;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.viewModel) {
        
        self.viewModel = [[CarOrderMateViewModel alloc] init];
    }
    [self.view addSubview:self.tableView];
    //不可编辑状态
    if (_notAllowedEdit==NO) {
        
        [self _creatSubmitButton];
    }
}
-(void)_creatSubmitButton{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, kScreen_Width-40, 40)];
    [baseView addSubview:button];
    [button setTitle:@"保存配偶信息" forState:0];
    [button setTitleColor:[UIColor whiteColor] forState:0];
    [button setBackgroundImage:[UIImage imageNamed:@"bg_button"] forState:0];
    [button addTarget:self action:@selector(_submit) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = baseView;
}

/**
 提交
 */
-(void)_submit{
        [[NSNotificationCenter defaultCenter]postNotificationName:kSubmitCarOrder object:self.viewModel.mate];
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-kNavHeight-menuHeight) style:UITableViewStyleGrouped];
            table.delegate     = self;
            table.dataSource   = self;
            
            table;
        });
    }
    return _tableView;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  [self.viewModel JH_numberOfSection];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.viewModel JH_numberOfRow:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  [self.viewModel JH_heightForCell:indexPath];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self.viewModel JH_setUpTableSectionHeader:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  [self.viewModel JH_setUpTableViewCell:indexPath WithHandle:^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

@end
