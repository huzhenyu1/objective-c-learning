//
//  SceneDelegate.m
//  Read
//
//  阅读应用 - 场景代理
//

#import "SceneDelegate.h"
#import "BookshelfViewController.h"
#import "BookSourceViewController.h"
#import "ProfileViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    // 创建 TabBarController
    UITabBarController *tabBarController = [[UITabBarController alloc] init];

    // 1. 书架页面
    BookshelfViewController *bookshelfVC = [[BookshelfViewController alloc] init];
    UINavigationController *bookshelfNav = [[UINavigationController alloc] initWithRootViewController:bookshelfVC];
    bookshelfNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"书架"
                                                            image:[UIImage systemImageNamed:@"books.vertical"]
                                                              tag:0];

    // 2. 书源页面
    BookSourceViewController *bookSourceVC = [[BookSourceViewController alloc] init];
    UINavigationController *bookSourceNav = [[UINavigationController alloc] initWithRootViewController:bookSourceVC];
    bookSourceNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"书源"
                                                             image:[UIImage systemImageNamed:@"globe"]
                                                               tag:1];

    // 3. 个人页面
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
    profileNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"个人"
                                                          image:[UIImage systemImageNamed:@"person.circle"]
                                                            tag:2];

    // 设置 TabBar 的 ViewControllers
    tabBarController.viewControllers = @[bookshelfNav, bookSourceNav, profileNav];

    // 设置为根视图控制器
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
}

@end
