//
//  ScanViewController.m
//  ZFScanCode
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ScanViewController.h"
#import "ZFScanViewController.h"
#include <math.h>
static int nowfile;
static int dataCont;
static BOOL isover = NO;
@interface ScanViewController ()

@property (nonatomic, strong) UIButton * scanButton;//扫描按钮
@property (nonatomic, strong) UIButton * backDataButton;//回退数据按钮
@property (nonatomic, strong) UILabel * resultLabel;//显示扫描结果
@property (nonatomic, strong) UIButton * mergeFileButton;//合并文件按钮
@property (nonatomic, strong) NSMutableArray * mergeData;//需要合并的数据都放到array
@property (nonatomic, strong) NSMutableString * filename;

@end

@implementation ScanViewController

- (void)viewWillAppear:(BOOL)animated{
    if (_mergeData.count != 0) {
        self.resultLabel.text = [NSString stringWithFormat:@"已经扫描了%lu个文件",(unsigned long)_mergeData.count];
    }else{
        self.resultLabel.text = @"快快扫描要导出来的文件吧！";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZFWhite;
    _mergeData = [[NSMutableArray alloc]initWithCapacity:10];
    //NSMutableString *filename = [NSMutableString stringWithString:@""];
    //filename = [self generateFilenameWithindex:0 len:3];
    //generateFilename(filename, 0, 3);
    //扫描按钮
    self.scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.scanButton.frame = CGRectMake(0, SCREEN_HEIGHT - 100, 100, 45);
    [self.scanButton setTitle:@"扫描文件" forState:UIControlStateNormal];
    [self.scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanButton];
    
    //回退按钮 扫描多个文件最后一次容易错误要支持回退
    self.backDataButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backDataButton.frame = CGRectMake(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT - 100, 100, 45);
    [self.backDataButton setTitle:@"回退文件" forState:UIControlStateNormal];
    [self.backDataButton addTarget:self action:@selector(backDataAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backDataButton];
    
    //显示扫描结果
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 100)];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.text = @"快快扫描要导出来的文件吧！";
    [self.view addSubview:self.resultLabel];
    
    //合并文件按钮
    self.mergeFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.mergeFileButton.frame = CGRectMake(SCREEN_WIDTH -100, SCREEN_HEIGHT - 100, 100, 45);
    [self.mergeFileButton setTitle:@"合并文件" forState:UIControlStateNormal];
    [self.mergeFileButton addTarget:self action:@selector(mergeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mergeFileButton];
}

-(NSString *)appearFileName:(NSInteger)fileCount{
    NSArray *arr = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
    NSString *fileName = @"扫描中";
    int nowFile = 0;
    for (int j = 0; j<26; j++) {
        for (int k = 0; k<26; k++) {
            nowFile ++;
            if (fileCount == nowFile) {
                fileName = [NSString stringWithFormat:@"当前扫描的文件名字是：x%@%@",arr[j],arr[k]];
                return fileName;
            }
        }
    }
    return fileName;
}

void generateFilename(NSMutableString *filename, int index, int length) {
    if (index >= length) {
        nowfile ++;
        if (nowfile == dataCont) {
            NSLog(@"current filename is:%@", filename);
            isover = YES;
        }
        NSLog(@"%@", filename);
        return;
    }
    
    char startLetter = (index == 0) ? 'x' : 'a';
    char endLetter = (index == 0) ? 'x' : 'z';
    
    for (char letter = startLetter; letter <= endLetter; letter++) {
        if (isover) {
            break;
        }
        [filename appendFormat:@"%c", letter];
        generateFilename(filename, index + 1, length);
        if (!isover) {
            [filename deleteCharactersInRange:NSMakeRange(index, 1)];
        }
    }
}

-(NSString *) generateFilenameWithindex:(int)index len:(int)length {
    if (index >= length) {
        nowfile ++;
        NSLog(@"%@", self.filename);
        if (nowfile == 600) {
            self.filename = [[NSMutableString alloc]initWithString:self.filename];
            return self.filename;
        }
        return  @"";
    }
    char startLetter = (index == 0) ? 'x' : 'a';
    char endLetter = (index == 0) ? 'x' : 'z';
    for (char letter = startLetter; letter <= endLetter; letter++) {
        NSLog(@"letter is %c",letter);
        if (nowfile == 600) {
            break;;
        }
        [self.filename appendFormat:@"%c", letter];
        [self generateFilenameWithindex:index+1 len:length];
        if (nowfile != 600) {
            [self.filename deleteCharactersInRange:NSMakeRange(index, 1)];
        }
    }
    NSLog(@"all is done");
    return self.filename;
}

/**
 *  扫描件
 */
- (void)scanAction:(UIButton *)sender{
    //self.resultLabel.text = @"快快扫描要导出来的文件吧！";
    ZFScanViewController * vc = [[ZFScanViewController alloc] init];
    __weak typeof (ZFScanViewController) *weakVc = vc;
    weakVc.returnScanBarCodeValue = ^(NSString * barCodeString){
        if (![_mergeData containsObject:barCodeString]) {
            [_mergeData addObject:barCodeString];
            dataCont = (int)_mergeData.count;
            int len = ceil(log(_mergeData.count) / log(26));
            int fileNameLen = (len < 3) ? 3 : len;;
            NSMutableString *filename = [NSMutableString stringWithString:@""];
            isover = NO;
            nowfile = 0;
            generateFilename(filename, 0, fileNameLen);
            weakVc.scanStateLabel.text = [NSString stringWithFormat:@"当前扫描的文件名字是：%@",filename];
            //weakVc.scanStateLabel.text = [self appearFileName:_mergeData.count];
        }else{
            //提示已经扫描过了
            UIAlertController * view = [UIAlertController alertControllerWithTitle:@"已经扫描过了" message:@"请扫码下一个" preferredStyle:UIAlertControllerStyleActionSheet];
//            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好滴" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [weakVc.session startRunning];
//            }];
//            [view addAction:ok];
            [weakVc presentViewController:view animated:YES completion:nil];
           // [self performSelector:@selector(dismiss:) withObject:view afterDelay:3.0];
            /**
            * 定制了延时执行的任务，不会阻塞线程，在主线程和子线程中都可以，效率较高（推荐使用）。
            * 此方式在可以在参数中选择执行的线程。
            * 是一种非阻塞的执行方式， 没有找到取消执行的方法。
            */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"aaaa6666777");
                [view dismissViewControllerAnimated:YES completion:nil];
             });
        }
    };
    weakVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:weakVc animated:YES completion:nil];
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}

