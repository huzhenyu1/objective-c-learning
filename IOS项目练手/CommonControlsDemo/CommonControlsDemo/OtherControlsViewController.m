//
//  OtherControlsViewController.m
//  CommonControlsDemo
//
//  其他控件演示：Switch, Slider, Segment, Picker, DatePicker, Progress, ActivityIndicator
//

#import "OtherControlsViewController.h"

@interface OtherControlsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UISwitch *switchControl;
@property (strong, nonatomic) UILabel *switchLabel;

@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *sliderLabel;

@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) UILabel *segmentLabel;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray<NSString *> *cities;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation OtherControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"其他控件演示";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.cities = @[@"北京", @"上海", @"广州", @"深圳", @"杭州"];

    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 创建 ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.scrollView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:self.scrollView];

    // 1. UISwitch
    [self addSectionTitle:@"1. UISwitch（开关）" yOffset:&yOffset];

    self.switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(padding, yOffset, 51, 31)];
    self.switchControl.on = YES;
    [self.switchControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.switchControl];

    self.switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.switchControl.frame) + 10, yOffset, 200, 31)];
    self.switchLabel.text = @"开关：已打开";
    self.switchLabel.font = [UIFont systemFontOfSize:16];
    [self.scrollView addSubview:self.switchLabel];
    yOffset += 60;

    // 2. UISlider
    [self addSectionTitle:@"2. UISlider（滑块）" yOffset:&yOffset];

    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 31)];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 100;
    self.slider.value = 50;
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.slider];
    yOffset += 40;

    self.sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 30)];
    self.sliderLabel.text = @"当前值：50";
    self.sliderLabel.textAlignment = NSTextAlignmentCenter;
    self.sliderLabel.font = [UIFont systemFontOfSize:16];
    [self.scrollView addSubview:self.sliderLabel];
    yOffset += 50;

    // 3. UISegmentedControl
    [self addSectionTitle:@"3. UISegmentedControl（分段控制器）" yOffset:&yOffset];

    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"选项1", @"选项2", @"选项3"]];
    self.segmentControl.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 32);
    self.segmentControl.selectedSegmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.segmentControl];
    yOffset += 40;

    self.segmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 30)];
    self.segmentLabel.text = @"选择了：选项1";
    self.segmentLabel.textAlignment = NSTextAlignmentCenter;
    self.segmentLabel.font = [UIFont systemFontOfSize:16];
    [self.scrollView addSubview:self.segmentLabel];
    yOffset += 50;

    // 4. UIPickerView
    [self addSectionTitle:@"4. UIPickerView（选择器）" yOffset:&yOffset];

    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, yOffset, screenWidth, 150)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.scrollView addSubview:self.pickerView];
    yOffset += 160;

    // 5. UIDatePicker
    [self addSectionTitle:@"5. UIDatePicker（日期选择器）" yOffset:&yOffset];

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 200);
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.datePicker];
    yOffset += 220;

    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 30)];
    [self updateDateLabel];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.font = [UIFont systemFontOfSize:16];
    [self.scrollView addSubview:self.dateLabel];
    yOffset += 50;

    // 6. UIProgressView
    [self addSectionTitle:@"6. UIProgressView（进度条）" yOffset:&yOffset];

    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 4)];
    self.progressView.progress = 0;
    [self.scrollView addSubview:self.progressView];
    yOffset += 20;

    UIButton *progressButton = [UIButton buttonWithType:UIButtonTypeSystem];
    progressButton.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
    [progressButton setTitle:@"模拟加载进度" forState:UIControlStateNormal];
    progressButton.backgroundColor = [UIColor systemBlueColor];
    [progressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    progressButton.layer.cornerRadius = 8;
    [progressButton addTarget:self action:@selector(startProgress) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:progressButton];
    yOffset += 60;

    // 7. UIActivityIndicatorView
    [self addSectionTitle:@"7. UIActivityIndicatorView（加载指示器）" yOffset:&yOffset];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = CGPointMake(screenWidth / 2, yOffset + 30);
    [self.scrollView addSubview:self.activityIndicator];
    yOffset += 70;

    UIButton *indicatorButton = [UIButton buttonWithType:UIButtonTypeSystem];
    indicatorButton.frame = CGRectMake(padding, yOffset, screenWidth - 2 * padding, 44);
    [indicatorButton setTitle:@"切换加载指示器" forState:UIControlStateNormal];
    indicatorButton.backgroundColor = [UIColor systemGreenColor];
    [indicatorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    indicatorButton.layer.cornerRadius = 8;
    [indicatorButton addTarget:self action:@selector(toggleActivity) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:indicatorButton];
    yOffset += 60;

    // 设置 ScrollView 的 contentSize
    self.scrollView.contentSize = CGSizeMake(screenWidth, yOffset + 20);
}

- (void)addSectionTitle:(NSString *)title yOffset:(CGFloat *)yOffset {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, *yOffset, [UIScreen mainScreen].bounds.size.width - 40, 30)];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor systemBlueColor];
    [self.scrollView addSubview:titleLabel];
    *yOffset += 35;
}

#pragma mark - Actions

- (void)switchChanged:(UISwitch *)sender {
    self.switchLabel.text = sender.isOn ? @"开关：已打开" : @"开关：已关闭";
}

- (void)sliderChanged:(UISlider *)sender {
    self.sliderLabel.text = [NSString stringWithFormat:@"当前值：%.0f", sender.value];
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    NSString *title = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    self.segmentLabel.text = [NSString stringWithFormat:@"选择了：%@", title];
}

- (void)dateChanged:(UIDatePicker *)sender {
    [self updateDateLabel];
}

- (void)updateDateLabel {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    self.dateLabel.text = [NSString stringWithFormat:@"选择的日期：%@", [formatter stringFromDate:self.datePicker.date]];
}

- (void)startProgress {
    self.progressView.progress = 0;

    [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.progressView.progress += 0.01;

        if (self.progressView.progress >= 1.0) {
            [timer invalidate];
        }
    }];
}

- (void)toggleActivity {
    if (self.activityIndicator.isAnimating) {
        [self.activityIndicator stopAnimating];
    } else {
        [self.activityIndicator startAnimating];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.cities.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.cities[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *city = self.cities[row];
    NSLog(@"选择了城市：%@", city);
}

@end

