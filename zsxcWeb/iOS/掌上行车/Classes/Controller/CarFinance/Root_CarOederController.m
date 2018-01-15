//
//  Root_CarOederController.m
//  掌上行车
//
//  Created by hyjt on 2017/5/8.
//
//

#import "Root_CarOederController.h"
#import "JHMenuControlView.h"
#import "CarOrderBuyerController.h"
#import "CarOrderSpouseController.h"
#import "CarOrderGuaranteeController.h"
#import "CarOrderCarInfoController.h"
#import "CarOrderAdvanceController.h"
#import "CarOrderDetailModel.h"
#import "CreditGuaranteeController.h"
#import "JHCustomMenu.h"
#import "CreditTogetherBuyerController.h"
@interface Root_CarOederController ()<UIGestureRecognizerDelegate,JHCustomMenuDelegate>
{
    CarOrderBuyerController *_buyer;
    CarOrderCarInfoController *_car;
    CarOrderAdvanceController *_advance;
    CarOrderGuaranteeController *_assure;
    CarOrderSpouseController *_mate;
}
@property (nonatomic, strong) JHCustomMenu *menu;
@property (nonatomic, strong) JHMenuControlView *cursorView;
@end
static const CGFloat menuHeight = 40;
@implementation Root_CarOederController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"初审单录入";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:0 target:self action:@selector(navigationShouldPopOnBackButton)];
    [self _loadData];
    //不可编辑状态
    if (_notAllowedEdit==NO) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_button"] style:0 target:self action:@selector(_rightAction)];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_submitCarOrder:) name:kSubmitCarOrder object:nil];
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_getMortgagehigh) name:kCalculateCar object:nil];
}

/**
 初审单提交
 */
