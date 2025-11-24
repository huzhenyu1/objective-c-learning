//
//  SceneDelegate.m
//  CommonControlsDemo
//
//  Scene Delegate
//

#import "SceneDelegate.h"
#import "ViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // 创建主视图控制器
    ViewController *rootVC = [[ViewController alloc] init];

    // 嵌入导航控制器
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootVC];

    // 设置为窗口的根视图控制器
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.rootViewController = navigationController;
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
