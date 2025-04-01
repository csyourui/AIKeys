import SwiftUI

struct SidebarView: View {
    @ObservedObject var keyStore: APIKeyStore
    @Binding var selectedAPIKey: APIKey?
    @Binding var showingHome: Bool
    @Binding var showingAddSheet: Bool
    @Binding var searchText: String
    
    var filteredKeys: [APIKey] {
        if searchText.isEmpty {
            return keyStore.apiKeys
        } else {
            return keyStore.apiKeys.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.provider.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if filteredKeys.isEmpty && searchText.isEmpty {
                emptyStateView
            } else {
                keyListView
            }
        }
        .navigationTitle("API密钥管理")
        .searchable(text: $searchText, prompt: "搜索密钥...")
        .toolbar {
            ToolbarItem {
                Button(action: {
                    showingAddSheet = true
                }) {
                    Label("添加", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
                .help("添加新的API密钥 (⌘N)")
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("没有API密钥", systemImage: "key.slash")
                .font(.title2)
        } description: {
            Text("点击添加按钮创建新的API密钥")
                .foregroundStyle(.secondary)
        } actions: {
            Button(action: {
                showingAddSheet = true
            }) {
                Text("添加密钥")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var keyListView: some View {
        List(selection: $selectedAPIKey) {
            // 导航部分
            Section("导航") {
                NavigationLink(destination: EmptyView()) {
                    Label("首页", systemImage: "house")
                }
                .tag(Optional<APIKey>.none)
                .onTapGesture {
                    selectedAPIKey = nil
                    showingHome = true
                }
                
                Button(action: {
                    showingAddSheet = true
                }) {
                    Label("添加新密钥", systemImage: "plus.circle")
                }
                .buttonStyle(.plain)
            }
            
            // API密钥部分
            if !filteredKeys.isEmpty {
                Section("API密钥") {
                    ForEach(filteredKeys) { apiKey in
                        NavigationLink(value: apiKey) {
                            KeyListRowView(apiKey: apiKey)
                        }
                        .tag(apiKey)
                        .onChange(of: selectedAPIKey) { oldValue, newValue in
                            if newValue != nil {
                                showingHome = false
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let apiKey = filteredKeys[index]
                            keyStore.deleteAPIKey(apiKey)
                        }
                    }
                }
            } else if !searchText.isEmpty {
                // 搜索无结果
                Section {
                    ContentUnavailableView {
                        Label("未找到匹配项", systemImage: "magnifyingglass")
                    } description: {
                        Text("没有找到匹配 \"\(searchText)\" 的API密钥")
                    }
                    .frame(height: 200)
                }
            }
        }
        .listStyle(.sidebar)
    }
}

struct KeyListRowView: View {
    let apiKey: APIKey
    
    var body: some View {
        HStack(spacing: 12) {
            if let iconImage = apiKey.providerInfo?.iconImage {
                iconImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
            } else {
                fallbackIconView
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(apiKey.name)
                    .font(.headline)
                
                Text(apiKey.provider)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var fallbackIconView: some View {
        Circle()
            .fill(providerColor)
            .frame(width: 28, height: 28)
            .overlay(
                Text(String(apiKey.provider.prefix(1).uppercased()))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            )
    }
    
    private var providerColor: Color {
        let hue = Double(apiKey.provider.hashValue % 360) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
}
