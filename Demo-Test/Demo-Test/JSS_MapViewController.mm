//
//  JSS_MapViewController.m
//  Demo-Test
//
//  Created by Daniel on 16/6/13.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "JSS_MapViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface JSS_MapViewController ()<BMKGeneralDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate>

@property (strong, nonatomic) UITextField *startCityTf;
@property (strong, nonatomic) UITextField *startAddressTf;
@property (strong, nonatomic) UITextField *endCityTf;
@property (strong, nonatomic) UITextField *endAddressTf;

@property (strong, nonatomic) BMKMapView *mapView;
//声明定位服务对象属性 （负责定位）
@property (strong, nonatomic) BMKLocationService *locationService;
//声明地理位置搜索对象（负责地理编码）
@property (strong, nonatomic) BMKGeoCodeSearch *getCodeSearch;
//声明路线搜索对象
@property (strong, nonatomic) BMKRouteSearch *routeSearch;
//开始路线检索节点
@property (strong, nonatomic) BMKPlanNode *startNode;
//目标路线检索节点
@property (strong, nonatomic) BMKPlanNode *endNode;

@end

@implementation JSS_MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    //创建百度地图主引擎类对象
    BMKMapManager *manager = [[BMKMapManager alloc]init];
    //启动引擎
    [manager start:@"bOyS4fAGvZZCOp3cdHVlZt51BQ7kGNVH" generalDelegate:self];
    */

    //设置边距
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 搭建UI
    [self addSubviews];
    
    //创建定位服务对象
    self.locationService = [[BMKLocationService alloc]init];
    //设置定位服务对象代理
    self.locationService.delegate = self;
    //设置再次定位的最小距离
    self.locationService.distanceFilter = 10;
    
    
    //创建地理位置搜索对象
    self.getCodeSearch = [[BMKGeoCodeSearch alloc]init];
    self.getCodeSearch.delegate = self;
    
    //创建路线搜索对象
    self.routeSearch = [[BMKRouteSearch alloc]init];
    self.routeSearch.delegate = self;
    
    [self leftAction];
}

# pragma mark - 搭建UI方法
- (void)addSubviews {
    //设置BarButtonItem
//    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:@"开始定位" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
//    self.navigationItem.leftBarButtonItem = left;
    self.title = @"地图";
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"关闭定位" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = right;
    
    //地点输入框设置
    self.startCityTf = [[UITextField alloc]initWithFrame:CGRectMake(20, 15, 80, 30)];
    self.startCityTf.placeholder = @"开始城市";
    [self.view addSubview:self.startCityTf];
    
    self.startAddressTf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_startCityTf.frame) + 30, CGRectGetMinY(_startCityTf.frame), CGRectGetWidth(_startCityTf.frame), CGRectGetHeight(_startCityTf.frame))];
    self.startAddressTf.placeholder = @"开始地址";
    [self.view addSubview:self.startAddressTf];
    
    self.endCityTf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(_startCityTf.frame), CGRectGetMaxY(_startCityTf.frame) + 10, CGRectGetWidth(_startCityTf.frame), CGRectGetHeight(_startCityTf.frame))];
    self.endCityTf.placeholder = @"目的城市";
    [self.view addSubview:self.endCityTf];
    
    self.endAddressTf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_endCityTf.frame) + 30, CGRectGetMaxY(_startCityTf.frame) + 10, CGRectGetWidth(_startCityTf.frame), CGRectGetHeight(_startCityTf.frame))];
    self.endAddressTf.placeholder = @"目的地址";
    [self.view addSubview:self.endAddressTf];
    
    //添加路线规划按钮
    UIButton *routeSearch = [UIButton buttonWithType:UIButtonTypeSystem];
    [routeSearch setTitle:@"路线规划" forState:UIControlStateNormal];
    routeSearch.frame = CGRectMake(CGRectGetMaxX(_startAddressTf.frame) + 10, CGRectGetMaxY(_startAddressTf.frame), 80, 30);
    [routeSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [routeSearch addTarget:self action:@selector(routeSearchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:routeSearch];
    
    //添加地图
    self.mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_endAddressTf.frame) + 5, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(_endAddressTf.frame) - 5)];
    //设置当前类为mapView的代理对象
    self.mapView.delegate = self;
    
    [self.mapView setZoomLevel:12];
    //添加到父视图上
    [self.view addSubview:self.mapView];
}

# pragma mark - 开始定位
- (void)leftAction {
    //开启定位服务
    [self.locationService startUserLocationService];
    //在地图上显示用户的位置
    self.mapView.showsUserLocation = YES;
}

# pragma mark - 关闭定位 
- (void)rightAction {
    NSLog(@"点击");
    //关闭定位服务
    [self.locationService stopUserLocationService];
    //设置地图不显示位置
    self.mapView.showsUserLocation = NO;
    //移除标注
    [self.mapView removeAnnotation:[self.mapView.annotations lastObject]];
}

