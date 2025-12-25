//
//  BookshelfViewModel.swift
//  ReadSwift
//
//  书架视图模型
//

import Foundation
import Combine

class BookshelfViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var books: [BookModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    // MARK: - Initialization

    init() {
        loadBooks()
    }

    // MARK: - Public Methods

    /// 加载书籍
    func loadBooks() {
        books = BookshelfManager.shared.getAllBooks()

        if books.isEmpty {
            createSampleBooks()
        }
    }

    /// 添加书籍
    func addBook(_ book: BookModel) {
        BookshelfManager.shared.addBook(book)
        loadBooks()
    }

    /// 删除书籍
    func deleteBook(_ book: BookModel) {
        BookshelfManager.shared.removeBook(book)
        loadBooks()
    }

    /// 删除书籍（IndexSet方式）
    func deleteBooks(at offsets: IndexSet) {
        let booksToDelete = offsets.map { books[$0] }
        BookshelfManager.shared.removeBooks(booksToDelete)
        loadBooks()
    }

    /// 搜索书籍
    func searchBooks(keyword: String) {
        isLoading = true

        BookSearchService.shared.searchBooks(keyword: keyword) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let books):
                    print("找到\(books.count)本书")

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }

    // MARK: - Private Methods

    private func createSampleBooks() {
        let sampleBooks = [
            BookModel(title: "三体", author: "刘慈欣", currentChapter: 3, totalChapters: 46, bookType: .network),
            BookModel(title: "流浪地球", author: "刘慈欣", currentChapter: 0, totalChapters: 1, bookType: .network),
            BookModel(title: "活着", author: "余华", currentChapter: 8, totalChapters: 12, bookType: .local),
            BookModel(title: "平凡的世界", author: "路遥", currentChapter: 0, totalChapters: 106, bookType: .network),
            BookModel(title: "红楼梦", author: "曹雪芹", currentChapter: 20, totalChapters: 120, bookType: .local),
            BookModel(title: "白鹿原", author: "陈忠实", currentChapter: 5, totalChapters: 50, bookType: .network)
        ]

        for book in sampleBooks {
            BookshelfManager.shared.addBook(book)
        }

        loadBooks()
    }
}
