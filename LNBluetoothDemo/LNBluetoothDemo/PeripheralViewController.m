//
//  PeripheralViewController.m
//  LNBluetoothDemo
//
//  Created by Lynn-Lin on 2017/2/8.
//  Copyright © 2017年 Lynn-Lin. All rights reserved.
//

#import "PeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface PeripheralViewController ()<CBPeripheralDelegate>
@property (nonatomic,strong) UILabel *deviceUUIDLabel;
@property (nonatomic,strong) CBCharacteristic *writeCharacter;
@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.connectedPeripheral.delegate = self;
    
    self.deviceUUIDLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 335, 100)];
    self.deviceUUIDLabel.numberOfLines = 0;
    self.deviceUUIDLabel.text = self.connectedPeripheral.identifier.description;
    [self.view addSubview:self.deviceUUIDLabel];
    
    UIButton *searchServiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchServiceBtn setTitle:@"搜索服务" forState:UIControlStateNormal];
    [searchServiceBtn addTarget:self action:@selector(searchServiceBtnAction) forControlEvents:UIControlEventTouchUpInside];
    searchServiceBtn.frame = CGRectMake(50, 250, 275, 30);
    [self.view addSubview:searchServiceBtn];
    
    UIButton *writeChBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeChBtn setTitle:@"写值" forState:UIControlStateNormal];
    [writeChBtn addTarget:self action:@selector(writeChBtnAction) forControlEvents:UIControlEventTouchUpInside];
    writeChBtn.frame = CGRectMake(50, 300, 275, 30);
    [self.view addSubview:writeChBtn];
    
    UIButton *readRSSIBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [readRSSIBtn setTitle:@"读取信号强度" forState:UIControlStateNormal];
    [readRSSIBtn addTarget:self action:@selector(readRSSIBtnAction) forControlEvents:UIControlEventTouchUpInside];
    readRSSIBtn.frame = CGRectMake(50, 250, 275, 30);
    [self.view addSubview:readRSSIBtn];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Peripheral delegate
// 发现设备服务之后调用此方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        // 判断需要的服务 进一步进行扫描特征
        if ([service.UUID.description isEqualToString:@"180D"]) {
            // 同样的 NSArray<CBUUID *> 传入对应需要特征的UUID数组,以筛选需要的特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
// 选择服务搜索特征调用此方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for (CBCharacteristic *characteristic in service.characteristics) {
        // 判断需要的特征 进行对应的操作 比如读取值
        if ([characteristic.UUID.description isEqualToString:@"E14"]) {
            // 读取特征值 一般这种方法用于读取静态值
            [peripheral readValueForCharacteristic:characteristic];
            return ;
        }
        
        if ([characteristic.UUID.description isEqualToString:@"H12"]) {
            // 对于动态值 采取订阅的方式 进行获取信息 通过通知的形式进行信息的传递
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            return ;
        }
        // 记录要存储的特征
        if ([characteristic.UUID.description isEqualToString:@"w"]) {
            self.writeCharacter = characteristic;
            // 读取特征值 一般这种方法用于读取静态值
            [peripheral readValueForCharacteristic:characteristic];
            return ;
        }
        // 特征的属性(CBCharacteristicProperties) 会显示此特征是否可读 可写 等权限characteristic.properties
        /*
         CBCharacteristicPropertyBroadcast												= 0x01,
         CBCharacteristicPropertyRead													= 0x02,
         CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
         CBCharacteristicPropertyWrite													= 0x08,
         CBCharacteristicPropertyNotify													= 0x10,
         CBCharacteristicPropertyIndicate												= 0x20,
         CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
         CBCharacteristicPropertyExtendedProperties										= 0x80,
         CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
         CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
         */
    }
}
// 读取特征值之后 调用此方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    // 获取特征值
    NSData *chData = characteristic.value;
    // 对读取的值做相应的操作...
}
// 采取订阅方式获取特征值 获取通知之后 调用此方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        [error localizedDescription];
        return ;
    }
    // 获取特征值
    NSData *chData = characteristic.value;
    // 对读取的值做相应的操作...
}
// 写入特征值之后 回调此代理方法
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        [error localizedDescription];
        return ;
    }
    // 写入成功 进行相应提示或其他操作
}
// 读取设备信号强度时调用此方法
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (error) {
        [error localizedDescription];
        return ;
    }
    // 显示强度
    NSString *labelStr = self.deviceUUIDLabel.text;
    self.deviceUUIDLabel.text = [labelStr stringByAppendingString:RSSI.description];
}
// 设备名称更改之后调用此方法
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    self.title = peripheral.name;
}

#pragma mark - response action
- (void)searchServiceBtnAction {
    // serviceUUIDs 入参有值的话 NSArray<CBUUID *>,会根据数组中的UUID进行查找服务
    [self.connectedPeripheral discoverServices:nil];
}

- (void)writeChBtnAction{
    NSString *writeStr = @"write";
    NSData *writeData = [writeStr dataUsingEncoding:NSUTF16StringEncoding];
    // 写入有两种类型 CBCharacteristicWriteWithResponse 会调用代理方法,告知是否成功
    //             CBCharacteristicWriteWithoutResponse 不会调用代理方法,直接写入数据,效率更高一些
    [self.connectedPeripheral writeValue:writeData forCharacteristic:self.writeCharacter type:CBCharacteristicWriteWithResponse];
}

- (void)readRSSIBtnAction {
    [self.connectedPeripheral readRSSI];
}
@end
