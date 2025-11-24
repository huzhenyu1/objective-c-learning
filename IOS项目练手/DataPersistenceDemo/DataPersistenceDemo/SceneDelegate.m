//
//  SceneDelegate.m
//  DataPersistenceDemo
//
//  数据持久化示例 - 场景代理
//

#import "SceneDelegate.h"
#import "ViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    // 创建主视图控制器
    ViewController *mainVC = [[ViewController alloc] init];

    // 包裹在导航控制器中
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];

    // 设置为根视图控制器
    self.window.rootViewController = nav;
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
