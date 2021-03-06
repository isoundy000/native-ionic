//
//  CarOrderAdvanceController.m
//  掌上行车
//
//  Created by hyjt on 2017/5/8.
//
//

#import "CarOrderAdvanceController.h"

@interface CarOrderAdvanceController ()

@end

@implementation CarOrderAdvanceController

static const CGFloat menuHeight = 40;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.viewModel) {
        
        self.viewModel = [[CarOrderAdvanceViewModel alloc] init];
    }
    [self.view addSubview:self.tableView];
    //不可编辑状态
    if (_notAllowedEdit==NO) {
        
        [self _creatSubmitButton];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_refreshData) name:kCalculateCar object:nil];
}

/**
 刷新数据
 */
-(void)_refreshData{
    [self.tableView reloadData];
}

/**
 按钮
 */
-(void)_creatSubmitButton{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    UIButton *saveButton = [UIButton new];
    [baseView addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(baseView).with.offset(10);
        make.height.equalTo(@40);
        make.centerY.equalTo(baseView);
        make.right.equalTo(baseView.mas_centerX).offset(-10);
    }];
    [saveButton setTitle:@"保存垫款信息" forState:0];
    [saveButton setTitleColor:[UIColor whiteColor] forState:0];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"bg_button"] forState:0];
    [saveButton addTarget:self action:@selector(_save) forControlEvents:UIControlEventTouchUpInside];
    

    UIButton *submitButton = [UIButton new];
    
    [baseView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(saveButton.mas_right).with.offset(20);
        make.height.equalTo(@40);
        make.centerY.equalTo(baseView);
        make.right.equalTo(baseView).with.offset(-10);
    }];
    [submitButton setTitle:@"提交初审单" forState:0];
    [submitButton setTitleColor:[UIColor whiteColor] forState:0];
    [submitButton setBackgroundImage:[UIImage imageNamed:@"bg_button"] forState:0];
    [submitButton addTarget:self action:@selector(_submit) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = baseView;
}
-(void)_save{
    [[NSNotificationCenter defaultCenter]postNotificationName:kSubmitCarOrder object:self.viewModel.advance];
}
/**
 提交
 */
-(void)_submit{
    [[NSNotificationCenter defaultCenter]postNotificationName:kSubmitCarOrder object:@"submit"];
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
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
