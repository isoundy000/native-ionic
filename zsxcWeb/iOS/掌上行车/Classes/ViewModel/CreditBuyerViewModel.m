//
//  CreditBuyerViewModel.m
//  carFinance
//
//  Created by 江弘 on 2017/4/16.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "CreditBuyerViewModel.h"
#import "CreditTextCell.h"
#import "CreditImageCell.h"
#import "CreditPickerCell.h"
#import "JHPickTableView.h"
#import "JHCommonPickerView.h"
@implementation CreditBuyerViewModel
/**
 加载数据并返回
 
 @param data 请求的数据
 @param completionblock 成功
 @param errorblock 失败
 */
-(void)JH_loadTableDataWithData:(NSDictionary *)data completionHandle:(void (^)(id result))completionblock errorHandle:(void (^)(NSError * error))errorblock{
    self.model = [[CreditBuyerModel alloc] init];
    //购车人标记
    self.model.type = @"BUYER";
    //    [self.dataList addObject:[CreditTogetherModel mj_objectWithKeyValues:[self testData]]];
    //    [self.dataList addObject:[CreditTogetherModel mj_objectWithKeyValues:[self testData]]];
}
-(NSInteger)JH_numberOfRow:(NSInteger)section{
    return [self cellType].count;
}
-(CGFloat)JH_heightForCell:(NSIndexPath *)indexPath{
    if ([[self cellType][indexPath.row] isEqual:@0]) {
        
        return 50;
    }else if ([[self cellType][indexPath.row] isEqual:@1]) {
        
        return 50;
    }else{
        return (kScreen_Width-30)*(54/85.6)+60;
        
    }
}

-(NSArray *)cellType{
    
    return @[@1,@0,@0,@2,@2,@2,@2];
}
-(UITableViewCell *)JH_setUpTableViewCell:(NSIndexPath *)indexPath{
    if ([[self cellType][indexPath.row] isEqual:@0]) {
        CreditTextCell *cell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CreditTextCell class]) owner:self options:nil]lastObject];
        return cell;
    }else if ([[self cellType][indexPath.row] isEqual:@1]) {
        CreditPickerCell *cell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CreditPickerCell class]) owner:self options:nil]lastObject];
        return cell;
    }else{
        CreditImageCell *cell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([CreditImageCell class]) owner:self options:nil]lastObject];
        return cell;
        
    }
    return nil;
    
}
//cellwillAooare
-(void)UIViewController:(UIViewController *)vc willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([[self cellType][indexPath.row] isEqual:@0]) {
        
        
        CreditTextCell *textCell         = (CreditTextCell *)cell;
        textCell.imgIcon.image           = [UIImage imageNamed:[self getData:DataTypeImageName WithRow: indexPath.row]];
        textCell.labTitle.attributedText = [self addNeedSymbol:[self getData:DataTypeTitlt WithRow: indexPath.row]];;
        textCell.texfDetail.placeholder  = [self getData:DataTypePlaceHold WithRow: indexPath.row];
        textCell.texfDetail.delegate     = vc;
        //获取输入框数据
        textCell.texfDetail.text         = [self.model valueForKeyPath:[self getData:DataTypeModel WithRow: indexPath.row]];
        //输入框键盘限制
        if ([[self getData:DataTypeTitlt WithRow: indexPath.row]isEqualToString:@"手机号"]) {
            textCell.texfDetail.keyboardType = UIKeyboardTypeNumberPad;
        }else if ([[self getData:DataTypeTitlt WithRow: indexPath.row]isEqualToString:@"身份证号"]) {
            textCell.texfDetail.keyboardType = UIKeyboardTypeASCIICapable;
        }
    }else if ([[self cellType][indexPath.row] isEqual:@1]){
        //选择器单元格
        CreditPickerCell *pickerCell       = (CreditPickerCell *)cell;
        pickerCell.imgIcon.image           = [UIImage imageNamed:[self getData:DataTypeImageName WithRow: indexPath.row]];
        pickerCell.labTitle.attributedText = [self addNeedSymbol:[self getData:DataTypeTitlt WithRow: indexPath.row]];
        
        if ([[self.model valueForKeyPath:[self getData:DataTypeModel WithRow: indexPath.row]]isEqualToString:@""]||[self.model valueForKeyPath:[self getData:DataTypeModel WithRow: indexPath.row]]==nil) {
            [pickerCell.labSelect setText:[self getData:DataTypePlaceHold WithRow: indexPath.row]];
            pickerCell.labSelect.textColor = kBaseGrayTextColor;
        }else{
            if (indexPath.row==0) {
                
                //银行
                [pickerCell.labSelect setText: [JHDownLoadFile getDictionTextByKey:@"bank" withId:[self.model valueForKeyPath:[self getData:DataTypeModel WithRow: indexPath.row]]]];
                pickerCell.labSelect.textColor = kBaseBlackTextColor;
            }
        }
        
    }else{
        //图片单元格
        CreditImageCell *imageCell = (CreditImageCell *)cell;
        
        imageCell.labTitle.attributedText = [self addNeedSymbol:[self getData:DataTypeTitlt WithRow: indexPath.row]];
        
        imageCell.imgPicture.text = [self getData:DataTypeTitlt WithRow: indexPath.row];
        NSString *fileGroup = [self.model valueForKeyPath:[self getData:DataTypeFileImageGroup WithRow: indexPath.row]];
        NSString *filePath = [self.model valueForKeyPath:[self getData:DataTypeFileImagePath WithRow: indexPath.row]];
        
        WeakSelf
        [imageCell.imgPicture sd_setShowActivityIndicatorView:YES];
        [imageCell.imgPicture sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",kBaseUrlStr_Local1,filePath]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf.model setValue:image forKey:[weakSelf getData:DataTypeModel WithRow:indexPath.row]];
            [imageCell.imgPicture setPicture: image];
        }];
        //由于imageView点击的时候无法让tableView响应，故这里要保存indexPath
        imageCell.imgPicture.indexPath = indexPath;
        //然后通过block将点击的image对应的indexpath返回，这样就能刷新视图，并保存数据了
        [imageCell.imgPicture setBlock:^(NSIndexPath *imageIndexPath ,BOOL isDelete){
            self.currentIndexPath = imageIndexPath;
            if (isDelete) {
                
                //删除请求
                [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kDeleteFile] HTTPMethod:HttpMethodPost  showHud:YES params:[JH_NetWorking addKeyAndUIdForRequest: @{@"aturl":filePath,@"atid":fileGroup,@"attachmenttype":@"credit"}] completionHandle:^(id result) {
                    if ([result[@"code"]isEqualToString:kSuccessCode]) {
                        //由于再重新添加的时候会重新设置图片的一些参数，这里就不用去删除了o(╯□╰)o
                        [weakSelf.model setValue:nil forKey:[weakSelf getData:DataTypeModel WithRow: indexPath.row]];
                        //还是把文件路径等一些信息删了吧，因为我要通过网络重新加载图片
                        [weakSelf.model setValue:nil forKey:[weakSelf getData:DataTypeFileImageName WithRow: indexPath.row]];
                        [weakSelf.model setValue:nil forKey:[weakSelf getData:DataTypeFileImagePath WithRow: indexPath.row]];
                        [weakSelf.model setValue:nil forKey:[weakSelf getData:DataTypeFileImageGroup WithRow: indexPath.row]];
                        
                    }
                } errorHandle:^(NSError *error) {
                    
                }];
            }
        }];
    }
}
-(NSMutableAttributedString *)addNeedSymbol:(NSString *)text{
    text = [NSString stringWithFormat:@"*%@",text];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:text];
    [attribute setAttributes:@{NSForegroundColorAttributeName :[UIColor redColor]} range:NSMakeRange(0, 1)];
    return attribute;
}
//选中事件
-(void)disSelectRowWithIndexPath:(NSIndexPath *)indexPath WithHandle:(void(^)())completionBlock{
    self.currentIndexPath = indexPath;
    
    if (indexPath.row==0) {
        NSArray *bankTitle = [JHDownLoadFile getArrayByKey:@"bank"];
        
        if (!IOS9_OR_LATER) {
            
            JHCommonPickerView *picker = [[JHCommonPickerView alloc] initWithFrame:CGRectZero titleArray:bankTitle handler:^(NSString *value, NSString *text) {
                [self.model setValue:value forKey:[self getData:DataTypeModel WithRow:indexPath.row]];
                completionBlock();
            }] ;
            [picker show];
        }else{
            [[[JHPickTableView alloc] initWithFrame:CGRectZero titleArray:bankTitle handler:^(NSString *key ,NSString *title) {
                
                [self.model setValue:key forKey:[self getData:DataTypeModel WithRow:indexPath.row]];
                completionBlock();
            }] show];
        }
    }
}
/**
 根据需求传入类型获取静态数据
 
 @param dataType DataType
 @param row NSInteger
 @return String
 */
