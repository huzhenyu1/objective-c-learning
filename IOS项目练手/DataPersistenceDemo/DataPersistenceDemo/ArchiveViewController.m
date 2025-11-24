//
//  ArchiveViewController.m
//  DataPersistenceDemo
//
//  归档示例 - NSCoding 对象序列化
//

#import "ArchiveViewController.h"
#import "Person.h"

@interface ArchiveViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Person *> *persons;
@property (strong, nonatomic) NSString *archivePath;
@end

@implementation ArchiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"归档（Archive）";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 获取归档文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    self.archivePath = [documentsPath stringByAppendingPathComponent:@"persons.archive"];

    // 添加按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addPerson)];

    [self setupUI];
    [self loadPersons];
}

- (void)setupUI {
    // 添加说明标签
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 100)];
    descLabel.text = @"归档（NSCoding）用于将自定义对象保存到文件。对象必须实现 NSCoding 协议。\n\n💡 点击右上角 ➕ 添加联系人";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 120;

    // TableView
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat tableHeight = screenHeight - yOffset;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOffset, screenWidth, tableHeight)
                                                   style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - 数据持久化方法

- (void)loadPersons {
    // 从文件中读取归档的对象数组
    NSData *data = [NSData dataWithContentsOfFile:self.archivePath];

    if (data) {
        // 反序列化
        NSError *error = nil;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];

        if (!error) {
            self.persons = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            [unarchiver finishDecoding];
        } else {
            NSLog(@"❌ 反序列化失败: %@", error.localizedDescription);
            self.persons = [NSMutableArray array];
        }
    } else {
        self.persons = [NSMutableArray array];
    }

    [self.tableView reloadData];
}

- (void)savePersons {
    // 序列化对象数组到文件
    NSError *error = nil;
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

    [archiver encodeObject:self.persons forKey:NSKeyedArchiveRootObjectKey];
    [archiver finishEncoding];

    BOOL success = [data writeToFile:self.archivePath atomically:YES];

    if (success) {
        NSLog(@"✅ 归档成功: %@", self.archivePath);
    } else {
        NSLog(@"❌ 归档失败");
    }
}

#pragma mark - 用户操作

- (void)addPerson {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加联系人"
                                                                   message:@"请输入联系人信息"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // 添加输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"姓名";
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"年龄";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"邮箱";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"电话";
        textField.keyboardType = UIKeyboardTypePhonePad;
    }];

    // 取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    // 确定按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields[0].text;
        NSInteger age = [alert.textFields[1].text integerValue];
        NSString *email = alert.textFields[2].text;
        NSString *phone = alert.textFields[3].text;

        if (name.length > 0) {
            // 创建 Person 对象
            Person *person = [[Person alloc] initWithName:name
                                                      age:age
                                                    email:email
                                                    phone:phone
                                                 birthday:[NSDate date]];

            // 添加到数组
            [self.persons addObject:person];

            // 保存到文件
            [self savePersons];

            // 刷新列表
            [self.tableView reloadData];

            NSLog(@"✅ 添加成功: %@", person);
        }
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellID];
    }

    Person *person = self.persons[indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"👤 %@ (%ld岁)", person.name, (long)person.age];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"📧 %@ | 📞 %@", person.email ?: @"未填写", person.phone ?: @"未填写"];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Person *person = self.persons[indexPath.row];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *birthdayStr = [formatter stringFromDate:person.birthday];

    NSString *message = [NSString stringWithFormat:@"姓名: %@\n年龄: %ld岁\n邮箱: %@\n电话: %@\n生日: %@",
                        person.name,
                        (long)person.age,
                        person.email ?: @"未填写",
                        person.phone ?: @"未填写",
                        birthdayStr];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"联系人详情"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除对象
        [self.persons removeObjectAtIndex:indexPath.row];

        // 保存到文件
        [self savePersons];

        // 刷新列表
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    // 删除按钮
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"删除"
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 删除对象
        [self.persons removeObjectAtIndex:indexPath.row];

        // 保存到文件
        [self savePersons];

        // 刷新列表
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        completionHandler(YES);
    }];

    deleteAction.backgroundColor = [UIColor systemRedColor];

    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    return configuration;
}

@end

