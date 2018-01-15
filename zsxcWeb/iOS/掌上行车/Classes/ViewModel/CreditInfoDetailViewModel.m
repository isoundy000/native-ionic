//
//  CreditInfoDetailViewModel.m
//  carFinance
//
//  Created by hyjt on 2017/4/17.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "CreditInfoDetailViewModel.h"
#import "CreditInfoDetailCell.h"
#import "CreditSituationCell.h"
#import "NSString+ChangeTime.h"
@implementation CreditInfoDetailViewModel
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

-(void)JH_loadTableDataWithData:(NSDictionary *)data completionHandle:(void (^)(id))completionblock errorHandle:(void (^)(NSError *))errorblock{
  
  [JH_NetWorking requestDataByJson:[NSString stringWithFormat:@"%@%@",kBaseUrlStr_Local1,kcreditDetail] HTTPMethod:HttpMethodGet  showHud:YES params:[JH_NetWorking addKeyAndUIdForRequest:@{@"ordernumber":data[@"ordernumber"]}] completionHandle:^(id result) {
    if ([result[@"code"]isEqualToString:kSuccessCode]) {
      
      //处理数据
      NSDictionary *persons = result[@"data"];
      
      CreditInfoDetailModel *detailModel = [CreditInfoDetailModel mj_objectWithKeyValues:persons];
      
      //重组可变数组
      NSMutableArray *together = [[NSMutableArray alloc] init];
      NSMutableArray *guarantee = [[NSMutableArray alloc] init];
      for (NSDictionary  *dic in detailModel.details) {
        CreditBuyerDetailModel *person = [CreditBuyerDetailModel mj_objectWithKeyValues:dic];
          person = [self sortImageInfo:person];
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
      
      self.model = detailModel;
      completionblock(nil);
    }else{
      
    }
  } errorHandle:^(NSError *error) {
    
    errorblock(nil);
  }];
}
-(CreditBuyerDetailModel *)sortImageInfo:(CreditBuyerDetailModel *)model{
    NSArray *fileinfo = model.fileinfo;
    [fileinfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *file = obj;
        switch (idx) {
            case 0:
                model.cardnoFrontphotoFilename  = file[@"card_name"];
                model.cardnoFrontphotoFilegroup = [NSString stringWithFormat:@"%@",file[@"card_id"]];
                model.cardnoFrontphotoFilepath  = file[@"card_url"];
                break;
            case 1:
                model.cardnoBackphotoFilename  = file[@"card_name"];
                model.cardnoBackphotoFilegroup = [NSString stringWithFormat:@"%@",file[@"card_id"]];
                model.cardnoBackphotoFilepath  = file[@"card_url"];
                break;
            case 2:
                model.authletterPhotoFilename  = file[@"card_name"];
                model.authletterPhotoFilegroup = [NSString stringWithFormat:@"%@",file[@"card_id"]];
                model.authletterPhotoFilepath  = file[@"card_url"];
                break;
            case 3:
                model.signaturePhotoFilename   = file[@"card_name"];
                model.signaturePhotoFilegroup  = [NSString stringWithFormat:@"%@",file[@"card_id"]];
                model.signaturePhotoFilepath   = file[@"card_url"];
                break;
            default:
                break;
        }
    }];
    return model;
}
/**
 将行数放回给VC
 
 @return 行数
 */
-(NSInteger)JH_numberOfSection{
  NSInteger count1 = self.model.togetherBuyer.count>0?1:0;
  NSInteger count2 = self.model.guarantee.count>0?1:0;
  
  return 2+count1+count2;
}
/**
 将列数放回给VC
 
 @param section 行数
 @return 列数
 */
-(NSInteger)JH_numberOfRow:(NSInteger)section{
    if (self.model.togetherBuyer.count==0) {
        if (section==2) {
            return self.model.guarantee.count;
        }
    }
    
  if (section==2) {
    return self.model.togetherBuyer.count;
  }
  if (section==3) {
    return self.model.guarantee.count;
  }
  return 1;
}
/**
 直接放回cell给VC
 
 @param indexPath indexPath
 @return cell
 */