-(void)_submitCarOrder:(NSNotification *)notif{
    NSMutableDictionary *finalData = [[NSMutableDictionary alloc] init];
    //为了解决AFNetWorking的bug将buyerInfoDtos转换成json成为一个value
    if ([[notif object]isKindOfClass:[NSArray class]]) {
        NSMutableArray *finalArray = [[NSMutableArray alloc] init];
        NSArray *assureList = [notif object];
        for (Assure *assure in assureList) {
            NSDictionary *data = [assure toDictionary];
            [finalArray addObject:data];
        }
        [finalData setObject:finalArray forKey:@"assure"];
    }else{
        NSObject *object = [notif object];
        //购车人
        if ([object isKindOfClass:[Carman class]]) {
            Carman *carman = (Carman *)object;
            NSDictionary *dic = [carman toDictionary];
            [finalData setObject:dic forKey:@"carman"];
        }else if ([object isKindOfClass:[Mate class]]) {
            //配偶
            Mate *mate = (Mate *)object;
            mate.base = [self getBaseStringModelByArrayModel:mate.base];
            mate.work = [self getWorkStringModelByArrayModel:mate.work];
            NSDictionary *dic = [mate toDictionary];
            [finalData setObject:dic forKey:@"mate"];
        }else if ([object isKindOfClass:[Car class]]) {
            //车辆信息
            Car *car = (Car *)object;
            NSDictionary *dic = [car toDictionary];
            [finalData setObject:dic forKey:@"car"];
        }else if ([object isKindOfClass:[Advance class]]) {
            //垫款信息(走保存)
            Advance *advance = (Advance *)object;
            NSDictionary *dic = [advance toDictionary];
            [finalData setObject:dic forKey:@"advance"];
        }else if ([object isKindOfClass: [NSString class]]){
            //垫款信息(走提交)
            Advance *advance = _advance.viewModel.advance;
            NSDictionary *dic = [advance toDictionary];
            [finalData setObject:dic forKey:@"advance"];
            //获取基础信息
            NSDictionary *baseinfo = [_buyer.viewModel.baseInfo toDictionary];
            [finalData setObject:baseinfo forKey:@"baseinfo"];
            
            NSArray *assureList = _assure.viewModel.asureArray;
            if (assureList) {
                
                NSMutableArray *finalArray = [[NSMutableArray alloc] init];
                for (Assure *assure in assureList) {
                    NSDictionary *data = [assure toDictionary];
                    [finalArray addObject:data];
                }
                [finalData setObject:finalArray forKey:@"assure"];
            }
            Carman *carman = _buyer.viewModel.carMan;
            if (carman) {
                
                NSDictionary *carManDic = [carman toDictionary];
                [finalData setObject:carManDic forKey:@"carman"];
            }
            //配偶
            Mate *mate = _mate.viewModel.mate;
            
            if (mate) {
                mate.base = [self getBaseStringModelByArrayModel:mate.base];
                mate.work = [self getWorkStringModelByArrayModel:mate.work];
                NSDictionary *mateDic = [mate toDictionary];
                [finalData setObject:mateDic forKey:@"mate"];
            }
            //车辆信息
            Car *car = _car.viewModel.car;
            if (car) {
                NSDictionary *carDic = [car toDictionary];
                [finalData setObject:carDic forKey:@"car"];
            }
            
            NSString *jsonStr = [JH_CommonInterface DataTOjsonString:finalData];
            //最终完成数据的添加
            
            [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kfirstverifysave] HTTPMethod:HttpMethodPost  showHud:YES  params:[JH_NetWorking addKeyAndUIdForRequest:@{@"handle":@"commit",@"orderinfo":jsonStr}] completionHandle:^(id result) {
                if ([result[@"code"]isEqualToString:kSuccessCode]) {
                    
                    [MBProgressHUD MBProgressShowSuccess:YES WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
                    
                    //垫款信息
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
                }
                
                
            } errorHandle:^(NSError *error) {
                
            }];
            return;
        }
    }
    
    //获取基础信息
    NSDictionary *baseinfo = [_buyer.viewModel.baseInfo toDictionary];
    [finalData setObject:baseinfo forKey:@"baseinfo"];
    
    NSString *jsonStr = [JH_CommonInterface DataTOjsonString:finalData];
    //最终完成数据的添加
    
    [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kfirstverifysave] HTTPMethod:HttpMethodPost  showHud:YES  params:[JH_NetWorking addKeyAndUIdForRequest:@{@"handle":@"save",@"orderinfo":jsonStr}] completionHandle:^(id result) {
        if ([result[@"code"]isEqualToString:kSuccessCode]) {
            
            [MBProgressHUD MBProgressShowSuccess:YES WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
            //页面跳转
            if ([[notif object]isKindOfClass:[NSArray class]]) {
                //担保人
                _cursorView.currentIndex++;
            }else{
                NSObject *object = [notif object];
                if ([object isKindOfClass:[Advance class]]) {
                    
                }else{
                _cursorView.currentIndex++;
                }
            }
        }else{
            [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
        }
        
        
    } errorHandle:^(NSError *error) {
        
    }];
}
/**
 根据旧的model，获取新的model
 */
-(Base *)getBaseStringModelByArrayModel:(Base *)model{
    Base *newModel = [[Base alloc] init];
    NSArray *propertyList = [JH_RuntimeTool fetchPropertyList:[model class]];
    for (NSString *property in propertyList) {
        
        [newModel setValue:[[model valueForKey:property] isKindOfClass:[NSArray class]]?[model valueForKey:property][0]:[model valueForKey:property] forKey:property];
    }
    return newModel;
}
/**
 根据旧的model，获取新的model
 */
-(Work *)getWorkStringModelByArrayModel:(Work *)model{
    Work *newModel = [[Work alloc] init];
    NSArray *propertyList = [JH_RuntimeTool fetchPropertyList:[model class]];
    for (NSString *property in propertyList) {
        
        [newModel setValue:[[model valueForKey:property] isKindOfClass:[NSArray class]]?[model valueForKey:property][0]:[model valueForKey:property] forKey:property];
    }
    return newModel;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_cursorView removeFromSuperview];
    _buyer = nil;
    _mate = nil;
    _assure = nil;
    _car = nil;
    _buyer = nil;
    _cursorView = nil;
}

/**
 导航栏右侧按钮，用于删选
 */
