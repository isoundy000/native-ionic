//
//  CarSignDetailController.m
//  掌上行车
//
//  Created by hyjt on 2017/5/11.
//
//

#import "CarSignDetailController.h"
#import "JH_PrivateHelper.h"
#import "NSString+ChangeTime.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <TZImagePickerController.h>
#import "TypicatTextView.h"
#import "CollectionViewCell.h"
#import "AddCollectionViewCell.h"
@interface CarSignDetailController ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate>
@property(nonatomic,strong)BMKLocationService *locService;//定位管理
@property(nonatomic,strong)BMKGeoCodeSearch *getCodeSearch;//地理编码
@property(nonatomic,strong)UICollectionView *collectionView;//布局
//@property (nonatomic ,strong) NSMutableArray *imageArray;
@property (nonatomic ,strong) NSMutableArray *imageDataArray;
@property (nonatomic ,strong) TypicatTextView *picker;
@property (nonatomic ,strong) NSString *type;
@end

@implementation CarSignDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"面签资料";
    [self _loadBaseData];
    [self _loadLocation];
    //默认加载第一个数据
    _type = [JHDownLoadFile getArrayByKey:@"visatype"][0][@"text"];
    [self _creatSignView];
    [self loadImageDataByType:_type];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交审核" style:0 target:self action:@selector(_visaSubmit)];
}

/**
 提交面签
 */
-(void)_visaSubmit{
    
    [JHAlertControllerTool alertTitle:@"确认提交" mesasge:@"提交后将无法修改，您确定要提交面签材料吗？" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *action) {
        //提交
        [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kvisasubmit] HTTPMethod:HttpMethodPost showHud:YES params:[JH_NetWorking addKeyAndUIdForRequest:@{@"ordernumber":self.signModel.ordernumber}] completionHandle:^(id result) {
            if ([result[@"code"]isEqualToString:kSuccessCode]) {
                [MBProgressHUD MBProgressShowSuccess:YES WithTitle:@"提交成功" view:[UIApplication sharedApplication].keyWindow];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
            }
            [self.collectionView reloadData];
        } errorHandle:^(NSError *error) {
            [self _creatNoNetWorkView];
        }];
        
    } cancleHandler:^(UIAlertAction *action) {
        
    } viewController:self];
}

/**
 加载图片信息

 @param type 面签材料类型
 */
-(void)loadImageDataByType:(NSString *)type{
    self.imageDataArray = [NSMutableArray array];
    _picker.pickerLabel.text = type;
    [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kgetvisaattachment] HTTPMethod:HttpMethodGet showHud:YES params:[JH_NetWorking addKeyAndUIdForRequest:@{@"ordernumber":self.signModel.ordernumber,@"class":type}] completionHandle:^(id result) {
        if ([result[@"code"]isEqualToString:kSuccessCode]) {
            self.imageDataArray = result[@"fileinfo"];
        }else{
            [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
        }
        [self.collectionView reloadData];
    } errorHandle:^(NSError *error) {
        [self _creatNoNetWorkView];
    }];
    
}
/**
 加载征信基础信息
 */
-(void)_loadBaseData{
    if (self.signModel) {
        self.labCustomer.text = [NSString stringWithFormat:@"客户：%@ %@",self.signModel.customname,self.signModel.customidnumber];
        self.labOrderNumber.text = [NSString stringWithFormat:@"项目编号：%@",self.signModel.ordernumber];
        self.labCreatTime.text = [NSString stringWithFormat:@"录入时间：%@",[NSString changeTimeIntervalToSecond:@([self.signModel.orderaddtime longLongValue])]];
        //处理项目状态
        NSString *statusText = [NSString stringWithFormat:@"项目状态：%@",self.signModel.orderstatus];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:statusText];
        [attribute setAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} range:NSMakeRange(5, statusText.length-5)];
        self.labStatus.attributedText = attribute;
    }
    
}

/**
 获取定位
 */
