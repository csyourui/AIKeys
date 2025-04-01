import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct AddAPIKeyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var keyStore: APIKeyStore
    
    @State private var name: String = ""
    @State private var provider: String = ""
    @State private var apiKeyValue: String = ""
    @State private var isSecured: Bool = true
    
    // 新增的提供商详细信息
    @State private var selectedProvider: APIProvider?
    @State private var providerHomepage: String = ""
    @State private var providerBaseURL: String = ""
    @State private var providerDescription: String = ""
    @State private var showProviderDetails: Bool = false
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 使用预定义的提供商列表
    private var commonProviders: [APIProvider] { APIProvider.commonProviders }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // API密钥信息部分
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle("API密钥信息")
                        
                        FormField(title: "名称", systemImage: "tag") {
                            TextField("输入API密钥名称", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // 服务提供商选择
                        FormField(title: "服务提供商", systemImage: "building.2") {
                            HStack {
                                Menu {
                                    Button("自定义提供商") {
                                        selectedProvider = nil
                                        provider = ""
                                        resetProviderDetails()
                                    }
                                    
                                    Divider()
                                    
                                    ForEach(commonProviders) { apiProvider in
                                        Button(apiProvider.name) {
                                            provider = apiProvider.name
                                            selectedProvider = apiProvider
                                            updateProviderDetails()
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if let selectedProvider = selectedProvider {
                                            Text(selectedProvider.name)
                                        } else if provider.isEmpty {
                                            Text("选择服务提供商")
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text(provider)
                                        }
                                        
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.textBackgroundColor))
                                    )
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: selectedProvider == nil ? 180 : .infinity)
                                
                                if selectedProvider == nil {
                                    TextField("自定义提供商名称", text: $provider)
                                        .textFieldStyle(.roundedBorder)
                                        .onChange(of: provider) { oldValue, newValue in
                                            if let matchedProvider = APIProvider.findCommonProvider(byName: newValue) {
                                                selectedProvider = matchedProvider
                                                updateProviderDetails()
                                            }
                                        }
                                }
                                
                                Button(action: {
                                    showProviderDetails.toggle()
                                }) {
                                    Label("提供商详情", systemImage: "info.circle")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(.borderless)
                                .help("编辑提供商详细信息")
                            }
                        }
                        
                        // API密钥值
                        FormField(title: "API密钥值", systemImage: "key") {
                            HStack {
                                if isSecured {
                                    SecureField("输入API密钥值", text: $apiKeyValue)
                                        .textFieldStyle(.roundedBorder)
                                } else {
                                    TextField("输入API密钥值", text: $apiKeyValue)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                Button(action: {
                                    isSecured.toggle()
                                }) {
                                    Image(systemName: isSecured ? "eye" : "eye.slash")
                                }
                                .buttonStyle(.borderless)
                                .help(isSecured ? "显示密钥" : "隐藏密钥")
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.windowBackgroundColor).opacity(0.5))
                    )
                    
                    // 提供商详细信息部分（仅在showProviderDetails为true时显示）
                    if showProviderDetails {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionTitle("提供商详细信息")
                            
                            FormField(title: "官方网站", systemImage: "globe") {
                                TextField("https://example.com", text: $providerHomepage)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            FormField(title: "API基础URL", systemImage: "link") {
                                TextField("https://api.example.com", text: $providerBaseURL)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            FormField(title: "描述", systemImage: "text.justifyleft") {
                                TextField("提供商描述", text: $providerDescription)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.windowBackgroundColor).opacity(0.5))
                        )
                        .transition(.opacity)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("保存") {
                    saveAPIKey()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || provider.isEmpty || apiKeyValue.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 480, minHeight: 400)
        .alert("错误", isPresented: $showingAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "key.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("添加新的API密钥")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("请输入您的API密钥信息")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    private func updateProviderDetails() {
        if let provider = selectedProvider {
            providerHomepage = provider.homepage
            providerBaseURL = provider.baseURL
            providerDescription = provider.description
        }
    }
    
    private func resetProviderDetails() {
        providerHomepage = ""
        providerBaseURL = ""
        providerDescription = ""
    }
    
    private func saveAPIKey() {
        guard !name.isEmpty && !provider.isEmpty && !apiKeyValue.isEmpty else {
            alertMessage = "请填写所有必填字段"
            showingAlert = true
            return
        }
        
        // 创建或使用选择的提供商
        let providerInfo: APIProvider
        if let selectedProvider = selectedProvider {
            providerInfo = selectedProvider
        } else {
            providerInfo = APIProvider(
                name: provider,
                homepage: providerHomepage,
                baseURL: providerBaseURL,
                description: providerDescription,
                logoName: nil
            )
        }
        
        // 创建并保存API密钥
        let apiKey = APIKey(
            name: name,
            provider: provider,
            value: apiKeyValue,
            providerInfo: providerInfo
        )
        
        keyStore.addAPIKey(apiKey)
        dismiss()
    }
}

// 表单字段组件
struct FormField<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content
    
    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.headline)
            }
            
            content
        }
    }
}

// 区块标题组件
struct SectionTitle: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

// 占位符扩展
extension View {
    func placeholder<Content: View>(
        _ placeholder: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder content: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            content().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    func placeholder(_ text: String, when shouldShow: Bool) -> some View {
        self.placeholder(text, when: shouldShow) {
            Text(text).foregroundColor(.secondary)
        }
    }
}

#Preview {
    AddAPIKeyView(keyStore: APIKeyStore())
}
