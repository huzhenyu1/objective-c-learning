//
//  SearchView.swift
//  ReadSwift
//
//  搜索视图 - SwiftUI
//

import SwiftUI

struct SearchView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [BookModel] = []
    @State private var isSearching = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack {
                if isSearching {
                    ProgressView("搜索中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptyResultView
                } else {
                    resultListView
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜索书名或作者")
            .onSubmit(of: .search) {
                performSearch()
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Views

    private var resultListView: some View {
        List(searchResults, id: \.bookId) { book in
            BookSearchResultRow(book: book)
                .contentShape(Rectangle())
                .onTapGesture {
                    addToBookshelf(book)
                }
        }
        .listStyle(.plain)
    }

    private var emptyResultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("没有找到相关书籍")
                .font(.headline)
                .foregroundColor(.gray)

            Text("试试其他关键词")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Methods

    private func performSearch() {
        guard !searchText.isEmpty else { return }

        isSearching = true

        BookSearchService.shared.searchBooks(keyword: searchText) { result in
            DispatchQueue.main.async {
                isSearching = false

                switch result {
                case .success(let books):
                    searchResults = books
                    if books.isEmpty {
                        alertMessage = "没有找到相关书籍"
                        showingAlert = true
                    }

                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }

    private func addToBookshelf(_ book: BookModel) {
        BookshelfManager.shared.addBook(book)
        alertMessage = "已加入书架"
        showingAlert = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
}

// MARK: - BookSearchResultRow

struct BookSearchResultRow: View {

    let book: BookModel

    var body: some View {
        HStack(spacing: 15) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 84)
                .cornerRadius(6)
                .overlay {
                    Text(String(book.title.prefix(2)))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)

                Text(book.author)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                if let intro = book.intro {
                    Text(intro)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                if book.totalChapters > 0 {
                    Text("\(book.totalChapters)章")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            Image(systemName: "plus.circle")
                .font(.system(size: 24))
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    SearchView()
}

