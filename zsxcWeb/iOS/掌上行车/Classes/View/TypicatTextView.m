//
//  TypicatTextView.m
//  JHTypicalViewTest
//
//  Created by hyjt on 2017/5/5.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "TypicatTextView.h"
#import "JHCommonPickerView.h"
#import "JH_DatePicker.h"
@implementation TypicatTextView
{
    NSArray *_dataArray;
}
/*
 init
 */
-(instancetype)initWithFrame:(CGRect)frame withType:(TypicalView )type withTitle:(NSString *)title withText:(NSString *)text withAddInfo:(NSString *)info titleArray:(NSArray<NSDictionary *> *)titleArray withNecessary:(BOOL)isNecessary{
    self = [super initWithFrame:frame];
    if (self) {
        //给self加上边框
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.cornerRadius = 3;
        
        switch (type) {
            case TypicalViewButton:
                [self _creatButton:title];
                break;
            case TypicalViewText:
            case TypicalViewTextNumber:
            case TypicalViewTextEnable:
                [self creatTextViewWithTitle:title withText:text withType:type withAddInfo:info withNecessary:isNecessary];
                break;
            case TypicalViewPickerProvince:
            case TypicalViewPickerDate:
                [self creatPickerViewWithTitle:title withText:text withNecessary:isNecessary withType:type];
                break;
            case TypicalViewPicker:
                _dataArray = titleArray;
                [self creatTextViewWithTitle:title withText:text titleArray:titleArray withNecessary:YES];
                break;
            case TypicalViewPickerEnable:
                [self creatPickerViewWithTitle:title withText:text withNecessary:isNecessary withType:type];
                break;
            default:
                break;
        }
    }
    return self;
}
/**
 按钮
 */
-(void)_creatButton:(NSString *)title{
    UIButton *btn = [UIButton new];
    [self addSubview:btn];
    [btn setTitle:title forState:0];
    [btn setTitleColor:[UIColor whiteColor] forState:0];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.layer.cornerRadius = 3;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [btn addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void)buttonAction{
    _buttonBlock();
}
/**
 文字框
 */
-(void)creatTextViewWithTitle:(NSString *)title withText:(NSString *)text withType:(TypicalView )type withAddInfo:(NSString *)info withNecessary:(BOOL)isNecessary{
    //label
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:12];
    
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(5);
        make.top.equalTo(self).with.offset(5);
        make.height.equalTo(@20);
    }];
    if (isNecessary) {
        label.attributedText = [self addNeedSymbol:title];
    }else{
        label.text = title;
    }
    //textView
    _textView =[UITextView new];
    
    _textView.text = text?[NSString stringWithFormat:@"%@",text]:@"";
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:12];
    _textView.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0);
    _textView.delegate = self;
    _textView.textColor = kBaseBlackTextColor;
    
    [self addSubview:_textView];
    if (type==TypicalViewTextEnable) {
        //取消编辑状态
        _textView.editable = NO;
        self.backgroundColor = kBaseBGColor;
    }
    if (type==TypicalViewTextNumber) {
        //取消编辑状态
        _textView.keyboardType = UIKeyboardTypeDecimalPad;
    }
    if (!IOS9_OR_LATER) {
        [label layoutIfNeeded];

        _textView.frame = CGRectMake(label.right, 5, self.frame.size.width-15-label.width-5, self.frame.size.height-10);

    }else{
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right);
            make.centerY.equalTo(self);
            make.height.equalTo(self).with.offset(-10);
            make.right.equalTo(self).with.offset(-15);
            
        }];

    }
    
    if (info.length!=0) {
        
            UILabel *addLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            addLabel.font = [UIFont systemFontOfSize:12];
            [self addSubview:addLabel];
            addLabel.text = info;
            addLabel.center = CGPointMake(self.width-15/2, self.height/2);
 
    }
