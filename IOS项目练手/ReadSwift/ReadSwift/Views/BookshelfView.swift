//
//  BookshelfView.swift
//  ReadSwift
//
//  书架视图 - SwiftUI
//

import SwiftUI
import UniformTypeIdentifiers

/// 书架分类
enum BookCategory: String, CaseIterable {
    case all = "全部"
    case local = "本地书籍"
    case network = "网络书籍"
}

struct BookshelfView: View {

    // MARK: - Properties

    @StateObject private var viewModel = BookshelfViewModel()
    @State private var showingSearch = false
    @State private var showingFileImporter = false
    @State private var selectedBook: BookModel?
    @State private var selectedCategory: BookCategory = .all

    // 网格列配置
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    /// 根据分类过滤后的书籍
    private var filteredBooks: [BookModel] {
        switch selectedCategory {
        case .all:
            return viewModel.books
        case .local:
            return viewModel.books.filter { $0.bookType == .local }
        case .network:
            return viewModel.books.filter { $0.bookType == .network }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 分类标签栏
                categoryTabBar

                Divider()

                // 书籍内容
                if filteredBooks.isEmpty {
                    emptyView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    bookGridView
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("书架")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingSearch = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }

                        Button {
                            showingFileImporter = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
            .sheet(item: $selectedBook) { book in
                ReaderView(book: book)
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.plainText, .text, UTType(filenameExtension: "txt")].compactMap { $0 },
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .alert("错误", isPresented: $viewModel.showError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "未知错误")
            }
        }
        .padding(.bottom, 80) // 为底部TabBar留空间
    }

    // MARK: - 分类标签栏

    private var categoryTabBar: some View {
        HStack(spacing: 0) {
            ForEach(BookCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(category.rawValue)
                            .font(.system(size: 15, weight: selectedCategory == category ? .semibold : .regular))
                            .foregroundColor(selectedCategory == category ? .primary : .gray)

                        // 选中指示器
                        Rectangle()
                            .fill(selectedCategory == category ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - 处理文件导入

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                // 获取安全访问权限
                guard url.startAccessingSecurityScopedResource() else {
                    continue
                }
                defer { url.stopAccessingSecurityScopedResource() }

                // 从文件名获取书名
                let fileName = url.deletingPathExtension().lastPathComponent

                // 创建本地书籍
                let book = BookModel(
                    title: fileName,
                    author: "未知作者",
                    currentChapter: 0,
                    totalChapters: 1,
                    bookType: .local
                )

                // 添加到书架
                viewModel.addBook(book)
            }
        case .failure(let error):
            viewModel.errorMessage = "导入失败: \(error.localizedDescription)"
            viewModel.showError = true
        }
    }

    // MARK: - Views

    private var bookGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(filteredBooks, id: \.bookId) { book in
                    BookCardView(book: book)
                        .onTapGesture {
                            selectedBook = book
                        }
                        .contextMenu {
                            Button {
                                viewModel.deleteBook(book)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(emptyViewTitle)
                .font(.title2)
                .foregroundColor(.gray)

            Text("点击右上角 + 添加本地书籍")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button {
                showingFileImporter = true
            } label: {
                Text("添加书籍")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }

    /// 空视图标题
    private var emptyViewTitle: String {
        switch selectedCategory {
        case .all:
            return "书架空空如也"
        case .local:
            return "暂无本地书籍"
        case .network:
            return "暂无网络书籍"
        }
    }
}

// MARK: - BookCardView

struct BookCardView: View {

    let book: BookModel

    var body: some View {
        VStack(spacing: 8) {
            // 封面
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(0.7, contentMode: .fit)
                    .cornerRadius(8)
                    .overlay {
                        Text(String(book.title.prefix(4)))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                    }

                // 未读标记
                if book.hasUnread {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 16, height: 16)
                        .padding(8)
                }
            }

            // 书名
            Text(book.title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 36)

            // 进度
            if book.currentChapter > 0 {
                Text("\(book.currentChapter)/\(book.totalChapters)章")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            } else {
                Text("未开始")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BookshelfView()
}

