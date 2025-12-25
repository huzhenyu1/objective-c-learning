//
//  BookSourceManager.swift
//  ReadSwift
//
//  书源管理器
//

import Foundation

class BookSourceManager {

    // MARK: - Singleton

    static let shared = BookSourceManager()
    private init() {
        initializeDefaultSources()
    }

    // MARK: - Constants

    private let sourcesKey = "ReadSwift_BookSources"

    // MARK: - Public Methods

    /// 获取所有书源
    func getAllSources() -> [BookSource] {
        guard let data = UserDefaults.standard.data(forKey: sourcesKey),
              let sources = try? JSONDecoder().decode([BookSource].self, from: data) else {
            return []
        }
        return sources.sorted { $0.priority > $1.priority }
    }

    /// 获取启用的书源
    func getEnabledSources() -> [BookSource] {
        return getAllSources().filter { $0.isEnabled }
    }

    /// 添加书源
    func addSource(_ source: BookSource) {
        var sources = getAllSources()

        if let index = sources.firstIndex(where: { $0.sourceId == source.sourceId }) {
            sources[index] = source
        } else {
            sources.append(source)
        }

        saveSources(sources)
    }

    /// 删除书源
    func removeSource(_ source: BookSource) {
        var sources = getAllSources()
        sources.removeAll { $0.sourceId == source.sourceId }
        saveSources(sources)
    }

    /// 更新书源
    func updateSource(_ source: BookSource) {
        addSource(source)
    }

    // MARK: - Private Methods

    private func saveSources(_ sources: [BookSource]) {
        if let data = try? JSONEncoder().encode(sources) {
            UserDefaults.standard.set(data, forKey: sourcesKey)
        }
    }

    private func initializeDefaultSources() {
        if getAllSources().isEmpty {
            let defaultSource = BookSource(
                sourceName: "默认书源",
                sourceUrl: "https://api.example.com",
                isEnabled: true,
                priority: 100
            )
            addSource(defaultSource)
        }
    }
}

