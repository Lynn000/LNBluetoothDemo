//
//  ViewController.m
//  LNBluetoothDemo
//
//  Created by Lynn-Lin on 2017/2/8.
//  Copyright © 2017年 Lynn-Lin. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralViewController.h"

static NSString * const CELLID = @"cellid";

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *connectedPeripheral;
@property (nonatomic,assign) BOOL isBluetoothOn;
@property (nonatomic,strong) NSMutableArray *peripheralArrayM;
@property (weak, nonatomic) IBOutlet UITableView *peripheralTableList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - centralManager delegate
// 蓝牙状态变化调用此方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:
        case CBManagerStateUnauthorized:
        case CBManagerStatePoweredOff:{
            [self showTip];
            self.isBluetoothOn = NO;
            break;
        }
        case CBManagerStatePoweredOn:{
            self.isBluetoothOn = YES;
            break;
        }
        case CBManagerStateUnsupported:{
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持蓝牙功能" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *conform = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:conform];
            [self presentViewController:alertVC animated:YES completion:nil];
            self.isBluetoothOn = NO;
            break;
        }
        case CBManagerStateResetting:{
            self.isBluetoothOn = NO;
            break;
        }
            
        default:
            break;
    }
}
// 扫描到蓝牙设备调用此方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    [self.peripheralArrayM addObject:peripheral];
}
// 连接设备调用此方法
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.centralManager stopScan]; // 苹果官方建议在连接到设备之后,就停止扫描设备,为了节省电量
    self.connectedPeripheral = peripheral;
    
    PeripheralViewController *peripheralVC = [[PeripheralViewController alloc]init];
    peripheralVC.connectedPeripheral = peripheral;
    peripheralVC.title = peripheral.name;
    [self.navigationController pushViewController:peripheralVC animated:YES];
}
// 连接设备失败调用此方法
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
}
// 断开和设备连接调用此方法
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        return ;
    }
    self.connectedPeripheral = nil;
}

#pragma mark - table datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.peripheralArrayM.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELLID];
    }
    CBPeripheral *peripheral = self.peripheralArrayM[indexPath.item];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.description;
    
    return cell;
}
#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *selPeripheral = self.peripheralArrayM[indexPath.item];
    
    [self.centralManager connectPeripheral:selPeripheral options: nil];
}

#pragma mark - response action
- (IBAction)checkBLEStatusAction {
    // 初始化中心设备管理对象
    [self initCentralManager];
}

- (IBAction)startScanAction {
    if (self.isBluetoothOn) {
        // serviceUUIDs 如果传入NSArray<CBUUID *>的数据,会根据传入的服务UUID进行扫描符合要求的设备
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }else {
        [self showTip];
    }
}

#pragma mark - private method
- (void)showTip{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请开启蓝牙" message:@"请确认蓝牙已开启,以保证设备功能正常使用" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:conform];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - init
- (void)initCentralManager{
    if (_centralManager == nil) {
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
}

- (NSMutableArray *)peripheralArrayM {
    if (_peripheralArrayM == nil) {
        _peripheralArrayM = [[NSMutableArray alloc]init];
    }
    return _peripheralArrayM;
}



@end
