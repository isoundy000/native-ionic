//
//  CreditInfoDetailViewModel.h
//  carFinance
//
//  Created by hyjt on 2017/4/17.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "JH_ViewModelFactory.h"
#import "CreditInfoDetailModel.h"
@interface CreditInfoDetailViewModel : JH_ViewModelFactory
@property(nonatomic,strong)CreditInfoDetailModel *model;
//分组标题
-(NSString *)titleForSection:(NSInteger )section;
/**
 返回单元格高度
 
 @param indexPath NSIndexPath
 @return 高度
 */
-(CGFloat)JH_heightForCell:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView;
@end
