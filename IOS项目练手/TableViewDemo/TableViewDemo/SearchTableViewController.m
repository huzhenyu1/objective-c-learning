//
//  SearchTableViewController.m
//  TableViewDemo
//
//  搜索功能 - 演示如何实现搜索过滤
//

#import "SearchTableViewController.h"

@interface SearchTableViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *allCities;         // 所有城市
@property (strong, nonatomic) NSMutableArray *filteredCities;  // 搜索结果
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"搜索功能";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 准备数据
    self.allCities = @[
        @"北京", @"上海", @"广州", @"深圳", @"杭州", @"南京", @"苏州", @"成都",
        @"重庆", @"武汉", @"西安", @"天津", @"郑州", @"长沙", @"沈阳", @"青岛",
        @"宁波", @"厦门", @"济南", @"哈尔滨", @"长春", @"福州", @"石家庄", @"合肥",
        @"昆明", @"兰州", @"太原", @"南昌", @"贵阳", @"南宁", @"乌鲁木齐", @"拉萨"
    ];
    self.filteredCities = [NSMutableArray arrayWithArray:self.allCities];

    [self setupSearchController];
    [self setupTableView];
}

- (void)setupSearchController {
    // 创建搜索控制器
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"搜索城市";

    // 设置搜索栏样式
    self.searchController.searchBar.tintColor = [UIColor systemBlueColor];

    // 将搜索栏添加到导航栏
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;  // 始终显示搜索栏

    // 确保搜索时不会影响导航栏
    self.definesPresentationContext = YES;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.view addSubview:self.tableView];
}

#pragma mark - UISearchResultsUpdating

// 搜索文本改变时调用
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;

    if (searchText.length == 0) {
        // 没有搜索内容，显示全部
        self.filteredCities = [NSMutableArray arrayWithArray:self.allCities];
    } else {
        // 过滤数据
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchText];
        self.filteredCities = [NSMutableArray arrayWithArray:[self.allCities filteredArrayUsingPredicate:predicate]];

        NSLog(@"搜索：%@，找到 %lu 个结果", searchText, (unsigned long)self.filteredCities.count);
    }

    // 刷新列表
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredCities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *city = self.filteredCities[indexPath.row];
    cell.textLabel.text = city;
    cell.textLabel.font = [UIFont systemFontOfSize:18];

    // 高亮搜索关键词（可选）
    NSString *searchText = self.searchController.searchBar.text;
    if (searchText.length > 0 && [city containsString:searchText]) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:city];
        NSRange range = [city rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor systemRedColor]
                                     range:range];
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont boldSystemFontOfSize:18]
                                     range:range];
            cell.textLabel.attributedText = attributedString;
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *city = self.filteredCities[indexPath.row];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择了城市"
                                                                   message:city
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];

    // 取消搜索状态
    self.searchController.active = NO;
}

// 添加空数据提示
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.filteredCities.count == 0 && self.searchController.searchBar.text.length > 0) {
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 100)];
        emptyLabel.text = @"未找到匹配的城市";
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.textColor = [UIColor secondaryLabelColor];
        emptyLabel.font = [UIFont systemFontOfSize:16];
        return emptyLabel;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.filteredCities.count == 0 && self.searchController.searchBar.text.length > 0) {
        return 100;
    }
    return 0;
}

@end

