//
//  BookshelfManager.swift
//  ReadSwift
//
//  书架管理器 - 负责书籍的增删改查
//

import Foundation

class BookshelfManager {

    // MARK: - Singleton

    static let shared = BookshelfManager()
    private init() {}

    // MARK: - Constants

    private let booksKey = "ReadSwift_Books"

    // MARK: - Public Methods

    /// 获取所有书籍
    func getAllBooks() -> [BookModel] {
        guard let data = UserDefaults.standard.data(forKey: booksKey),
              let books = try? JSONDecoder().decode([BookModel].self, from: data) else {
            return []
        }
        return books.sorted { $0.addTime > $1.addTime }
    }

    /// 添加书籍
    func addBook(_ book: BookModel) {
        var books = getAllBooks()

        // 检查是否已存在
        if let index = books.firstIndex(where: { $0.bookId == book.bookId }) {
            books[index] = book
        } else {
            books.append(book)
        }

        saveBooks(books)
    }

    /// 删除书籍
    func removeBook(_ book: BookModel) {
        var books = getAllBooks()
        books.removeAll { $0.bookId == book.bookId }
        saveBooks(books)
    }

    /// 批量删除书籍
    func removeBooks(_ booksToRemove: [BookModel]) {
        var books = getAllBooks()
        let idsToRemove = Set(booksToRemove.map { $0.bookId })
        books.removeAll { idsToRemove.contains($0.bookId) }
        saveBooks(books)
    }

    /// 更新书籍
    func updateBook(_ book: BookModel) {
        var books = getAllBooks()

        if let index = books.firstIndex(where: { $0.bookId == book.bookId }) {
            books[index] = book
            saveBooks(books)
        }
    }

    /// 获取指定书籍
    func getBook(bookId: String) -> BookModel? {
        return getAllBooks().first { $0.bookId == bookId }
    }

    /// 清空书架
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: booksKey)
    }

    // MARK: - Private Methods

    private func saveBooks(_ books: [BookModel]) {
        if let data = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(data, forKey: booksKey)
        }
    }
}

