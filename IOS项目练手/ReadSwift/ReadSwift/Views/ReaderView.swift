//
//  ReaderView.swift
//  ReadSwift
//
//  阅读器视图 - SwiftUI
//

import SwiftUI

struct ReaderView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ReaderViewModel
    @StateObject private var settings = ReadingSettingsManager.shared

    @State private var showMenu = false
    @State private var showChapterList = false
    @State private var showSettings = false

    // MARK: - Initialization

    init(book: BookModel) {
        let chapters = Self.generateChapters(for: book)
        let progress = ReadingProgressManager.shared.getProgress(forBook: book.bookId)
        let currentChapterIndex = progress?.chapterIndex ?? book.currentChapter
        let currentChapter = chapters[min(currentChapterIndex, chapters.count - 1)]
        let source = BookSourceManager.shared.getEnabledSources().first ?? BookSource(sourceName: "默认", sourceUrl: "")

        _viewModel = StateObject(wrappedValue: ReaderViewModel(
            book: book,
            chapter: currentChapter,
            chapters: chapters,
            bookSource: source
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            settings.settings.theme.backgroundColor
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                if showMenu {
                    topBar
                        .transition(.move(edge: .top))
                }

                Spacer()

                contentView

                Spacer()

                if showMenu {
                    bottomBar
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .statusBar(hidden: !showMenu)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                showMenu.toggle()
            }
        }
        .sheet(isPresented: $showChapterList) {
            ChapterListView(
                chapters: viewModel.chapters,
                currentChapter: viewModel.currentChapter
            ) { chapter in
                viewModel.goToChapter(chapter)
                showChapterList = false
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Views

    private var contentView: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(viewModel.chapterContent)
                    .font(.system(size: settings.settings.fontSize))
                    .foregroundColor(settings.settings.theme.textColor)
                    .lineSpacing(settings.settings.lineSpacing)
                    .padding(EdgeInsets(
                        top: 40,
                        leading: 20,
                        bottom: 40,
                        trailing: 20
                    ))
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Text(viewModel.currentChapter.title)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            .frame(height: 56)
            .background(Color.white.opacity(0.95))

            Divider()
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()

            Text(viewModel.progress)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.top, 10)

            HStack(spacing: 40) {
                Button {
                    viewModel.previousChapter()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("上一章")
                            .font(.system(size: 12))
                    }
                }
                .disabled(!viewModel.canGoToPrevious)
                .foregroundColor(viewModel.canGoToPrevious ? .blue : .gray)

                Button {
                    showChapterList = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                        Text("目录")
                            .font(.system(size: 12))
                    }
                }
                .foregroundColor(.blue)

                Button {
                    showSettings = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape")
                        Text("设置")
                            .font(.system(size: 12))
                    }
                }
                .foregroundColor(.blue)

                Button {
                    viewModel.nextChapter()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.right")
                        Text("下一章")
                            .font(.system(size: 12))
                    }
                }
                .disabled(!viewModel.canGoToNext)
                .foregroundColor(viewModel.canGoToNext ? .blue : .gray)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.95))
        }
    }

    // MARK: - Helper Methods

    private static func generateChapters(for book: BookModel) -> [ChapterModel] {
        return (0..<book.totalChapters).map { index in
            ChapterModel(
                bookId: book.bookId,
                title: "第\(index + 1)章",
                chapterIndex: index
            )
        }
    }
}

// MARK: - ChapterListView

struct ChapterListView: View {

    let chapters: [ChapterModel]
    let currentChapter: ChapterModel
    let onSelect: (ChapterModel) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(chapters, id: \.chapterId) { chapter in
                Button {
                    onSelect(chapter)
                } label: {
                    HStack {
                        Text(chapter.displayName)
                            .foregroundColor(chapter.chapterId == currentChapter.chapterId ? .blue : .primary)

                        Spacer()

                        if chapter.chapterId == currentChapter.chapterId {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("目录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Theme Extension

extension ReadingTheme {
    var backgroundColor: Color {
        switch self {
        case .white:
            return Color.white
        case .sepia:
            return Color(red: 0.97, green: 0.93, blue: 0.82)
        case .green:
            return Color(red: 0.78, green: 0.92, blue: 0.71)
        case .night:
            return Color(red: 0.12, green: 0.12, blue: 0.12)
        }
    }

    var textColor: Color {
        switch self {
        case .white, .sepia, .green:
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        case .night:
            return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
    }
}

// MARK: - Preview

#Preview {
    let book = BookModel(title: "三体", author: "刘慈欣", currentChapter: 0, totalChapters: 46)
    return ReaderView(book: book)
}

