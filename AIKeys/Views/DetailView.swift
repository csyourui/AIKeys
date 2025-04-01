import SwiftUI

struct DetailView: View {
    @ObservedObject var keyStore: APIKeyStore
    @Binding var selectedAPIKey: APIKey?
    @Binding var showingHome: Bool
    @Binding var showingAddSheet: Bool
    
    var body: some View {
        if showingHome {
            // 显示首页
            HomeView(showingAddSheet: $showingAddSheet, keyStore: keyStore)
        } else if let apiKey = selectedAPIKey {
            // 显示选中的密钥详情
            APIKeyDetailView(keyStore: keyStore, apiKey: apiKey)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            showingHome = true
                            selectedAPIKey = nil
                        }) {
                            Label("返回首页", systemImage: "house")
                        }
                    }
                }
        } else {
            // 未选中密钥且不显示首页时的提示
            ContentUnavailableView {
                Label("未选择API密钥", systemImage: "key")
            } description: {
                Text("请从左侧列表选择一个API密钥查看详情")
            } actions: {
                Button(action: {
                    showingAddSheet = true
                }) {
                    Text("添加新密钥")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    showingHome = true
                }) {
                    Text("返回首页")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