//合并文件事件

- (void)mergeAction:(UIButton *)sender{
    NSMutableData *resData = [[NSMutableData alloc]init];
    for (int i = 0; i<_mergeData.count; i++) {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:_mergeData[i] options:0];
        [resData appendData:data];
    }
    if (resData.length != 0) {
        [self writeToFile:resData];
    }else{
        [self showMergeFileState];
    }
}

- (void)backDataAction:(UIButton *)sender{
    if (_mergeData.count != 0) {
        [_mergeData removeLastObject];
        if (_mergeData.count != 0) {
            self.resultLabel.text = [NSString stringWithFormat:@"已经扫描了%lu个文件",(unsigned long)_mergeData.count];
        }else{
            self.resultLabel.text = @"快快扫描要导出来的文件吧！";
        }
    }else{
        
    }
}

- (void)writeToFile:(NSData*)data{
    // 得到Documents路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // NSData写入文件
       // 创建一个存放NSData数据的路径
    NSString *fileDataPath = [docPath stringByAppendingPathComponent:@"result.tar.gz"];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:fileDataPath]){
        NSLog(@"文件已经存在");
        [self showMergeFileState];
        return;
    }else{
        [data writeToFile:fileDataPath atomically:YES];
    }
    self.resultLabel.text = [NSString stringWithFormat:@"当前扫描了%lu个文件\n，合并的文件大小是:%llu\n",(unsigned long)_mergeData.count,[[manager attributesOfItemAtPath:fileDataPath error:nil] fileSize]];
    NSURL *url = [NSURL fileURLWithPath:fileDataPath];
    //提示用户确认分享文件
    UIAlertController * view = [UIAlertController alertControllerWithTitle:@"确认分享文件" message:@"请确认" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好滴" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airdropShare:url];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"暂不分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [view dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [view addAction:ok];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}

- (void)showMergeFileState{
    // 得到Documents路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // NSData写入文件
       // 创建一个存放NSData数据的路径
    NSString *fileDataPath = [docPath stringByAppendingPathComponent:@"result.tar.gz"];
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:fileDataPath]){
        self.resultLabel.text = [NSString stringWithFormat:@"当前扫描了%lu个文件\n，之前合并的文件大小是:%llu\n赶快扫描新的文件吧！",(unsigned long)_mergeData.count,[[manager attributesOfItemAtPath:fileDataPath error:nil] fileSize]];
        NSURL *url = [NSURL fileURLWithPath:fileDataPath];
        [self airdropShare:url];
    }else{
        self.resultLabel.text = @"还没有扫描结果，快快扫起来！";
    }
}

-(void)airdropShare:(NSURL *)url{
    NSArray *objectsToShare = @[url];
    //airdrop 共享文件
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    UIActivityViewControllerCompletionWithItemsHandler shareBlock = ^(NSString *activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"activityType :%@",activityType);
        if (completed) {
            NSLog(@"share completed");
            //删除文件，清除缓存
            [self removeFileCacheData];
        }else{
            NSLog(@"share cancel");
        }
    };
    controller.completionWithItemsHandler = shareBlock;
    [self presentViewController:controller animated:YES completion:nil];
    
}
-(void)removeFileCacheData{
    // 得到Documents路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // NSData写入文件
       // 创建一个存放NSData数据的路径
    NSString *fileDataPath = [docPath stringByAppendingPathComponent:@"result.tar.gz"];
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:fileDataPath]){
        [manager removeItemAtPath:fileDataPath error:nil];
        [_mergeData removeAllObjects];
        self.resultLabel.text = @"还没有扫描结果，快快扫起来！";
    }else{
        NSLog(@"shared data is not found");
    }
}

#pragma mark - 横竖屏适配

/**
 *  PS：size为控制器self.view的size，若图表不是直接添加self.view上，则修改以下的frame值
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    
    self.scanButton.frame = CGRectMake((SCREEN_HEIGHT - 100) / 2, SCREEN_WIDTH - 100, 100, 30);
    
    //横屏(转前是横屏，转后是竖屏)
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        
        self.resultLabel.frame = CGRectMake(0, 200, SCREEN_HEIGHT, 100);
        
    //竖屏(转前是竖屏，转后是横屏)
    }else{
        self.resultLabel.frame = CGRectMake(0, 80, SCREEN_HEIGHT, 100);
        
    }
}

@end
