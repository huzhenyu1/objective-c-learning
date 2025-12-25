//
//  ReadSwiftApp.swift
//  ReadSwift
//
//  SwiftUI应用入口
//

import SwiftUI

@main
struct ReadSwiftApp: App {

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }

    private func configureAppearance() {
        // 配置导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
