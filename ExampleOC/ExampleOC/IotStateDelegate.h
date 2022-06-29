//
//  IotStateDelegate.h
//  ExampleOC
//
//  Created by ADMIN on 2022/5/25.
//

#ifndef IotStateDelegate_h
#define IotStateDelegate_h

/*
 * @brief 设备上线与下线回调
 * @param online     : true:上线 false:下线
 * @param deviceId   : 设备id
 * @param productId  : 产品型号id
 */
//func onDeviceOnOffline(online:Bool,deviceId:String,productId:String)
/*
 * @brief 设备发生行为改变
 * @param deviceId     : 设备id
 * @param actionType   : add:绑定  delete:解绑
 */
//func onDeviceActionUpdated(deviceId:String,actionType:String)
/*
 * @brief 设备发生属性改变
 * @param deviceId       : 设备id
 * @param deviceNumber   : 设备号id
 * @param props          : 被改变的属性
 */
//func onDevicePropertyUpdated(deviceId:String,deviceNumber:String,props:[String:Any]?)

@protocol IotStateDelegate
@required
-(void)DeviceStateUpdate:(BOOL)onoff deviceId:(NSString*)deviceId productId:(NSString*)productId;
@required
-(void)DeviceActionUpdated:(NSString*)deviceId actionType:(NSString*)actionType;
@required
-(void)DevicePropertyUpdated:(NSString*)deviceId deviceNumber:(NSString*)deviceNumber props:(NSDictionary*)props;
@end

@protocol IotCallbackDelegate

@required
-(void)filterResult:(int)errCode errMessage:(NSString*)errMessage;

@end

#endif /* IotStateDelegate_h */
