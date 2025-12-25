//
//  ReaderViewModel.swift
//  ReadSwift
//
//  阅读器视图模型
//

import Foundation
import Combine

class ReaderViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentChapter: ChapterModel
    @Published var chapterContent: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var progress: String = ""

    // MARK: - Properties

    let book: BookModel
    let chapters: [ChapterModel]
    let bookSource: BookSource

    var canGoToPrevious: Bool {
        currentChapter.chapterIndex > 0
    }

    var canGoToNext: Bool {
        currentChapter.chapterIndex < chapters.count - 1
    }

    // MARK: - Initialization

    init(book: BookModel, chapter: ChapterModel, chapters: [ChapterModel], bookSource: BookSource) {
        self.book = book
        self.currentChapter = chapter
        self.chapters = chapters
        self.bookSource = bookSource

        loadChapterContent()
    }

    // MARK: - Public Methods

    /// 加载章节内容
    func loadChapterContent() {
        isLoading = true
        updateProgress()

        ReadingContentManager.shared.getChapterContent(
            chapter: currentChapter,
            source: bookSource
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let content):
                    self?.chapterContent = content
                    self?.saveProgress()
                    self?.preloadNextChapters()

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }

    /// 上一章
    func previousChapter() {
        guard canGoToPrevious else { return }
        currentChapter = chapters[currentChapter.chapterIndex - 1]
        loadChapterContent()
    }

    /// 下一章
    func nextChapter() {
        guard canGoToNext else { return }
        currentChapter = chapters[currentChapter.chapterIndex + 1]
        loadChapterContent()
    }

    /// 跳转到指定章节
    func goToChapter(_ chapter: ChapterModel) {
        currentChapter = chapter
        loadChapterContent()
    }

    // MARK: - Private Methods

    private func saveProgress() {
        ReadingProgressManager.shared.saveProgress(
            bookId: book.bookId,
            chapterIndex: currentChapter.chapterIndex
        )
    }

    private func updateProgress() {
        progress = "\(currentChapter.chapterIndex + 1)/\(chapters.count)"
    }

    private func preloadNextChapters() {
        ReadingContentManager.shared.preloadNextChapters(
            currentChapter: currentChapter,
            chapters: chapters,
            source: bookSource,
            count: 2
        )
    }
}