-(void)_rightAction{
        __weak __typeof(self) weakSelf = self;
        if (!self.menu) {
            self.menu = [[JHCustomMenu alloc] initWithDataArr:@[@"补录配偶", @"补录担保人"] origin:CGPointMake(kScreen_Width-130, kNavHeight) width:110 rowHeight:44];
            _menu.delegate = self;
            _menu.dismiss = ^() {
                weakSelf.menu = nil;
            };
//            _menu.arrImgName = @[@"info_icon_1", @"info_icon_2",];
            [self.view addSubview:_menu];
        } else {
            [_menu dismissWithCompletion:^(JHCustomMenu *object) {
                weakSelf.menu = nil;
            }];
        }

    
}
- (void)jhCustomMenu:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select: %ld", indexPath.row);
    if (indexPath.row==1) {
        if (_assure) {
            if (_assure.viewModel.asureArray.count>=4) {
                [JHAlertControllerTool alertTitle:@"提示" mesasge:@"担保人最多只能有4人" confirmHandler:^(UIAlertAction *action) {
                    
                } viewController:self];
                return;
            }
        }
        //担保人
        CreditGuaranteeController *guarantee = [[CreditGuaranteeController alloc] init];
        guarantee.ordernumber = self.ordernumber;
        guarantee.baseNumber = _assure.viewModel.asureArray.count;
        [self _pushViewController:guarantee];
    }else{
        if (_mate) {
            [JHAlertControllerTool alertTitle:@"提示" mesasge:@"配偶最多只能有1人" confirmHandler:^(UIAlertAction *action) {
                
            } viewController:self];
            return;
        }
        CreditTogetherBuyerController *together = [[CreditTogetherBuyerController alloc] init];
        together.ordernumber = self.ordernumber;
        [self _pushViewController:together];
    }
}
//关于导航栏右滑动作禁止，点击返回拦截的操作
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
/**
 点击退出主动拦截
 */
- (void)navigationShouldPopOnBackButton{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确认要关闭初审单录入？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCertain = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //popVC
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:actionCertain];
    [alertController addAction:actionCancel];
    [self  presentViewController:alertController animated:YES completion:nil];
    
}

/**
 加载数据
 */
-(void)_loadData{
    WeakSelf
    if (self.ordernumber) {
        [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kgetorderinfo] HTTPMethod:HttpMethodGet showHud:YES params:[JH_NetWorking addKeyAndUIdForRequest:@{@"ordernumber":self.ordernumber}] completionHandle:^(id result) {
            if ([result[@"code"]isEqualToString:kSuccessCode]) {
               [weakSelf addChildVC:result[@"orderinfo"]];
                
            }else{
                [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
            }

        } errorHandle:^(NSError *error) {
            [weakSelf _creatNoNetWorkView];
        }];
    }
}

/**
 创建子视图，并传递相关的数据
 @param data
 */
