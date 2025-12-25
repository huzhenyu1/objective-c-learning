//
//  BookModel.swift
//  ReadSwift
//
//  书籍数据模型
//

import Foundation

/// 书籍类型
enum BookType: String, Codable {
    case local = "local"      // 本地书籍
    case network = "network"  // 网络书籍
}

/// 书籍模型
class BookModel: Codable, Equatable, Identifiable {

    // MARK: - Properties

    var id: String { bookId }  // Identifiable协议要求
    let bookId: String
    var title: String
    var author: String
    var coverImageURL: String?
    var intro: String?
    var currentChapter: Int
    var totalChapters: Int
    var bookType: BookType
    var hasUnread: Bool
    var lastReadTime: Date?
    var addTime: Date

    // MARK: - Initialization

    init(bookId: String = UUID().uuidString,
         title: String,
         author: String,
         coverImageURL: String? = nil,
         intro: String? = nil,
         currentChapter: Int = 0,
         totalChapters: Int,
         bookType: BookType = .network,
         hasUnread: Bool = false,
         lastReadTime: Date? = nil,
         addTime: Date = Date()) {

        self.bookId = bookId
        self.title = title
        self.author = author
        self.coverImageURL = coverImageURL
        self.intro = intro
        self.currentChapter = currentChapter
        self.totalChapters = totalChapters
        self.bookType = bookType
        self.hasUnread = hasUnread
        self.lastReadTime = lastReadTime
        self.addTime = addTime
    }

    // MARK: - Equatable

    static func == (lhs: BookModel, rhs: BookModel) -> Bool {
        return lhs.bookId == rhs.bookId
    }

    // MARK: - Helper Methods

    /// 阅读进度百分比
    var progressPercentage: Double {
        guard totalChapters > 0 else { return 0 }
        return Double(currentChapter) / Double(totalChapters) * 100
    }

    /// 是否已读完
    var isFinished: Bool {
        return currentChapter >= totalChapters
    }
}

