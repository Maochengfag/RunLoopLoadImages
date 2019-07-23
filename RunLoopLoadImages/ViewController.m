//
//  ViewController.m
//  RunLoopLoadImages
//
//  Created by Mac on 2019/6/28.
//  Copyright © 2019年 Mac. All rights reserved.
//

#import "UIImageView+AddPragram.h"
#import "ViewController.h"
//定义一个block
typedef BOOL(^RunloopBlock)(void);
static NSString *IDENTIFIER = @"IDNETIFIER";
static CGFloat CELL_HEIGHT = 135.5;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
/** 存放任务的数组  */
@property(nonatomic,strong) NSMutableArray* tasks;
/** 任务标记  */
@property(nonatomic,strong) NSMutableArray* tasksKeys;
/** 最大任务数 */
@property(nonatomic,assign) NSInteger  max;
@property(nonatomic,strong) UITableView *listTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView *view = [[UIImageView alloc] init];
    view.downUrl = @"";
    _max = 18;
    _tasks = [NSMutableArray array];
    _tasksKeys = [NSMutableArray array];
    
    self.listTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    [self.view addSubview:self.listTableView];
    //注册cell
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFIER];
    //注册监听
    [self addRunLoopObserver];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.listTableView.frame =
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- tableview Delegate& DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 399;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //不要直接加载图片!! 你将加载图片的代码!都给RunLoop!!
    [self addTask:^BOOL{
        [ViewController addImage1With:cell];
        return YES;
    } withKey:indexPath];
    
    [self addTask:^BOOL{
        [ViewController addImage2With:cell];
        return YES;
    } withKey:indexPath];

    [self addTask:^BOOL{
        [ViewController addImage3With:cell];
        return YES;
    } withKey:indexPath];

    [self addTask:^BOOL{
        [ViewController addLabelWith:cell];
        return YES;
    } withKey:indexPath];
   
    return cell;
}

#pragma mark 内部实现方法

+ (void)addImage1With:(UITableViewCell *)cell{
    [self loadImage:cell FrameX:5 Tag:1];
}

+ (void)addImage2With:(UITableViewCell *)cell{
    [self loadImage:cell FrameX:105 Tag:2];
}

+ (void)addImage3With:(UITableViewCell *)cell{
    [self loadImage:cell FrameX:200 Tag:3];
}

+ (void)addLabelWith:(UITableViewCell *)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor redColor];
    label.text = @"%zd - Drawing index is top priority";
    label.font = [UIFont boldSystemFontOfSize:13];
    [cell.contentView addSubview:label];
    
    [UIView transitionWithView:cell.contentView duration:0.3 options:(UIViewAnimationCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
        [cell.contentView addSubview:label];
    } completion:nil];
}

+ (void)loadImage:(UITableViewCell *)cell FrameX:(NSInteger)x Tag:(NSInteger)tag{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 20, 85, 85)];
    imageView.tag = tag;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionTransitionCrossDissolve) animations:^{
        [cell.contentView addSubview:imageView];
    } completion:nil];
}

#pragma mark - <RunLoop>
#pragma mark -- 添加任务

- (void)addTask:(RunloopBlock)unit withKey:(id)key{
    [self.tasks addObject:unit];
    [self.tasksKeys addObject:key];
    //保证之前没有显示出来的任务,不再浪费时间加载
    if (self.tasks.count > self.max) {
        [self.tasks removeObjectAtIndex:0];
        [self.tasksKeys removeObjectAtIndex:0];
    }
}

#pragma mark 回调函数
static void Callback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void * info){
    ViewController *vc = (__bridge ViewController *)(info);
    if (vc.tasks.count == 0) {
        return;
    }
    
    BOOL result = NO;
    
    while (result == NO && vc.tasks.count) {
        //取出任务
        RunloopBlock unit = vc.tasks.firstObject;
        //执行任务
        result = unit();
        //干掉第一个任务
        [vc.tasks removeObjectAtIndex:0];
        //干掉表示
        [vc.tasksKeys removeObjectAtIndex:0];
    }
}


- (void)addRunLoopObserver{
    //获取当前的runloop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
     //定义一个context
    CFRunLoopObserverContext context = {
        0,
        ( __bridge void*)(self),
        &CFRetain,
        &CFRelease,
        NULL
    };
     //定义一个观察者
    static CFRunLoopObserverRef defaultModeObsever;
    //创建观察者
    defaultModeObsever = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting, YES, NSIntegerMax - 999, &Callback , &context);
    //添加当前Runloop的观察者
    CFRunLoopAddObserver(runloop, defaultModeObsever, kCFRunLoopDefaultMode);
    //c语言有creat 就需要release
    CFRelease(defaultModeObsever);
}

@end
