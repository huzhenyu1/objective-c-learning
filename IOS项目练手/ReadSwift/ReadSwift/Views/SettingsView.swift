//
//  SettingsView.swift
//  ReadSwift
//
//  设置视图 - SwiftUI
//

import SwiftUI

struct SettingsView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = ReadingSettingsManager.shared

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                // 字体设置
                Section("字体") {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("字体大小: \(Int(settingsManager.settings.fontSize))")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack {
                            Text("A")
                                .font(.system(size: 14))

                            Slider(
                                value: Binding(
                                    get: { settingsManager.settings.fontSize },
                                    set: { settingsManager.settings.fontSize = $0 }
                                ),
                                in: 14...32,
                                step: 1
                            )

                            Text("A")
                                .font(.system(size: 20))
                        }

                        Text("这是预览文本，用于展示当前字体大小的效果。")
                            .font(.system(size: settingsManager.settings.fontSize))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                // 主题设置
                Section("主题") {
                    ForEach([ReadingTheme.white, .sepia, .green, .night], id: \.self) { theme in
                        Button {
                            settingsManager.settings.theme = theme
                        } label: {
                            HStack {
                                Rectangle()
                                    .fill(theme.backgroundColor)
                                    .frame(width: 60, height: 40)
                                    .cornerRadius(6)
                                    .overlay {
                                        Text("样")
                                            .font(.system(size: 16))
                                            .foregroundColor(theme.textColor)
                                    }

                                Text(theme.displayName)
                                    .foregroundColor(.primary)

                                Spacer()

                                if settingsManager.settings.theme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                // 间距设置
                Section("间距") {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("行间距: \(Int(settingsManager.settings.lineSpacing))")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Slider(
                            value: Binding(
                                get: { settingsManager.settings.lineSpacing },
                                set: { settingsManager.settings.lineSpacing = $0 }
                            ),
                            in: 0...20,
                            step: 2
                        )

                        Text("段间距: \(Int(settingsManager.settings.paragraphSpacing))")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Slider(
                            value: Binding(
                                get: { settingsManager.settings.paragraphSpacing },
                                set: { settingsManager.settings.paragraphSpacing = $0 }
                            ),
                            in: 0...30,
                            step: 5
                        )
                    }
                }

                // 翻页设置
                Section("翻页") {
                    Toggle("启用翻页动画", isOn: Binding(
                        get: { settingsManager.settings.enablePageTurnAnimation },
                        set: { settingsManager.settings.enablePageTurnAnimation = $0 }
                    ))
                }

                // 其他设置
                Section("其他") {
                    Toggle("自动保存进度", isOn: Binding(
                        get: { settingsManager.settings.autoSaveProgress },
                        set: { settingsManager.settings.autoSaveProgress = $0 }
                    ))

                    Toggle("保持屏幕常亮", isOn: Binding(
                        get: { settingsManager.settings.keepScreenOn },
                        set: { settingsManager.settings.keepScreenOn = $0 }
                    ))
                }

                // 重置按钮
                Section {
                    Button("恢复默认设置") {
                        settingsManager.resetToDefault()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Theme Extension

extension ReadingTheme {
    var displayName: String {
        switch self {
        case .white:
            return "白天模式"
        case .sepia:
            return "羊皮纸"
        case .green:
            return "护眼模式"
        case .night:
            return "夜间模式"
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