# pragma mark - 路线规划点击事件
- (void)routeSearchAction:(UIButton *)sender {
    //完成正向地理编码
    //1.创建正向编码对象
    BMKGeoCodeSearchOption *geoSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    //2.正向地理编码位置赋值
    geoSearchOption.city = self.startCityTf.text;
    geoSearchOption.address = self.startAddressTf.text;
    //3.执行正向地理位置编码
    [self.getCodeSearch geoCode:geoSearchOption];
}

# pragma mark - BMKLocationService的代理方法
- (void)willStartLocatingUser {
    NSLog(@"开始定位");
}

- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"定位失败");
    NSLog(@"%@",error);
}

//定位成功，再次定位的方法
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    
    //完成地理反编码
    //1.创建反向地理编码对象
    BMKReverseGeoCodeOption *reverseOption = [[BMKReverseGeoCodeOption alloc]init];
    //2.给反向地理编码对象的坐标点赋值
    reverseOption.reverseGeoPoint = userLocation.location.coordinate;
    //3.执行反向地理编码
    [self.getCodeSearch reverseGeoCode:reverseOption];
    
}

#pragma mark - BMKGeoCodeSearch的代理方法
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    //定义大头针标注
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
    //设置标注坐标位置
    annotation.coordinate = result.location;
    //显示当前位置信息
    annotation.title = result.address;
    //添加到地图中
    [self.mapView addAnnotation:annotation];
    //使地图显示该位置
    [self.mapView setCenterCoordinate:result.location animated:YES];
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if ([result.address isEqualToString:self.startAddressTf.text]) {
        self.startNode = [[BMKPlanNode alloc]init];
        //节点坐标赋值
        _startNode.pt = result.location;
        
        //目标节点地理编码
        BMKGeoCodeSearchOption *geoOption = [[BMKGeoCodeSearchOption alloc]init];
        geoOption.city = self.endCityTf.text;
        geoOption.address = self.endAddressTf.text;
        [self.getCodeSearch geoCode:geoOption];
        
        self.endNode = nil;
    }
    else {
        self.endNode = [[BMKPlanNode alloc]init];
        _endNode.pt = result.location;
    }
    
    if (_startNode != nil && _endNode != nil) {
        //开始路线规划
        //1.创建驾车路线规划
        BMKDrivingRoutePlanOption *drivingRouteOption = [[BMKDrivingRoutePlanOption alloc]init];
        //2。指定开始和目标节点
        drivingRouteOption.from = _startNode;
        drivingRouteOption.to = _endNode;
        //3.路线搜索服务对象搜索路线
        [self.routeSearch drivingSearch:drivingRouteOption];
    }
}

//获取自驾路线回调
- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    //删除原来的覆盖物
    NSArray *array = [NSArray arrayWithArray:self.mapView.annotations];
    [self.mapView removeAnnotations:array];
    
    //删除overlays
    array = [NSArray arrayWithArray:self.mapView.overlays];
    [self.mapView removeAnnotations:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        //选取获取到所有路线中的一条
        BMKDrivingRouteLine *planLine = [result.routes objectAtIndex:0];
        //计算路线方案中路段的数目
        NSUInteger size = [planLine.steps count];
        //声明整型变量用来计算所有轨迹点总数
        int planPointCounts = 0;
        for (int i = 0; i < size; i ++) {
            //获取路线中的路段
            BMKDrivingStep *step = planLine.steps[i];
            if (i == 0) {
                //地图显示经纬区域
                BMKCoordinateRegion region;
                region.center = step.entrace.location;
                region.span.latitudeDelta = 0.001;
                region.span.longitudeDelta = 0.001;
                [self.mapView setRegion: region];
            }
            //累计轨迹点
            planPointCounts += step.pointsCount;
        }
        //声明一个结构体数组用来保存所有轨迹点
        BMKMapPoint *tempoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j ++) {
            BMKDrivingStep *transitStep = [planLine.steps objectAtIndex:j];
            int k = 0;
            for (k = 0; k < transitStep.pointsCount; k ++) {
                //获取每个轨迹点的x,y放入数组中
                tempoints[i].x = transitStep.points[k].x;
                tempoints[i].y = transitStep.points[k].y;
                
                i ++;
            }
        }
        //通过轨迹点构造BMKPolyline(折线)
        BMKPolyline *polyLine = [BMKPolyline polylineWithPoints:tempoints count:planPointCounts];
        //添加到地图上
        [self.mapView addOverlay:polyLine];
    }
}

#pragma mark - mapView的代理方法
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //创建要显示的折现
        BMKPolylineView *polylineView = [[BMKPolylineView alloc]initWithOverlay:overlay];
        //设置该线条的填充颜色
        polylineView.fillColor = [UIColor redColor];
        //设置线条颜色
        polylineView.strokeColor = [UIColor redColor];
        //设置折线宽度
        polylineView.lineWidth = 3.0;
        
        return polylineView;
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.locationService.delegate = nil;
    self.getCodeSearch.delegate = nil;
    self.routeSearch.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