-(NSString *)getData:(DataType)dataType WithRow:(NSInteger)row{
    switch (dataType) {
        case DataTypeModel:
            return @[@"loanBank",@"name",@"cardno",@"cardnoFrontphotoFile",@"cardnoBackphotoFile",@"authletterPhotoFile",@"signaturePhotoFile"][row];
            break;
        case DataTypeTitlt:
            return @[@"贷款银行",@"姓名",@"身份证号",@"身份证正面照片",@"身份证反面照片",@"授权书照片",@"签字照片"][row];
            break;
        case DataTypePlaceHold:
            return @[@"请选择银行",@"请输入姓名",@"请输入身份证号",@"身份证正面照片",@"身份证反面照片",@"授权书照片",@"签字照片"][row];
            break;
        case DataTypeImageName:
            return @[@"icon_5",@"icon_1",@"icon_3",@"",@"",@"",@""][row];
            break;
        case DataTypeFileImageName:
            return @[@"",@"",@"",@"cardnoFrontphotoFilename",@"cardnoBackphotoFilename",@"authletterPhotoFilename",@"signaturePhotoFilename"][row];
            break;
        case DataTypeFileImagePath:
            return @[@"",@"",@"",@"cardnoFrontphotoFilepath",@"cardnoBackphotoFilepath",@"authletterPhotoFilepath",@"signaturePhotoFilepath"][row];
            break;
        case DataTypeFileImageGroup:
            return @[@"",@"",@"",@"cardnoFrontphotoFilegroup",@"cardnoBackphotoFilegroup",@"authletterPhotoFilegroup",@"signaturePhotoFilegroup"][row];
            break;
        default:
            break;
    }
    
}

@end
