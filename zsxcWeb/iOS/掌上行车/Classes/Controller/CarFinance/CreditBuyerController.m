//
//  CreditBuyerController.m
//  carFinance
//
//  Created by hyjt on 2017/4/12.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "CreditBuyerController.h"
#import "JHImageViewerWindow.h"

@interface CreditBuyerController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)UITableView *tableView;

@end
static const CGFloat menuHeight = 40;
@implementation CreditBuyerController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.viewModel) {
        
        self.viewModel = [[CreditBuyerViewModel alloc] init];
        [self.viewModel JH_loadTableDataWithData:nil completionHandle:^(id result) {
            
        } errorHandle:^(NSError * error) {
            
        }];
    }
    [self.view addSubview:self.tableView];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-kNavHeight-menuHeight) style:UITableViewStyleGrouped];
            table.delegate     = self;
            table.dataSource   = self;
            
            table;
        });
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.viewModel JH_numberOfRow:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  [self.viewModel JH_heightForCell:indexPath];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  [self.viewModel JH_setUpTableViewCell:indexPath];
}


-(UITableViewCell *)getCell:(UIResponder *)response{
    while (![response isKindOfClass:[UITableViewCell class]]) {
        return [self getCell:response.nextResponder];
    }
    
    return (UITableViewCell *)response;
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell *cell = [self getCell:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //存储输入框数据
    [self.viewModel.model setValue:textField.text forKey:[self.viewModel getData:DataTypeModel WithRow:indexPath.row]];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.viewModel UIViewController:self  willDisplayCell:cell forRowAtIndexPath:indexPath];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //取消编辑事件，用于存储文字
    if ([scrollView isKindOfClass:[self.tableView class]]) {
        [self.tableView endEditing:YES];
    }
}
#pragma mark - selectRow
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.viewModel disSelectRowWithIndexPath:indexPath WithHandle:^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
    }];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //压缩处理图片
    __block NSData *imageData;
    //获取图片的名字
    __block NSDictionary* upData;
    
    
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:^{
            //获取时间戳和当前图片index给图片命名
            NSDate* dat = [NSDate date];
            
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
            imageData = [UIImage compressOriginalImageOnece:image toMaxDataSizeKBytes:kMaxImageSize];
            upData = @{@"fileData":imageData?imageData:[UIImage compressOriginalImageOnece:image toMaxDataSizeKBytes:kMaxImageSize],
                       @"name":@"uploadfile",
                       @"fileName":[NSString stringWithFormat:@"%@.jpg",timeString],
                       @"mimeType":@"image/jpeg"
                       };
            [self uploadImageWithData:upData image:image];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        }];
    }else{
        NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
        //        define the block to call when we get the asset based on the url (below)
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
        {
            ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
            
            NSString *imageFileName = [imageRep filename];
            //获取时间戳和当前图片index给图片命名
            NSDate* dat = [NSDate date];
            
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
            
            upData = @{@"fileData":imageData?imageData:[UIImage compressOriginalImageOnece:image toMaxDataSizeKBytes:kMaxImageSize],
                       @"name":@"uploadfile",
                       @"fileName":imageFileName?imageFileName:[NSString stringWithFormat:@"%@.jpg",timeString],
                       @"mimeType":@"image/jpeg"
                       };
            
        };
        //    get the asset library and fetch the asset based on the ref url (pass in block above)
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        
        [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
        //增加图片选择确定的视图
        JHImageViewerWindow *imageWindows = [[JHImageViewerWindow alloc] initWithFrame:CGRectMake(0, 0,kScreen_Width, kScreen_Height) WithImage:image];
        [imageWindows _setCancelAndCertainButton];
        [picker.view addSubview:imageWindows];
        
        
        [imageWindows setBlock:^(UIImage *img){
            
            [picker dismissViewControllerAnimated:YES completion:^{
                if (upData) {
                    [self uploadImageWithData:upData image:image];
                    
                }else{
                    kTipAlert(@"文件选取失败")
                }
                
            }];
            
        }];
    }
    
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error==nil) {
        NSLog(@"保存照片成功");
    }
}
/**
 上传图片
 */
-(void)uploadImageWithData:(NSDictionary *)data image:(UIImage *)img{
    WeakSelf
    //上传图片
    [JH_NetWorking requestDataAndFormData:[kBaseUrlStr_Local1 stringByAppendingString:kUploadFile] HTTPMethod:HttpMethodPost params:[JH_NetWorking addKeyAndUIdForRequest:@{@"attachmenttype":@"credit"}] formDataArray:@[data] completionHandle:^(id result) {
        if ([result[@"code"]isEqualToString:kSuccessCode]) {
            [MBProgressHUD MBProgressShowSuccess:YES WithTitle:@"上传成功！" view:[UIApplication sharedApplication].keyWindow];
            //根据获取到的数据将Model数据添加
            NSArray *rows = result[@"fileinfo"];
            NSString *filePathKey = [self.viewModel getData:DataTypeFileImagePath WithRow:weakSelf.viewModel.currentIndexPath.row];
            NSString *filegroupKey = [self.viewModel getData:DataTypeFileImageGroup WithRow:weakSelf.viewModel.currentIndexPath.row];;
            
            [weakSelf.viewModel.model setValue:rows[0][@"aturl"] forKey:filePathKey];
            [weakSelf.viewModel.model setValue:rows[0][@"atid"] forKey:filegroupKey];
            //存储输入框数据
            //                    [weakSelf.viewModel.model setValue:image forKey:[weakSelf.viewModel getData:DataTypeModel WithRow:weakSelf.viewModel.currentIndexPath.row]];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[weakSelf.viewModel.currentIndexPath] withRowAnimation:0];
            
        }else{
            [MBProgressHUD MBProgressShowSuccess:NO WithTitle:result[@"info"] view:[UIApplication sharedApplication].keyWindow];
        }
        
    } errorHandle:^(NSError *error) {
        
    }];

    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
