//
//  CarOrderCarInfoController.h
//  掌上行车
//
//  Created by hyjt on 2017/5/8.
//
//

#import "Root_BaseController.h"
#import "CarOrderCarInfoViewModel.h"
@interface CarOrderCarInfoController : Root_BaseController
@property(nonatomic,strong)CarOrderCarInfoViewModel *viewModel;
@property(nonatomic,assign)BOOL notAllowedEdit;
@end
