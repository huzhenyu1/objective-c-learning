//
//  MainTabView.swift
//  ReadSwift
//
//  主界面 - 底部TabBar导航
//

import SwiftUI

struct MainTabView: View {

    // MARK: - Properties

    @State private var selectedTab: TabItem = .bookshelf

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // 当前选中的视图
            Group {
                switch selectedTab {
                case .bookshelf:
                    BookshelfView()
                case .bookSource:
                    BookSourceView()
                case .profile:
                    ProfileView()
                }
            }

            // 底部浮动TabBar
            floatingTabBar
        }
    }

    // MARK: - 浮动TabBar

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == tab ? .blue : .gray)

                        Text(tab.title)
                            .font(.system(size: 11))
                            .foregroundColor(selectedTab == tab ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - TabItem

enum TabItem: CaseIterable {
    case bookshelf
    case bookSource
    case profile

    var title: String {
        switch self {
        case .bookshelf:
            return "书架"
        case .bookSource:
            return "书源"
        case .profile:
            return "个人"
        }
    }

    var icon: String {
        switch self {
        case .bookshelf:
            return "books.vertical"
        case .bookSource:
            return "globe"
        case .profile:
            return "person"
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
