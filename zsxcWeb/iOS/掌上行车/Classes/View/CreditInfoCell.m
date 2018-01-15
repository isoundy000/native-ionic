//
//  CreditInfoCell.m
//  carFinance
//
//  Created by hyjt on 2017/4/17.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "CreditInfoCell.h"
#import "NSString+ChangeTime.h"
@implementation CreditInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setItem:(CreditInfoItem *)item{
    if (_item!=item) {
        _item = item;
    }
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self setAttribute];
    [self addSomeView];
}
-(void)setAttribute{
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.viewBase.layer.cornerRadius = 5;
    self.viewBase.layer.masksToBounds = YES;
    
    self.labLoanBank.text = _item.loanbank;
//    self.labDealer.text = _item.deler;
//    self.labCheckTime.text = _item.rtime?_item.rtime:_item.refuseTime?_item.refuseTime:_item.mtime;
  
//    self.labTimeType.text = _item.rtime?@"审核时间：":_item.refuseTime?@"退回时间：":@"提交时间：";
//    self.labRefuse.text = [_item.orderstatus isEqualToString:@"NORMAL"]?@"否":@"是";
      self.labCheckTime.text = [NSString changeTimeIntervalToSecond:@([_item.orderaddtime longLongValue])];
      self.labTimeType.text = @"提交时间：";
  
}

-(void)addSomeView{
  CGFloat firstHtight = 60;
    [self addLineImageView:CGRectMake(20, firstHtight,kScreen_Width-40, 0.5)];
    
    CreditPersonStateView *buyer = [[CreditPersonStateView alloc] initWithFrame:CGRectMake(20, firstHtight,kScreen_Width-40, 25) withTitle:@"购车人姓名" withName:_item.buyer.name withState:_item.buyer.status];
    [self.contentView addSubview:buyer];
    if (_item.togetherBuyer.count>0) {
        [self addLineImageView:CGRectMake(20, buyer.bottom,kScreen_Width-40, 0.5)];
    }
    
    for (int i = 0; i<_item.togetherBuyer.count; i++) {
        CreditBuyerDetailModel *model = _item.togetherBuyer[i];
        CreditPersonStateView *together = [[CreditPersonStateView alloc] initWithFrame:CGRectMake(buyer.left, buyer.bottom+25*(i),buyer.width, buyer.height) withTitle:@"配偶姓名" withName:model.name withState:model.status];
        [self.contentView addSubview:together];
    }
    if (_item.guarantee.count>0) {
        [self addLineImageView:CGRectMake(20, buyer.bottom+25*_item.togetherBuyer.count,kScreen_Width-40, 0.5)];
    }
    for (int i = 0; i<_item.guarantee.count; i++) {
        CreditBuyerDetailModel *model = _item.guarantee[i];
        CreditPersonStateView *guarantee = [[CreditPersonStateView alloc] initWithFrame:CGRectMake(buyer.left, buyer.bottom+25*(i+_item.togetherBuyer.count),buyer.width, buyer.height) withTitle:@"担保人姓名" withName:model.name withState:model.status];
        [self.contentView addSubview:guarantee];
    }
    [self addLineView:CGRectMake(10, buyer.bottom+25*(_item.togetherBuyer.count+_item.guarantee.count),kScreen_Width-20, 0.5)];
    
    //查看详情按钮
    [self creatButton:CGRectMake(10, buyer.bottom+25*(_item.togetherBuyer.count+_item.guarantee.count),kScreen_Width-20, 40)];
}
//添加实线
-(void)addLineView:(CGRect )frame{
    UIView *lineView = [[UIView alloc] initWithFrame:frame];
    lineView.backgroundColor = kBaseBGColor;
    [self.contentView addSubview:lineView];
}
//添加虚线
-(void)addLineImageView:(CGRect )frame{
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:frame];
    lineView.image = [UIImage imageNamed:@"line_1"];
    [self.contentView addSubview:lineView];
}
-(void)creatButton:(CGRect)frame{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [self.contentView addSubview:button];
    [button setTitle:@"查看详情" forState:0];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:kBaseColor forState:0];
    [button addTarget:self action:@selector(_pushAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void)_pushAction{
    _block();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
