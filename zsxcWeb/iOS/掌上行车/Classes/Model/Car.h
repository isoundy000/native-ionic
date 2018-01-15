#import <UIKit/UIKit.h>

@interface Car : NSObject

@property (nonatomic, strong) NSString * agemoney;
@property (nonatomic, strong) NSString * assess;
@property (nonatomic, strong) NSString * automotivetype;
@property (nonatomic, strong) NSString * bankrate;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * companyrate;
@property (nonatomic, strong) NSString * county;
@property (nonatomic, strong) NSString * firstpay;
@property (nonatomic, strong) NSString * genre_num;
@property (nonatomic, strong) NSString * isboard;
@property (nonatomic, strong) NSString * loanage;
@property (nonatomic, strong) NSString * loanbank;
@property (nonatomic, strong) NSString * loanbankid;
@property (nonatomic, strong) NSNumber * loanmoney;
@property (nonatomic, strong) NSString * loanratio;
@property (nonatomic, strong) NSString * loantype;
@property (nonatomic, strong) NSString * monthpay;
@property (nonatomic, strong) NSString * mortgagehigh;
@property (nonatomic, strong) NSString * owner;
@property (nonatomic, strong) NSString * pactcarprice;
@property (nonatomic, strong) NSString * pactprice;
@property (nonatomic, strong) NSString * pactpriceratio;
@property (nonatomic, strong) NSString * price;
@property (nonatomic, strong) NSString * province;
@property (nonatomic, strong) NSString * realpay;
@property (nonatomic, strong) NSString * realpayratio;
@property (nonatomic, strong) NSString * refundmoney;
@property (nonatomic, strong) NSString * refundmoneyratio;
@property (nonatomic, strong) NSString * registtime;
@property (nonatomic, strong) NSString * remark;
@property (nonatomic, strong) NSString * seatnum;
@property (nonatomic, strong) NSString * vehiclestruct;
@property (nonatomic, strong) NSString * vehicletype;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
