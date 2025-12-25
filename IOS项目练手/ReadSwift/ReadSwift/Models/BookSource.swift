//
//  BookSource.swift
//  ReadSwift
//
//  书源数据模型
//

import Foundation

/// 书源模型
class BookSource: Codable, Equatable, Identifiable {

    // MARK: - Properties

    var id: String { sourceId }  // Identifiable协议要求
    let sourceId: String
    var sourceName: String
    var sourceUrl: String
    var isEnabled: Bool
    var priority: Int

    // MARK: - Initialization

    init(sourceId: String = UUID().uuidString,
         sourceName: String,
         sourceUrl: String,
         isEnabled: Bool = true,
         priority: Int = 0) {

        self.sourceId = sourceId
        self.sourceName = sourceName
        self.sourceUrl = sourceUrl
        self.isEnabled = isEnabled
        self.priority = priority
    }

    // MARK: - Equatable

    static func == (lhs: BookSource, rhs: BookSource) -> Bool {
        return lhs.sourceId == rhs.sourceId
    }
}

