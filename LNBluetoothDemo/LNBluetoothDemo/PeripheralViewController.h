//
//  PeripheralViewController.h
//  LNBluetoothDemo
//
//  Created by Lynn-Lin on 2017/2/8.
//  Copyright © 2017年 Lynn-Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface PeripheralViewController : UIViewController
@property (nonatomic,strong) CBPeripheral *connectedPeripheral;
@end
