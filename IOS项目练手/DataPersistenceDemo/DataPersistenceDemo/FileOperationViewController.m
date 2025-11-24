//
//  FileOperationViewController.m
//  DataPersistenceDemo
//
//  文件操作示例 - NSFileManager
//

#import "FileOperationViewController.h"

@interface FileOperationViewController () <UITextViewDelegate>
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) NSString *documentsPath;
@property (strong, nonatomic) NSString *filePath;
@end

@implementation FileOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"文件操作";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 获取文档目录路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsPath = [paths firstObject];
    self.filePath = [self.documentsPath stringByAppendingPathComponent:@"notes.txt"];

    [self setupUI];
    [self loadFile];
    [self updateInfo];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 20;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // 说明文本
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 100)];
    descLabel.text = @"文件操作用于存储大量文本、图片等数据。数据保存在应用的沙盒目录中。\n\n💡 尝试在下方输入文本，退出应用后再次打开，数据依然存在！";
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [self.view addSubview:descLabel];
    yOffset += 120;

    // 文本编辑器
    UILabel *editorLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 24)];
    editorLabel.text = @"📝 笔记编辑器";
    editorLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:editorLabel];
    yOffset += 30;

    CGFloat textViewHeight = screenHeight - yOffset - 200;
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, textViewHeight)];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.cornerRadius = 8;
    self.textView.delegate = self;
    self.textView.text = @"在这里输入你的笔记...";
    self.textView.textColor = [UIColor placeholderTextColor];
    [self.view addSubview:self.textView];
    yOffset += textViewHeight + 20;

    // 信息标签
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, screenWidth - 2 * padding, 80)];
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.font = [UIFont systemFontOfSize:13];
    self.infoLabel.textColor = [UIColor secondaryLabelColor];
    self.infoLabel.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.infoLabel.layer.cornerRadius = 8;
    self.infoLabel.clipsToBounds = YES;
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.infoLabel];
    yOffset += 90;

    // 按钮栏
    CGFloat buttonWidth = (screenWidth - 3 * padding) / 2;

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.frame = CGRectMake(padding, yOffset, buttonWidth, 44);
    [saveButton setTitle:@"💾 保存" forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor systemGreenColor];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    saveButton.layer.cornerRadius = 8;
    [saveButton addTarget:self action:@selector(saveFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];

    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteButton.frame = CGRectMake(padding * 2 + buttonWidth, yOffset, buttonWidth, 44);
    [deleteButton setTitle:@"🗑️ 删除" forState:UIControlStateNormal];
    deleteButton.backgroundColor = [UIColor systemRedColor];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    deleteButton.layer.cornerRadius = 8;
    [deleteButton addTarget:self action:@selector(deleteFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
}

#pragma mark - 文件操作方法

- (void)loadFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 检查文件是否存在
    if ([fileManager fileExistsAtPath:self.filePath]) {
        // 读取文件内容
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:self.filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];

        if (error) {
            NSLog(@"❌ 读取文件失败: %@", error.localizedDescription);
        } else {
            self.textView.text = content;
            self.textView.textColor = [UIColor labelColor];
        }
    }
}

- (void)saveFile {
    NSString *content = self.textView.text;

    // 写入文件
    NSError *error = nil;
    BOOL success = [content writeToFile:self.filePath
                             atomically:YES  // 原子性写入，先写临时文件再移动
                               encoding:NSUTF8StringEncoding
                                  error:&error];

    if (success) {
        [self showAlert:@"✅ 保存成功" message:@"文件已保存到Documents目录"];
        [self updateInfo];
    } else {
        [self showAlert:@"❌ 保存失败" message:error.localizedDescription];
    }
}

- (void)deleteFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 检查文件是否存在
    if (![fileManager fileExistsAtPath:self.filePath]) {
        [self showAlert:@"提示" message:@"文件不存在"];
        return;
    }

    // 确认删除
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:@"确定要删除文件吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSError *error = nil;
        BOOL success = [fileManager removeItemAtPath:self.filePath error:&error];

        if (success) {
            self.textView.text = @"在这里输入你的笔记...";
            self.textView.textColor = [UIColor placeholderTextColor];
            [self updateInfo];
            [self showAlert:@"✅ 删除成功" message:@"文件已删除"];
        } else {
            [self showAlert:@"❌ 删除失败" message:error.localizedDescription];
        }
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateInfo {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSMutableString *info = [NSMutableString stringWithString:@"\n📁 文件信息:\n\n"];

    // 文件路径
    [info appendFormat:@"路径: %@\n\n", self.filePath];

    // 文件是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:self.filePath];
    [info appendFormat:@"状态: %@\n", fileExists ? @"✅ 已存在" : @"❌ 不存在"];

    // 文件大小
    if (fileExists) {
        NSError *error = nil;
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:self.filePath error:&error];
        if (!error) {
            unsigned long long fileSize = [attributes fileSize];
            [info appendFormat:@"大小: %llu 字节", fileSize];
        }
    }

    self.infoLabel.text = info;
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"在这里输入你的笔记..."]) {
        textView.text = @"";
        textView.textColor = [UIColor labelColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"在这里输入你的笔记...";
        textView.textColor = [UIColor placeholderTextColor];
    }
}

@end

