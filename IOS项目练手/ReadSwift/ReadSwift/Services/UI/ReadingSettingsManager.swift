//
//  ReadingSettingsManager.swift
//  ReadSwift
//
//  阅读设置管理器
//

import Foundation
import SwiftUI
import Combine

/// 阅读主题
enum ReadingTheme: String, Codable, CaseIterable {
    case white = "white"
    case sepia = "sepia"
    case green = "green"
    case night = "night"
}

/// 阅读设置
struct ReadingSettings: Codable {
    var fontSize: CGFloat = 18
    var theme: ReadingTheme = .white
    var lineSpacing: CGFloat = 8
    var paragraphSpacing: CGFloat = 15
    var enablePageTurnAnimation: Bool = true
    var autoSaveProgress: Bool = true
    var keepScreenOn: Bool = false
}

class ReadingSettingsManager: ObservableObject {

    // MARK: - Singleton

    static let shared = ReadingSettingsManager()

    // MARK: - Published Properties

    @Published var settings: ReadingSettings {
        didSet {
            saveSettings()
            postNotification()
        }
    }

    // MARK: - Constants

    private let settingsKey = "ReadSwift_ReadingSettings"
    static let settingsDidChangeNotification = Notification.Name("ReadingSettingsDidChange")

    // MARK: - Initialization

    private init() {
        self.settings = Self.loadSettings()
    }

    // MARK: - Public Methods

    /// 重置为默认设置
    func resetToDefault() {
        settings = ReadingSettings()
    }

    /// 更新字体大小
    func updateFontSize(_ size: CGFloat) {
        settings.fontSize = size
    }

    /// 更新主题
    func updateTheme(_ theme: ReadingTheme) {
        settings.theme = theme
    }

    /// 更新行间距
    func updateLineSpacing(_ spacing: CGFloat) {
        settings.lineSpacing = spacing
    }

    /// 更新段间距
    func updateParagraphSpacing(_ spacing: CGFloat) {
        settings.paragraphSpacing = spacing
    }

    // MARK: - Private Methods

    private static func loadSettings() -> ReadingSettings {
        let settingsKey = "ReadSwift_ReadingSettings"
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(ReadingSettings.self, from: data) else {
            return ReadingSettings()
        }
        return settings
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }

    private func postNotification() {
        NotificationCenter.default.post(
            name: Self.settingsDidChangeNotification,
            object: settings
        )
    }
}