-(UITableViewCell *)JH_setUpTableViewCell:(NSIndexPath *)indexPath{
  if (indexPath.section==0) {
    CreditSituationCell *creditCell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CreditSituationCell class]) owner:self options:nil]firstObject];
    
    creditCell.labLoanBank.text = self.model.orderinfo[@"loanbank"];
    creditCell.labCheckTime.text = [NSString changeTimeIntervalToSecond:@([self.model.buyer.returnTime longLongValue])];
    return creditCell;
  }
  CreditInfoDetailCell *creditCell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CreditInfoDetailCell class]) owner:self options:nil]firstObject];
  if (indexPath.section==1) {
    //购车人
    creditCell.labName.text = self.model.buyer.name;
    creditCell.labIdCard.text = self.model.buyer.idnumber;
    creditCell.labSex.text = self.model.buyer.sex;
    creditCell.labCreditState.text = [self.model.buyer.status isEqualToString:@""]?@"无":self.model.buyer.status;
    creditCell.labCreditHistory.text = self.model.buyer.remark;
    creditCell.detailImageView.imageArray = [self sortImageUrl:self.model.buyer];
    
  }else{
    CreditBuyerDetailModel *model;
      if (self.model.togetherBuyer.count==0) {
          if (indexPath.section==2) {
              //担保人
              model = self.model.guarantee[indexPath.row];
          }
      }else{
          if (indexPath.section==2){
              //配偶
              model = self.model.togetherBuyer[indexPath.row];
          }else{
              
              //担保人
              model = self.model.guarantee[indexPath.row];
          }
      }
    
    
    creditCell.labName.text = model.name;
    creditCell.labIdCard.text = model.idnumber;
    creditCell.labSex.text = model.sex;
//    creditCell.labMobile.text = model.phone;
      creditCell.labCreditState.text = [model.status isEqualToString:@""]?@"无":model.status;
;
    creditCell.labCreditHistory.text = model.remark;

    creditCell.detailImageView.imageArray = [self sortImageUrl:model];
  }
  return creditCell;
}
-(NSArray *)sortImageUrl:(CreditBuyerDetailModel *)model{

    return @[[NSString stringWithFormat:@"%@%@",kBaseUrlStr_Local1,model.cardnoFrontphotoFilepath],
             [NSString stringWithFormat:@"%@%@",kBaseUrlStr_Local1,model.cardnoBackphotoFilepath],
             [NSString stringWithFormat:@"%@%@",kBaseUrlStr_Local1,model.authletterPhotoFilepath],
           [NSString stringWithFormat:@"%@%@",kBaseUrlStr_Local1,model.signaturePhotoFilepath]
           ];
  
  
}

/**
 返回单元格高度
 
 @param indexPath NSIndexPath
 @return 高度
 */
-(CGFloat)JH_heightForCell:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView{
      if (indexPath.section==0) {
          return 60;
      }
    NSString *remarkText;
    if (indexPath.section==1) {
        //购车人
        remarkText = self.model.buyer.remark;
    }else{
        CreditBuyerDetailModel *model;
        if (self.model.togetherBuyer.count==0) {
            if (indexPath.section==2) {
                //担保人
                model = self.model.guarantee[indexPath.row];
                remarkText = model.remark;
            }
        }else{
            if (indexPath.section==2){
                //配偶
                model = self.model.togetherBuyer[indexPath.row];
                remarkText = model.remark;
            }else{
                //担保人
                model = self.model.guarantee[indexPath.row];
                remarkText = model.remark;
            }

        }
        
    }
    //计算文本大小
    CGFloat maxWidth = kScreen_Width - 8*2 -77;
    CGRect frame = [remarkText boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    return frame.size.height+25*3+15;
}
//分组标题
-(NSString *)titleForSection:(NSInteger )section{
  return @[@"审核情况",@"购车人",@"配偶",@"担保人"][section];
}
/**
 创建分组头视图
 
 @param section NSIndexPath
 @return view
 */
-(UIView *)JH_setUpTableSectionHeader:(NSInteger)section{
  
  UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
  baseView.backgroundColor = [UIColor whiteColor];
  //separateView
  //tipView
  UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0,0,baseView.width, 10)];
  separateView.backgroundColor = kBaseBGColor;
  [baseView addSubview:separateView];
  //tipView
  CGFloat height = 15;
  UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(10,separateView.height+height/2, 3, height)];
  imageView.backgroundColor = kBaseColor;
  [baseView addSubview:imageView];
  //titleView
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+5, separateView.height,200, baseView.height-separateView.height)];
  titleLabel.font = [UIFont systemFontOfSize:16];
  titleLabel.text = [self titleForSection:section];
  [baseView addSubview:titleLabel];
  return baseView;
}


@end
