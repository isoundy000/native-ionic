//
//  CreditInfoViewModel.m
//  carFinance
//
//  Created by hyjt on 2017/4/17.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "CreditInfoViewModel.h"
#import "CreditInfoCell.h"
#import "CreditInfoItem.h"
#import "CreditInfoDetailController.h"
@implementation CreditInfoViewModel

-(NSDictionary *)testData{
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"creditList"ofType:@"json"];
    
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingMutableLeaves error:&error];
    return jsonObject;
}
/**
 加载数据并返回
 
 @param data 请求的数据
 @param completionblock 成功
 @param errorblock 失败
 */
-(void)JH_loadTableDataWithData:(NSDictionary *)data completionHandle:(void (^)(id))completionblock errorHandle:(void (^)(NSError *))errorblock{
  self.dataList = [[NSMutableArray alloc] init];
  [JH_NetWorking requestDataByJson:[kBaseUrlStr_Local1 stringByAppendingString:korderlist] HTTPMethod:HttpMethodGet  showHud:YES params:data completionHandle:^(id result) {
    if ([result[@"code"]isEqualToString:kSuccessCode]) {
      
      //处理数据
      NSArray *recordList = result[@"list"];
      for (NSDictionary *dic in recordList) {
        
        CreditInfoItem *detailModel = [CreditInfoItem mj_objectWithKeyValues:dic];
        //重组可变数组
        NSMutableArray *together = [[NSMutableArray alloc] init];
        NSMutableArray *guarantee = [[NSMutableArray alloc] init];
        for (NSDictionary  *dic in detailModel.creditRes) {
          CreditBuyerDetailModel *person = [CreditBuyerDetailModel mj_objectWithKeyValues:dic];
          if ([person.type isEqualToString:@"购车人"]) {
            detailModel.buyer = person;
          }else if ([person.type isEqualToString:@"担保人"]) {
            [guarantee addObject:person];
          }else if ([person.type isEqualToString:@"配偶"]) {
            
            [together addObject:person];
          }
        }
        detailModel.togetherBuyer = together;
        
        detailModel.guarantee = guarantee;
        
        [self.dataList addObject:detailModel];
        
      }
      
    }else{
      
    }
    completionblock(result);
  } errorHandle:^(NSError *error) {
    errorblock(error);
    
  }];
}



-(NSInteger)JH_numberOfSection{

    if (_key!=nil&&![_key isEqualToString:@""]) {
        return [self _searchData:_key].count;
    }
    return self.dataList.count;
}
-(NSInteger)JH_numberOfRow:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)JH_setUpTableViewCell:(NSIndexPath *)indexPath{
    CreditInfoCell *creditCell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CreditInfoCell class]) owner:self options:nil]firstObject];

    if (self.dataList.count>0) {
        
        creditCell.item = self.dataList[indexPath.section];
        if (_key!=nil&&![_key isEqualToString:@""]) {
            creditCell.item = [self _searchData:_key][indexPath.section];
        }
        WeakSelf
        [creditCell setBlock:^(){

          [weakSelf didSelectRowAndPush:indexPath vcName:nil dic:nil nav:nil];
        }];
    }
    return creditCell;
}


-(CGFloat)JH_heightForCell:(NSIndexPath *)indexPath{
    CreditInfoItem *item = self.dataList[indexPath.section];
    if (_key!=nil&&![_key isEqualToString:@""]) {
        item = [self _searchData:_key][indexPath.section];
    }
    return 60+(item.togetherBuyer.count+item.guarantee.count+1)*25+40;
}
-(void)didSelectRowAndPush:(NSIndexPath *)indexPath vcName:(NSString *)vcName dic:(NSDictionary *)dic nav:(UINavigationController *)nav{
    CreditInfoDetailController *detail = [[CreditInfoDetailController alloc] init];
    //model
    CreditInfoItem *detailModel = self.dataList[indexPath.section];
    if (_key!=nil&&![_key isEqualToString:@""]) {
        detailModel = [self _searchData:_key][indexPath.section];
    }
    detail.creditHandleId = [NSString stringWithFormat:@"%@",detailModel.ordernumber];
    detail.hidesBottomBarWhenPushed = YES;
    [self.viewController.navigationController pushViewController:detail animated:YES];
}

/**
 搜索数据
 
 @param key 关键字
 @return 查询到的数据
 */
-(NSMutableArray *)_searchData:(NSString *)key{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (CreditInfoItem *detailModel in self.dataList) {
        if ([detailModel.customname containsString:key]||[detailModel.customidnumber containsString:key]) {
            [tempArray addObject:detailModel];
            continue;
        }
        //配偶(由于只有一个目前)
        if (detailModel.togetherBuyer.count>0) {
            CreditBuyerDetailModel *person = detailModel.togetherBuyer[0];
            if ([person.name containsString:key]) {
                [tempArray addObject:detailModel];
                continue;
            }
        }
        //担保人
        for (CreditBuyerDetailModel *person in detailModel.guarantee) {
            if ([person.name containsString:key]) {
                
            [tempArray addObject:detailModel];
            break;
            }
        }
    }
    return tempArray;
}

@end