-(void)_loadLocation{
    //定位管理器
    //初始化BMKLocationService
    //初始化BMKLocationService
    if (!_locService) {
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
    }
    if (!_getCodeSearch) {
        _getCodeSearch = [[BMKGeoCodeSearch alloc] init];
        _getCodeSearch.delegate = self;
    }
    //授权情况
    if (![JH_PrivateHelper checkLocationAuthorizationStatus]) {
        return;
    }
    //启动LocationService
    [_locService startUserLocationService];

    
}
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{

    //1.创建反向地理编码选项对象
    BMKReverseGeoCodeOption *reverseOption=[[BMKReverseGeoCodeOption alloc]init];
    //2.给反向地理编码选项对象的坐标点赋值
    reverseOption.reverseGeoPoint=userLocation.location.coordinate;
    //3.执行反地理编码
    [_getCodeSearch reverseGeoCode:reverseOption];
    
}
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    BMKAddressComponent *component=[[BMKAddressComponent alloc]init];
    component=result.addressDetail;
    // 位置名
    self.labLocation.text = result.address?result.address:@"定位出错！";
    //停止定位
    [_locService stopUserLocationService];
}
-(NSString *)isNullString:(NSString *)str{
    if (str==nil||[str isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return str;
}
#pragma mark -面签资料

-(void)_creatSignView{

    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 240+10, kScreen_Width, 50)];
    baseView.backgroundColor = [UIColor whiteColor];
    _picker = [[TypicatTextView alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width-20, 30) withType:TypicalViewPicker withTitle:@"选择面签材料类型:" withText:_type withAddInfo:@"" titleArray:[JHDownLoadFile getArrayByKey:@"visatype"] withNecessary:NO];
    WeakSelf
    [_picker setPickerBlock:^(NSString *value,NSString *text,NSString *typical){
        _type = text;
        [weakSelf loadImageDataByType:text];
    }];
    
    [baseView addSubview:_picker];
    [self.view addSubview:baseView];
    [self.view addSubview:self.collectionView];
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayOut = [[UICollectionViewFlowLayout alloc] init];
        //        flowLayOut.minimumInteritemSpacing = 11;
        //        flowLayOut.minimumLineSpacing = 11;
        flowLayOut.itemSize = CGSizeMake(kScreen_Width/2-20, kScreen_Width/2*3/4);
        flowLayOut.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 240+60, kScreen_Width, kScreen_Height-240-60) collectionViewLayout:flowLayOut];
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[AddCollectionViewCell class] forCellWithReuseIdentifier:@"identifier"];
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        //        self.collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}
#pragma mark ---------collectionView代理方法--------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.imageDataArray.count + 1 ;

}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AddCollectionViewCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    
    if (self.imageDataArray.count == 0) {
        return cell1;
        
    }else{
        
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        
        if (indexPath.item + 1 > self.imageDataArray.count ) {
            
            return cell1;
            
            
        }else{
            
            NSDictionary *imageData = self.imageDataArray[indexPath.item];
            [cell.imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",kBaseUrlStr_Local1,imageData[@"aturl"]]] placeholderImage:[UIImage imageNamed: @"p1.jpg"]];

            [cell.imageV addSubview:cell.deleteButotn];
            cell.deleteButotn.tag = indexPath.item + 100;
            [cell.deleteButotn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        }

        return cell;
    }
    
}
-(void)deleteImage:(UIButton *)btn{
    NSInteger index = btn.tag - 100;
    //    NSLog(@"index=%ld",index);
    //    NSLog(@"+++%ld",self.imageDataArray.count);
    //    NSLog(@"---%ld",self.imageArray.count);
    NSDictionary *imageData = self.imageDataArray[index];
    [JHAlertControllerTool alertTitle:@"提示" mesasge:@"确认删除面签照片？" preferredStyle:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction * action) {
        
        //移除显示图片数组imageArray中的数据
        [JH_NetWorking requestData:[kBaseUrlStr_Local1 stringByAppendingString:kdeleteattachment] HTTPMethod:HttpMethodPost showHud:YES params:[JH_NetWorking addKeyAndUIdForRequest:@{@"attachmenttype":@"visa",@"ordernumber":self.signModel.ordernumber,@"atid":imageData[@"atid"],@"aturl":imageData[@"aturl"]}] completionHandle:^(id result) {
            if ([result[@"code"]isEqualToString:kSuccessCode]) {
                
                [MBProgressHUD MBProgressShowSuccess:YES WithTitle:@"删除成功！" view:[UIApplication sharedApplication].keyWindow];
                [self loadImageDataByType:_type];
                
            }else{
                [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
            }
        } errorHandle:^(NSError *error) {
            
        }];
        
    } cancleHandler:^(UIAlertAction * action) {
        
    } viewController:self];
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item + 1 > self.imageDataArray.count ) {
        NSLog(@"上传");
        [self submitPictureToServer];
    }else{
        
    }
    
}
-(void)submitPictureToServer{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.allowPickingVideo = NO;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}

-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    NSDictionary *params = [JH_NetWorking addKeyAndUIdForRequest:@{@"attachmenttype":@"visa",@"ordernumber":self.signModel.ordernumber,@"class":_type,@"tag":@"visa"}];

    for (int i = 0; i<photos.count; i++) {
        NSMutableArray *formDataArray = [[NSMutableArray alloc] init];
        UIImage *image = photos[i];
        //获取时间戳和当前图片index给图片命名
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        
        NSTimeInterval a=[dat timeIntervalSince1970];
        
        NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
        
        NSDictionary *data = @{@"fileData":[UIImage compressOriginalImageOnece:image toMaxDataSizeKBytes:kMaxImageSize],
                               @"name":@"uploadfile",
                               @"fileName":[NSString stringWithFormat:@"%@%d.jpg",timeString,i],
                               @"mimeType":@"image/jpeg"
                               };
        [formDataArray addObject:data];
#warning 由于服务器不支持多图上传，故采用单张多线程操作
        [JH_NetWorking requestDataAndFormData:[kBaseUrlStr_Local1 stringByAppendingString:kuploadattachment] HTTPMethod:HttpMethodPost params:params formDataArray:formDataArray completionHandle:^(id result) {
            if ([result[@"code"]isEqualToString:kSuccessCode]) {
                [self loadImageDataByType:_type];
            }else{
                [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
            }
        } errorHandle:^(NSError *error) {
            
        }];
    }
    
}



@end
