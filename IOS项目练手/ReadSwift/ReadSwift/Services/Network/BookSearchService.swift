//
//  BookSearchService.swift
//  ReadSwift
//
//  书籍搜索服务
//

import Foundation

class BookSearchService {

    // MARK: - Singleton

    static let shared = BookSearchService()
    private init() {}

    // MARK: - Public Methods

    /// 搜索书籍
    func searchBooks(keyword: String, completion: @escaping (Result<[BookModel], NetworkError>) -> Void) {
        // 模拟搜索结果
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let results = self.generateMockSearchResults(keyword: keyword)
            completion(.success(results))
        }

        // 实际项目中应该这样实现：
        // let url = "https://api.example.com/search?keyword=\(keyword)"
        // NetworkManager.shared.get(url: url, completion: completion)
    }

    /// 获取书籍详情
    func getBookDetail(bookId: String, completion: @escaping (Result<BookModel, NetworkError>) -> Void) {
        // 模拟获取详情
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let book = BookModel(
                bookId: bookId,
                title: "书籍详情",
                author: "作者名",
                totalChapters: 100
            )
            completion(.success(book))
        }
    }

    /// 获取章节列表
    func getChapterList(bookId: String, completion: @escaping (Result<[ChapterModel], NetworkError>) -> Void) {
        // 模拟获取章节列表
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let chapters = (0..<50).map { index in
                ChapterModel(
                    bookId: bookId,
                    title: "第\(index + 1)章 章节标题",
                    chapterIndex: index
                )
            }
            completion(.success(chapters))
        }
    }

    // MARK: - Private Methods

    private func generateMockSearchResults(keyword: String) -> [BookModel] {
        let titles = [
            "三体", "流浪地球", "球状闪电",
            "活着", "许三观卖血记", "兄弟",
            "平凡的世界", "人生", "白鹿原",
            "红楼梦", "西游记", "水浒传"
        ]

        let authors = [
            "刘慈欣", "余华", "路遥", "陈忠实", "曹雪芹"
        ]

        return titles.filter { $0.contains(keyword) || keyword.isEmpty }
            .prefix(10)
            .map { title in
                BookModel(
                    title: title,
                    author: authors.randomElement() ?? "未知作者",
                    intro: "这是《\(title)》的简介。",
                    totalChapters: Int.random(in: 20...200),
                    bookType: .network
                )
            }
    }
}