//    [_textView layoutIfNeeded];
//    if (_textView.text==0) {
//    
//        _textView.contentSize = CGSizeMake(_textView.frame.size.width, _textView.frame.size.height);
//    }

}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    //由于空的时候出现偏移的bug，故这里手动设置容器大小
    if (textView.text.length==0) {
        _textView.contentSize = CGSizeMake(_textView.frame.size.width, _textView.frame.size.height);
    }
}
-(void)textViewDidChange:(UITextView *)textView{
    //由于清空的时候出现偏移的bug，故这里手动设置容器大小
    if (textView.text.length==0) {
        _textView.contentSize = CGSizeMake(_textView.frame.size.width, _textView.frame.size.height);
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    //停止编辑的时候需要将数据返回
    _InputBlock(textView.text,_typical);
}
/**
 选择框
 */
-(void)creatTextViewWithTitle:(NSString *)title withText:(NSString *)text titleArray:(NSArray<NSDictionary *> *)titleArray withNecessary:(BOOL)isNecessary{
    //标题label
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = title;
    [self addSubview:titleLabel];
    if (isNecessary) {
        titleLabel.attributedText = [self addNeedSymbol:title];
    }else{
        titleLabel.text = title;
    }
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(5);
        make.centerY.equalTo(self);
    }];
    //文字label
    UILabel *pickerLabel = [UILabel new];
    pickerLabel.font = [UIFont systemFontOfSize:12];
    pickerLabel.numberOfLines = 2;
    pickerLabel.text = text.length==0?@"请选择":text;
    pickerLabel.textColor = text.length==0?kBaseGrayTextColor:kBaseBlackTextColor;
    [self addSubview:pickerLabel];
    //将title的大小固定
    [titleLabel setNeedsLayout];
    [pickerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).with.offset(5);
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(self).with.offset(-15);
    }];
    _pickerLabel = pickerLabel;
    //往下图片
    UIImageView *imageView = [UIImageView new];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"icon_more"];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-2);
        make.width.equalTo(@11);
        make.height.equalTo(imageView.mas_width).multipliedBy(13/24.0);
        make.centerY.equalTo(titleLabel);
    }];
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAction)];
    [self addGestureRecognizer:tap];
    
}
//省市区选择
-(void)creatPickerViewWithTitle:(NSString *)title withText:(NSString *)text withNecessary:(BOOL)isNecessary withType:(TypicalView )type{
    //标题label
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = title;
    [self addSubview:titleLabel];
    if (isNecessary) {
        titleLabel.attributedText = [self addNeedSymbol:title];
    }else{
        titleLabel.text = title;
    }
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(5);
        make.centerY.equalTo(self);
    }];
    //文字label
    UILabel *pickerLabel = [UILabel new];
    pickerLabel.font = [UIFont systemFontOfSize:12];
    pickerLabel.numberOfLines = 2;
    pickerLabel.text = text.length==0?@"请选择":text;
    pickerLabel.textColor = text.length==0?kBaseGrayTextColor:kBaseBlackTextColor;
    [self addSubview:pickerLabel];
    //将title的大小固定
//    [titleLabel setNeedsLayout];
    [pickerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).with.offset(5);
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(self).with.offset(-15);
    }];
    _pickerLabel = pickerLabel;
    //往下图片
    UIImageView *imageView = [UIImageView new];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"icon_more"];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-2);
        make.width.equalTo(@11);
        make.height.equalTo(imageView.mas_width).multipliedBy(13/24.0);
        make.centerY.equalTo(titleLabel);
    }];
    if (type==TypicalViewPickerProvince) {
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_provinceTapAcion)];
        [self addGestureRecognizer:tap];
    }else if (type==TypicalViewPickerDate) {
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dataPickerAction)];
        [self addGestureRecognizer:tap];
    }else{
        self.backgroundColor = kBaseBGColor;
    }
    
    
}

/**
 时间选择
 */
-(void)_dataPickerAction{
    [[self viewController].view endEditing:YES];
    
    JH_DatePicker *date = [[JH_DatePicker alloc] initWithFrame:CGRectZero];
    [date show];
    [date setBlock:^(NSDate *date){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];//设置输出的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];//四个y就是2014－10-15，2个y就是14-10-15，这是输出字符串的时候用到的
        NSString *dateStr = [dateFormatter stringFromDate:date];
        _pickerBlock([NSString stringWithFormat:@"%@",date],dateStr,_typical);
    }];
    
}
/**
 省市区选择
 */
-(void)_provinceTapAcion{
    [[self viewController].view endEditing:YES];
    
    [self.pickerView show];
}
/**
 点击事件
 */
-(void)_tapAction{
    [[self viewController].view endEditing:YES];
    
    JHCommonPickerView *picker = [[JHCommonPickerView alloc] initWithFrame:CGRectZero titleArray:_dataArray handler:^(NSString *value, NSString *text) {
        _pickerBlock(value,text,_typical);
    }];
    [picker show];
    
}
- (AddressPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[AddressPickerView alloc]initWithFrame:CGRectZero];
        _pickerView.delegate = self;
        
    }
    return _pickerView;
}
/**
 获取UIView的UIViewController控制器
 */
-(UIViewController *)viewController{
    UIResponder *next = self.nextResponder;
    while(next !=nil){
        if([next isKindOfClass:[UIViewController class]]){
            return (UIViewController *)next;
        }
        next = next.nextResponder;
    }
    return nil;
}
#pragma mark - AddressPickerViewDelegate
- (void)cancelBtnClick{
    
    [self.pickerView hide];
    
}
- (void)sureBtnClickReturnProvince:(NSString *)province City:(NSString *)city Area:(NSString *)area{
    NSString *provinceText = [NSString stringWithFormat:@"%@-%@-%@",province,city,area];
    [self.pickerView hide];
    _pickerBlock(@"",provinceText,_typical);
}
-(NSMutableAttributedString *)addNeedSymbol:(NSString *)text{
    text = [NSString stringWithFormat:@"*%@",text];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:text];
    [attribute setAttributes:@{NSForegroundColorAttributeName :[UIColor redColor]} range:NSMakeRange(0, 1)];
    return attribute;
}

@end
