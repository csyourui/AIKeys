//
//  ContentView.swift
//  AIKeys
//
//  Created by 尤瑞 on 2025/4/1.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var keyStore = APIKeyStore()
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var selectedAPIKey: APIKey?
    @State private var showingHome = true  // 控制是否显示首页
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic  // 控制侧边栏可见性

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // 侧边栏视图
            SidebarView(
                keyStore: keyStore,
                selectedAPIKey: $selectedAPIKey,
                showingHome: $showingHome,
                showingAddSheet: $showingAddSheet,
                searchText: $searchText,
                columnVisibility: $columnVisibility
            )
            .sheet(isPresented: $showingAddSheet) {
                AddAPIKeyView(keyStore: keyStore)
                    .frame(width: 500, height: 550)
            }
            .onChange(of: keyStore.apiKeys) { oldValue, newValue in
                // 如果没有选中的密钥或者选中的密钥已被删除，则选择第一个密钥
                if selectedAPIKey == nil
                    || !newValue.contains(where: { $0.id == selectedAPIKey?.id }
                    )
                {
                    if !newValue.isEmpty && showingHome {
                        showingHome = false
                    }
                    selectedAPIKey = showingHome ? nil : newValue.first
                }
            }
        } detail: {
            // 详情视图
            DetailView(
                keyStore: keyStore,
                selectedAPIKey: $selectedAPIKey,
                showingHome: $showingHome,
                showingAddSheet: $showingAddSheet,
                columnVisibility: $columnVisibility
            )
        }
        .frame(minWidth: 800, minHeight: 500)
    }
}

#Preview {
    ContentView()
}
