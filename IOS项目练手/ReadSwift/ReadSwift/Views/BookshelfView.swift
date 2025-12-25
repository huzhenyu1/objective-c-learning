//
//  BookshelfView.swift
//  ReadSwift
//
//  书架视图 - SwiftUI
//

import SwiftUI

struct BookshelfView: View {

    // MARK: - Properties

    @StateObject private var viewModel = BookshelfViewModel()
    @State private var showingSearch = false
    @State private var showingAddOptions = false
    @State private var selectedBook: BookModel?

    // 网格列配置
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.books.isEmpty {
                    emptyView
                } else {
                    bookGridView
                }
            }
            .navigationTitle("书架")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingSearch = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }

                        Button {
                            showingAddOptions = true
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
            .actionSheet(isPresented: $showingAddOptions) {
                ActionSheet(
                    title: Text("添加书籍"),
                    message: Text("选择添加方式"),
                    buttons: [
                        .default(Text("搜索网络书籍")) {
                            showingSearch = true
                        },
                        .default(Text("导入本地文件")) {
                            // TODO: 导入本地文件
                        },
                        .cancel(Text("取消"))
                    ]
                )
            }
            .alert("错误", isPresented: $viewModel.showError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "未知错误")
            }
        }
    }

    // MARK: - Views

    private var bookGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.books, id: \.bookId) { book in
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

            Text("书架空空如也")
                .font(.title2)
                .foregroundColor(.gray)

            Text("点击右上角添加书籍")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button {
                showingAddOptions = true
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

