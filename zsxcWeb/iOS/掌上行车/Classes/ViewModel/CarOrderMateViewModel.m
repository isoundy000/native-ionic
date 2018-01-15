//
//  CarOrderMateViewModel.m
//  掌上行车
//
//  Created by hyjt on 2017/5/9.
//
//

#import "CarOrderMateViewModel.h"
#import "CarOrderViewCell.h"
@implementation CarOrderMateViewModel
-(NSInteger)JH_numberOfSection{
    return 3;
}
-(NSInteger)JH_numberOfRow:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)JH_setUpTableViewCell:(NSIndexPath *)indexPath WithHandle:(void(^)())completionBlock{
        CarOrderViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CarOrderViewCell class]) owner:self options:nil]lastObject];
        cell.type = CarOrderViewCellTypeMate;
        if (indexPath.section==0) {//购车人信息
            
            cell.model = self.mate.base;
            [cell setRefreshBlock:^(NSObject *model,BOOL refresh){
                self.mate.base = (Base *)model;
                if (refresh) {
                    completionBlock();
                }
            }];
        }else if (indexPath.section==1){//工作信息
            cell.model = self.mate.work;
            [cell setRefreshBlock:^(NSObject *model,BOOL refresh){
                self.mate.work = (Work *)model;
                if (refresh) {
                    completionBlock();
                }
            }];
        }else{//客户描述
            TypicatTextView *view = [[TypicatTextView alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width-20, 50) withType:TypicalViewText withTitle:@"描述：" withText:self.mate.remark withAddInfo:@"" titleArray:@[] withNecessary:YES];
            view.typical = @"remark";
            [view setInputBlock:^(NSString *text,NSString *typical){
                self.mate.remark = text;
                completionBlock();
            }];
            [cell.contentView addSubview:view];
        }
        
        return cell;
    
}


-(CGFloat)JH_heightForCell:(NSIndexPath *)indexPath{
    switch (indexPath.section) {

        case 0:
            return 190;
            break;
        case 1:
            return 270;
            break;
        default:
            break;
    }
    return  70;
}

//分组标题
-(NSString *)titleForSection:(NSInteger )section{
    return @[@"配偶",@"工作信息",@"描述"][section];
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
