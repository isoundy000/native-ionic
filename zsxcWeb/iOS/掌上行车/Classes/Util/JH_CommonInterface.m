//
//  JH_CommonInterface.m
//  carFinance
//
//  Created by hyjt on 2017/4/12.
//  Copyright © 2017年 haoyungroup. All rights reserved.
//

#import "JH_CommonInterface.h"

@implementation JH_CommonInterface
//从资源包中加载不会占内存
+(UIImage *)LoadImageFromBundle:(NSString *)imageName{
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName
                                                     ofType:nil];
    
    return [UIImage imageWithContentsOfFile:path];
}
/**
 获取当前视图

 @return UIViewController
 */
+ (UIViewController *)presentingVC{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}
/**
 获取viewController
 */
+(UIViewController *)viewController :(UIResponder *)response{
    
    UIResponder *next = response.nextResponder;
    while(next !=nil){
        if([next isKindOfClass:[UIViewController class]]){
            return (UIViewController *)next;
        }
        next = next.nextResponder;
    }
    return nil;
}

/**
 获取keyWindows
 */
+(UIWindow *)getKeyWindows{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    return window;
}
/**
 字典转json的类别
 */
+(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
// 递归获取子视图
- (void)getSub:(UIView *)view andLevel:(int)level {
    NSArray *subviews = [view subviews];
    
    // 如果没有子视图就直接返回
    if ([subviews count] == 0) return;
    
    for (UIView *subview in subviews) {
        
        // 根据层级决定前面空格个数，来缩进显示
        NSString *blank = @"";
        for (int i = 1; i < level; i++) {
            blank = [NSString stringWithFormat:@"  %@", blank];
        }
        
        // 打印子视图类名
        NSLog(@"%@%d: %@", blank, level, subview.class);
        
        // 递归获取此视图的子视图
        [self getSub:subview andLevel:(level+1)];
        
    }
}
//给字符添加上“*”o(╯□╰)o代表必填
+(NSMutableAttributedString *)addNeedSymbol:(NSString *)text{
    text = [NSString stringWithFormat:@"*%@",text];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:text];
    [attribute setAttributes:@{NSForegroundColorAttributeName :[UIColor redColor]} range:NSMakeRange(0, 1)];
    return attribute;
}
@end
