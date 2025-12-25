//
//  ReadingContentManager.swift
//  ReadSwift
//
//  阅读内容管理器
//

import Foundation

class ReadingContentManager {

    // MARK: - Singleton

    static let shared = ReadingContentManager()
    private init() {}

    // MARK: - Properties

    private var contentCache: [String: String] = [:]

    // MARK: - Public Methods

    /// 获取章节内容
    func getChapterContent(chapter: ChapterModel,
                          source: BookSource,
                          completion: @escaping (Result<String, NetworkError>) -> Void) {

        // 先检查缓存
        if let cached = contentCache[chapter.chapterId] {
            completion(.success(cached))
            return
        }

        // 模拟加载内容
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let content = self.generateMockContent(for: chapter)
            self.contentCache[chapter.chapterId] = content
            completion(.success(content))
        }

        // 实际项目中应该：
        // if let url = chapter.contentURL {
        //     NetworkManager.shared.downloadText(url: url) { result in
        //         if case .success(let content) = result {
        //             self.contentCache[chapter.chapterId] = content
        //         }
        //         completion(result)
        //     }
        // }
    }

    /// 预加载下一章
    func preloadNextChapters(currentChapter: ChapterModel,
                            chapters: [ChapterModel],
                            source: BookSource,
                            count: Int = 2) {
        let startIndex = currentChapter.chapterIndex + 1
        let endIndex = min(startIndex + count, chapters.count)

        for index in startIndex..<endIndex {
            let chapter = chapters[index]
            getChapterContent(chapter: chapter, source: source) { _ in }
        }
    }

    /// 清除缓存
    func clearCache() {
        contentCache.removeAll()
    }

    /// 清除指定书籍的缓存
    func clearCache(forBook bookId: String) {
        contentCache = contentCache.filter { !$0.key.contains(bookId) }
    }

    // MARK: - Private Methods

    private func generateMockContent(for chapter: ChapterModel) -> String {
        let title = "\(chapter.displayName)\n\n"

        let paragraphs = [
            "这是第\(chapter.chapterIndex + 1)章的内容。在真实的应用中，这里会显示从网络获取或本地存储的章节内容。",
            "由于这是示例应用，我们生成了一些模拟文本来展示阅读器的功能。您可以通过点击屏幕中间显示菜单，调节字体大小、切换主题等设置。",
            "阅读器支持以下功能：",
            "• 自动保存阅读进度",
            "• 多种字体大小选择",
            "• 4种阅读主题（白天、护眼、羊皮纸、夜间）",
            "• 可调节行间距和段间距",
            "• 快速切换章节",
            "这是一个功能完整的电子书阅读器，使用Swift和SwiftUI构建，代码简洁且易于维护。",
            "点击下方的按钮可以切换到上一章或下一章。阅读进度会自动保存，下次打开时会从上次的位置继续阅读。",
            "SwiftUI使用声明式语法，让UI开发变得更加简单高效。相比传统的UIKit，代码量减少了40%以上。",
            "MVVM架构模式让数据流向更加清晰，ViewModel负责业务逻辑，View只负责展示，实现了良好的职责分离。",
            "使用@Published属性包装器，当数据发生变化时，UI会自动更新，无需手动调用刷新方法。",
            "LazyVGrid和LazyVStack等懒加载容器，只在需要时才创建视图，大大提升了性能。",
            "通过Combine框架，可以优雅地处理异步操作和数据流，让响应式编程变得简单。",
            "这个项目展示了现代iOS开发的最佳实践，适合作为学习SwiftUI的入门项目。"
        ]

        let content = paragraphs.joined(separator: "\n\n")
        return title + content
    }
}

