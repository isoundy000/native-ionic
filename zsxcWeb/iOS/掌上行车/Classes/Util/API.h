//
//  API.h
//  carFinance
//
//  Created by hyjt on 2017/4/19.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#ifndef API_h
#define API_h
//登录
#define kLogin @"/Api/login"
//上传文件
#define kUploadFile @"/Api/uploadattachment"
//删除征信材料
#define kDeleteFile @"/Api/deleteattachment"
//上传征信
#define kCreditHandle @"/Api/submitcredit"
//数据字典/
#define kdict @"/Api/getcombox"

//订单征信列表
#define korderlist @"/Api/getorderlist"
//征信详情
#define kcreditDetail @"/Api/getOrderCreditDetail"
//获取订单详情
#define kgetorderinfo @"/Api/getorderinfo"
//补录担保人
#define kaddsurety @"/Api/addsurety"
//补录配偶
#define kaddspouse @"/Api/addspouse"
//保存初审单
#define kfirstverifysave @"/Api/firstverifysave"
//获取面签材料
#define kgetvisaattachment @"/Api/getvisaattachment"
//上传面签
#define kuploadattachment @"/Api/uploadattachment"
//删除面签
#define kdeleteattachment @"/Api/deleteattachment"
//面签提交
#define kvisasubmit @"/Api/visasubmit"
//计算费率
#define kcalculateageinfo @"/Api/calculateageinfo"
//注册极光推送
#define kJpushLogin @"http://push.yuuwei.com/index.php/Push/extraPushLogin"
//关闭极光推送
#define kJpushLogout @"http://push.yuuwei.com/index.php/Push/extraLogout"
//获取消息列表
#define kJpushList @"http://push.yuuwei.com/index.php/Push/getExtraPushMessage"
//改变消息状态
#define kJpushSet @"http://push.yuuwei.com/index.php/Push/setExtraPushReadMessage"

#endif /* API_h */
