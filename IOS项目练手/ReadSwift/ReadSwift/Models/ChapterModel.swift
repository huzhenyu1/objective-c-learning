//
//  ChapterModel.swift
//  ReadSwift
//
//  章节数据模型
//

import Foundation

/// 章节模型
class ChapterModel: Codable, Equatable, Identifiable {

    // MARK: - Properties

    var id: String { chapterId }  // Identifiable协议要求
    let chapterId: String
    let bookId: String
    var title: String
    var chapterIndex: Int
    var contentURL: String?
    var wordCount: Int
    var hasDownloaded: Bool

    // MARK: - Initialization

    init(chapterId: String = UUID().uuidString,
         bookId: String,
         title: String,
         chapterIndex: Int,
         contentURL: String? = nil,
         wordCount: Int = 0,
         hasDownloaded: Bool = false) {

        self.chapterId = chapterId
        self.bookId = bookId
        self.title = title
        self.chapterIndex = chapterIndex
        self.contentURL = contentURL
        self.wordCount = wordCount
        self.hasDownloaded = hasDownloaded
    }

    // MARK: - Equatable

    static func == (lhs: ChapterModel, rhs: ChapterModel) -> Bool {
        return lhs.chapterId == rhs.chapterId
    }

    // MARK: - Helper Methods

    /// 显示名称（如：第1章）
    var displayName: String {
        return title.isEmpty ? "第\(chapterIndex + 1)章" : title
    }
}

