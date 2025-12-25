//
//  BookSourceManager.swift
//  ReadSwift
//
//  书源管理器
//

import Foundation
import Combine

class BookSourceManager: ObservableObject {

    // MARK: - Singleton

    static let shared = BookSourceManager()
    private init() {
        initializeDefaultSources()
        loadSources()
    }

    // MARK: - Published Properties

    @Published var sources: [BookSource] = []

    // MARK: - Constants

    private let sourcesKey = "ReadSwift_BookSources"

    // MARK: - Public Methods

    /// 加载书源
    func loadSources() {
        sources = getAllSources()
    }

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
        return sources.filter { $0.isEnabled }
    }

    /// 添加书源
    func addSource(_ source: BookSource) {
        if let index = sources.firstIndex(where: { $0.sourceId == source.sourceId }) {
            sources[index] = source
        } else {
            sources.append(source)
        }
        saveSources(sources)
    }

    /// 删除书源
    func removeSource(_ source: BookSource) {
        sources.removeAll { $0.sourceId == source.sourceId }
        saveSources(sources)
    }

    /// 切换书源启用状态
    func toggleSource(_ source: BookSource) {
        if let index = sources.firstIndex(where: { $0.sourceId == source.sourceId }) {
            sources[index].isEnabled.toggle()
            saveSources(sources)
        }
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
            var allSources = getAllSources()
            allSources.append(defaultSource)
            saveSources(allSources)
        }
    }
}

