//
//  ProfileView.swift
//  ReadSwift
//
//  个人中心视图
//

import SwiftUI

struct ProfileView: View {

    // MARK: - Properties

    @State private var showingSettings = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                // 用户信息区域
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("阅读者")
                                .font(.title2)
                                .fontWeight(.semibold)

                            Text("享受阅读的乐趣")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 10)
                }

                // 阅读统计
                Section("阅读统计") {
                    HStack {
                        Image(systemName: "books.vertical")
                            .foregroundColor(.blue)
                        Text("书架书籍")
                        Spacer()
                        Text("\(BookshelfManager.shared.getAllBooks().count) 本")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text("阅读时长")
                        Spacer()
                        Text("0 小时")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("已读完")
                        Spacer()
                        Text("0 本")
                            .foregroundColor(.gray)
                    }
                }

                // 功能设置
                Section("设置") {
                    Button {
                        showingSettings = true
                    } label: {
                        HStack {
                            Image(systemName: "textformat.size")
                                .foregroundColor(.purple)
                            Text("阅读设置")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(.blue)
                        Text("数据同步")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("清理缓存")
                        Spacer()
                        Text("0 MB")
                            .foregroundColor(.gray)
                    }
                }

                // 关于
                Section("关于") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                        Text("给个好评")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("个人")
                        .font(.headline)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .padding(.bottom, 80) // 为底部TabBar留空间
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
