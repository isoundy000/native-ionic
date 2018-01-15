//
//  CarOrderAssureViewModel.m
//  掌上行车
//
//  Created by hyjt on 2017/5/9.
//
//

#import "CarOrderAssureViewModel.h"

#import "CarOrderViewCell.h"
@implementation CarOrderAssureViewModel
-(NSInteger)JH_numberOfSection{
    return 4*(self.asureArray.count);
}
-(NSInteger)JH_numberOfRow:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)JH_setUpTableViewCell:(NSIndexPath *)indexPath WithHandle:(void(^)())completionBlock{
    CarOrderViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CarOrderViewCell class]) owner:self options:nil]lastObject];
    //第几个人
    NSInteger index = indexPath.section/4;
    //哪一种类
    NSInteger indexType = indexPath.section%4;
    Assure *assure = self.asureArray[index];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.asureArray];
    cell.type = CarOrderViewCellTypeAssue;
    if (indexType==0) {
        cell.model = assure.base;
        [cell setRefreshBlock:^(NSObject *model,BOOL refresh){
            assure.base = (Base *)model;
            [tempArray replaceObjectAtIndex:index withObject:assure];
            _asureArray = tempArray;
            if (refresh) {
                completionBlock();
            }
        }];
    }else if (indexType==1) {
        cell.model = assure.house;
        [cell setRefreshBlock:^(NSObject *model,BOOL refresh){
            assure.house = (House *)model;
            [tempArray replaceObjectAtIndex:index withObject:assure];
            _asureArray = tempArray;
            if (refresh) {
                completionBlock();
            }
        }];
    }else if (indexType==2) {
        cell.model = assure.work;
        [cell setRefreshBlock:^(NSObject *model,BOOL refresh){
            assure.work = (Work *)model;
            [tempArray replaceObjectAtIndex:index withObject:assure];
            _asureArray = tempArray;
            if (refresh) {
                completionBlock();
            }
        }];
    }else{
        TypicatTextView *view = [[TypicatTextView alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width-20, 50) withType:TypicalViewText withTitle:@"备注：" withText:assure.remark withAddInfo:@"" titleArray:@[] withNecessary:YES];
        view.typical = @"remark";
        [view setInputBlock:^(NSString *text,NSString *typical){
            assure.remark = text;
            [tempArray replaceObjectAtIndex:index withObject:assure];
            _asureArray = tempArray;
            completionBlock();
        }];
        [cell.contentView addSubview:view];
    }

    return cell;
    
}


-(CGFloat)JH_heightForCell:(NSIndexPath *)indexPath{
    //哪一种类
    NSInteger indexType = indexPath.section%4;
    switch (indexType) {
            
        case 0:
            return 230;
            break;
        case 1:
            return 230;
            break;
        case 2:
            return 270;
        default:
            break;
    }
    return  70;
}

//分组标题
-(NSString *)titleForSection:(NSInteger )section{
    NSInteger indexType = section%4;
    return @[@"担保人",@"房产信息",@"工作信息",@"备注"][indexType];
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
