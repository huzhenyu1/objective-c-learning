//
//  BookSourceView.swift
//  ReadSwift
//
//  书源管理视图
//

import SwiftUI

struct BookSourceView: View {

    // MARK: - Properties

    @StateObject private var sourceManager = BookSourceManager.shared
    @State private var showingAddSource = false
    @State private var newSourceURL = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if sourceManager.sources.isEmpty {
                    emptyView
                } else {
                    sourceListView
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("书源")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSource = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("添加书源", isPresented: $showingAddSource) {
                TextField("书源地址", text: $newSourceURL)
                Button("取消", role: .cancel) {
                    newSourceURL = ""
                }
                Button("添加") {
                    if !newSourceURL.isEmpty {
                        // TODO: 解析并添加书源
                        newSourceURL = ""
                    }
                }
            } message: {
                Text("请输入书源URL或JSON地址")
            }
        }
        .padding(.bottom, 80) // 为底部TabBar留空间
    }

    // MARK: - Views

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("暂无书源")
                .font(.title2)
                .foregroundColor(.gray)

            Text("点击右上角 + 添加书源")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button {
                showingAddSource = true
            } label: {
                Text("添加书源")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sourceListView: some View {
        List {
            ForEach(sourceManager.sources, id: \.sourceId) { source in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.sourceName)
                            .font(.headline)

                        Text(source.sourceUrl)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    if source.isEnabled {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    sourceManager.toggleSource(source)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    sourceManager.removeSource(sourceManager.sources[index])
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    BookSourceView()
}
