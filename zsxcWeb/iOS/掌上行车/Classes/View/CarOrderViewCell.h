//
//  CarOrderViewCell.h
//  掌上行车
//
//  Created by hyjt on 2017/5/8.
//
//

#import <UIKit/UIKit.h>
#import "CarOrderDetailModel.h"
#import "TypicatTextView.h"
typedef void (^RefreshBlock) (NSObject *,BOOL refresh);
typedef void (^UrgencyListBlock) (NSArray *,BOOL refresh);
typedef void (^CalculateBlock) ();
typedef NS_ENUM(NSInteger, CarOrderViewCellType) {
    CarOrderViewCellTypeBuyer,//购车人
    CarOrderViewCellTypeMate,//配偶
    CarOrderViewCellTypeAssue,//担保人
    CarOrderViewCellTypeCarInfo,//车辆信息
    CarOrderViewCellTypeCarInfoCalculate,//车辆信息计算合同价
    CarOrderViewCellTypeCarAdvance,//垫款信息
    CarOrderViewCellTypeCarAdvanceIn,//垫款信息收入
    CarOrderViewCellTypeCarAdvanceOut,//垫款信息支出
    CarOrderViewCellTypeCarAdvanceOther,//垫款信息其他
};

@interface CarOrderViewCell : UITableViewCell
@property(nonatomic,strong)RefreshBlock refreshBlock;
@property(nonatomic,strong)UrgencyListBlock urgencyBlock;
@property(nonatomic,strong)CalculateBlock calculateBlock;
@property(nonatomic,strong)NSObject *model;
@property(nonatomic,strong)NSArray *urgentList;
@property(nonatomic,assign)CarOrderViewCellType type;
@end
