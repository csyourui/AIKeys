import SwiftUI

struct DetailView: View {
    @ObservedObject var keyStore: APIKeyStore
    @Binding var selectedAPIKey: APIKey?
    @Binding var showingHome: Bool
    @Binding var showingAddSheet: Bool
    @Binding var columnVisibility: NavigationSplitViewVisibility
    
    // 为每个API密钥ID存储一个验证视图模型
    @StateObject private var validationViewModels = ValidationViewModelStore()

    var body: some View {
        if showingHome {
            // 显示首页
            HomeView(
                showingAddSheet: $showingAddSheet, 
                showingHome: $showingHome, 
                columnVisibility: $columnVisibility,
                keyStore: keyStore
            )
        } else if let apiKey = selectedAPIKey {
            // 显示选中的密钥详情
            APIKeyDetailView(
                keyStore: keyStore, 
                apiKey: apiKey,
                validationViewModel: validationViewModels.getViewModel(for: apiKey.id, keyStore: keyStore)
            )
                .id(apiKey.id) // 添加唯一ID，确保每次切换密钥时都创建新的视图实例
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

// 存储验证视图模型的类
class ValidationViewModelStore: ObservableObject {
    private var viewModels: [UUID: APIKeyValidationViewModel] = [:]
    
    func getViewModel(for id: UUID, keyStore: APIKeyStore) -> APIKeyValidationViewModel {
        if let viewModel = viewModels[id] {
            return viewModel
        } else {
            let viewModel = APIKeyValidationViewModel(apiKeyStore: keyStore)
            viewModels[id] = viewModel
            return viewModel
        }
    }
}
