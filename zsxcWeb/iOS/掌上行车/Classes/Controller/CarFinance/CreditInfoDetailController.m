//
//  CreditInfoDetailController.m
//  carFinance
//
//  Created by hyjt on 2017/4/17.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "CreditInfoDetailController.h"
#import "CreditInfoDetailViewModel.h"
#import "Root_CreditController.h"
@interface CreditInfoDetailController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)CreditInfoDetailViewModel *viewModel;

@end

@implementation CreditInfoDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
  //暂时不需要修改征信
//    [self _creatRightButton];
  
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    WeakSelf
    _viewModel = [[CreditInfoDetailViewModel alloc] init];
    [_viewModel JH_loadTableDataWithData:@{@"ordernumber":self.creditHandleId} completionHandle:^(id result) {
        weakSelf.title = _viewModel.model.buyer.name;
        [weakSelf.tableView reloadData];
    } errorHandle:^(NSError *error) {
        [weakSelf _creatNoNetWorkView];
    }];
}

/**
 修改征信按钮
 */
-(void)_creatRightButton{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改征信" style:UIBarButtonItemStylePlain target:self action:@selector(_editCreditAction)];
}

/**
 跳转征信修改，并传递数据
 */
-(void)_editCreditAction{
    Root_CreditController *credit = [[Root_CreditController alloc] init];
    credit.viewModel = self.viewModel;
    [self _pushViewController:credit];
    
}

-(UITableView *)tableView{
    if (_tableView==nil) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

#pragma mark - tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.viewModel JH_numberOfSection];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.viewModel JH_numberOfRow:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [self.viewModel JH_setUpTableViewCell:indexPath];
}

#pragma mark - tableViewDataDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.viewModel JH_heightForCell:indexPath withTableView:tableView];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return  [self.viewModel JH_setUpTableSectionHeader:section];
}
#pragma mark - 选中事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
