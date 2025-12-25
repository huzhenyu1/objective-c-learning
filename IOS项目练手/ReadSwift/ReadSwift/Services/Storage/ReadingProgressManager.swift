//
//  ReadingProgressManager.swift
//  ReadSwift
//
//  阅读进度管理器
//

import Foundation

/// 阅读进度模型
struct ReadingProgress: Codable {
    let bookId: String
    var chapterIndex: Int
    var scrollOffset: Double
    var lastReadTime: Date
}

class ReadingProgressManager {

    // MARK: - Singleton

    static let shared = ReadingProgressManager()
    private init() {}

    // MARK: - Constants

    private let progressKey = "ReadSwift_ReadingProgress"

    // MARK: - Public Methods

    /// 保存阅读进度
    func saveProgress(bookId: String, chapterIndex: Int, scrollOffset: Double = 0) {
        var progressDict = getAllProgress()

        let progress = ReadingProgress(
            bookId: bookId,
            chapterIndex: chapterIndex,
            scrollOffset: scrollOffset,
            lastReadTime: Date()
        )

        progressDict[bookId] = progress
        saveAllProgress(progressDict)

        // 同步更新书籍的当前章节
        if let book = BookshelfManager.shared.getBook(bookId: bookId) {
            book.currentChapter = chapterIndex
            book.lastReadTime = Date()
            BookshelfManager.shared.updateBook(book)
        }
    }

    /// 获取阅读进度
    func getProgress(forBook bookId: String) -> ReadingProgress? {
        return getAllProgress()[bookId]
    }

    /// 删除阅读进度
    func removeProgress(forBook bookId: String) {
        var progressDict = getAllProgress()
        progressDict.removeValue(forKey: bookId)
        saveAllProgress(progressDict)
    }

    /// 清空所有进度
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: progressKey)
    }

    // MARK: - Private Methods

    private func getAllProgress() -> [String: ReadingProgress] {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode([String: ReadingProgress].self, from: data) else {
            return [:]
        }
        return progress
    }

    private func saveAllProgress(_ progress: [String: ReadingProgress]) {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }
}