-(void)addChildVC:(NSDictionary *)data{
    CarOrderDetailModel *detailModel = [[CarOrderDetailModel alloc]initWithDictionary:data];
    //固定有的三个标题
    NSMutableArray *titles = [NSMutableArray arrayWithObjects:@"购车人",@"车辆信息",@"垫款信息", nil];
    //设置所有子controller
    NSMutableArray *controllers = [NSMutableArray array];
    _buyer = [[CarOrderBuyerController alloc] init];
    _buyer.viewModel = [[CarOrderBuyerViewModel alloc] init];
    _buyer.viewModel.carMan = detailModel.carman;
    _buyer.viewModel.baseInfo = detailModel.baseinfo;
    _buyer.notAllowedEdit = _notAllowedEdit;
    
    _car = [[CarOrderCarInfoController alloc] init];
    _car.viewModel = [[CarOrderCarInfoViewModel alloc] init];
    _car.viewModel.car = detailModel.car;
    _car.viewModel.baseInfo = detailModel.baseinfo;
    _car.notAllowedEdit = _notAllowedEdit;
    
    _advance = [[CarOrderAdvanceController alloc] init];
    _advance.viewModel = [[CarOrderAdvanceViewModel alloc] init];
    _advance.viewModel.advance = detailModel.advance;
    _advance.notAllowedEdit = _notAllowedEdit;
    
    [controllers addObject:_buyer];
    [controllers addObject:_car];
    [controllers addObject:_advance];
    //根据是否有担保人字段插入数据（1）
    if (detailModel.assure) {
        _assure = [[CarOrderGuaranteeController alloc] init];
        _assure.viewModel = [[CarOrderAssureViewModel alloc] init];
        _assure.viewModel.asureArray = detailModel.assure;
        _assure.notAllowedEdit = _notAllowedEdit;
        [controllers insertObject:_assure atIndex:1];
        [titles insertObject:@"担保人" atIndex:1];
    }
    //根据配偶信息的有无插入（1）
    if (detailModel.mate && detailModel.mate.base.name) {
        _mate = [[CarOrderSpouseController alloc] init];
        _mate.viewModel = [[CarOrderMateViewModel alloc]init];
        _mate.viewModel.mate = detailModel.mate;
        _mate.notAllowedEdit = _notAllowedEdit;
        [controllers insertObject:_mate atIndex:1];
        [titles insertObject:@"配偶" atIndex:1];
    }
    WeakSelf
    _cursorView = [[JHMenuControlView alloc]initWithFrame:CGRectMake(0, kNavHeight, CGRectGetWidth(self.view.bounds),menuHeight) withParentViewController:weakSelf withTitles:titles withControllers:controllers withOnePageCount:titles.count];
    //设置子页面容器的高度
    _cursorView.contentViewHeight = kScreen_Height-menuHeight-kNavHeight;
    
    //设置字体和颜色
    //    _cursorView.normalColor = [UIColor blackColor];
    _cursorView.selectedColor = kBaseColor;
    //    _cursorView.selectedFont = [UIFont systemFontOfSize:16];
    //    _cursorView.normalFont = [UIFont systemFontOfSize:13];
    //    _cursorView.backgroundColor = [UIColor whiteColor];
    _cursorView.lineView.backgroundColor = kBaseColor;
    _cursorView.currentIndex = 0;
    [self.view addSubview:_cursorView];
    
    //属性设置完成后，调用此方法绘制界面
    [_cursorView reloadPages];

    //提前加载年限和贷款类型(同步请求)
    NSDictionary *data1= [JH_NetWorking sendSynchronousRequest:[kBaseUrlStr_Local1 stringByAppendingString:kdict] HTTPMethod:HttpMethodGet params:[JH_NetWorking addKeyAndUIdForRequest:@{@"bid":detailModel.car.loanbankid,@"type":@"yeartype",@"info":@"year",@"bankname":detailModel.car.loanbank}]];
    NSDictionary *data2= [JH_NetWorking sendSynchronousRequest:[kBaseUrlStr_Local1 stringByAppendingString:kdict] HTTPMethod:HttpMethodGet params:[JH_NetWorking addKeyAndUIdForRequest:@{@"bid":detailModel.car.loanbankid,@"type":@"yeartype",@"info":@"type",@"bankname":detailModel.car.loanbank}]];
    if ([data1[@"code"]isEqualToString:kSuccessCode]) {
        [JHDownLoadFile addDictionaryToLocol:@"yeartype_year" data:data1[@"combox"]];
    }else{
        
    }
    if ([data2[@"code"]isEqualToString:kSuccessCode]) {
        [JHDownLoadFile addDictionaryToLocol:@"yeartype_type" data:data2[@"combox"]];
    }else{
        
    }
}

/**
 监听计算数据
 */
-(void)_getMortgagehigh{
    //获取最新的车辆高息价格和用款金额并传入垫款信息
    NSString *mortgagehigh = _car.viewModel.car.mortgagehigh;
    _advance.viewModel.advance.mortgagehigh = mortgagehigh;
    float totalPrice = [_advance.viewModel.advance.keepprice floatValue]+[_advance.viewModel.advance.canalsprice floatValue]+[_advance.viewModel.advance.mortgageprice floatValue]+[_advance.viewModel.advance.gopledge floatValue]+[_advance.viewModel.advance.mortgagehigh floatValue]+[_advance.viewModel.advance.mortgagecash floatValue];
    _advance.viewModel.advance.puttotal = [NSString stringWithFormat:@"%.2f",totalPrice];
    _advance.viewModel.advance.money = [NSString stringWithFormat:@"%@",_car.viewModel.car.loanmoney];

    
}

@end
