import SwiftUI

struct APIKeyEditView: View {
    @ObservedObject var keyStore: APIKeyStore
    let apiKey: APIKey
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var name: String
    @State private var provider: String
    @State private var selectedProvider: APIProvider?
    @State private var value: String
    @State private var isValueVisible: Bool = false
    @State private var providerBaseURL: String
    @State private var providerDescription: String
    @State private var providerDefaultModel: String
    
    // 获取所有可用的提供商
    private let availableProviders = APIProvider.commonProviders
    
    init(keyStore: APIKeyStore, apiKey: APIKey) {
        self.keyStore = keyStore
        self.apiKey = apiKey
        
        // 初始化状态变量
        _name = State(initialValue: apiKey.name)
        _provider = State(initialValue: apiKey.provider)
        _value = State(initialValue: apiKey.value)
        _selectedProvider = State(initialValue: apiKey.providerInfo)
        _providerBaseURL = State(initialValue: apiKey.providerBaseURL)
        _providerDescription = State(initialValue: apiKey.providerDescription)
        _providerDefaultModel = State(initialValue: apiKey.providerDefaultModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text("编辑API密钥")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(colorScheme == .dark ? .darkGray : .white))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 基本信息
                    GroupBox(label: 
                        Label("基本信息", systemImage: "info.circle")
                            .font(.headline)
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("名称")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("请输入API密钥名称", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 4)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("服务提供商")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("选择服务提供商", selection: $provider) {
                                    ForEach(availableProviders) { availableProvider in
                                        Text(availableProvider.name).tag(availableProvider.name)
                                    }
                                    Text("自定义").tag("自定义")
                                }
                                .pickerStyle(.menu)
                                .onChange(of: provider) { oldValue, newValue in
                                    if let newProvider = APIProvider.findCommonProvider(byName: newValue) {
                                        selectedProvider = newProvider
                                        providerBaseURL = newProvider.baseURL
                                        providerDescription = newProvider.description
                                        providerDefaultModel = newProvider.defaultModel
                                    } else {
                                        selectedProvider = nil
                                    }
                                }
                                
                                if provider == "自定义" {
                                    TextField("请输入自定义服务提供商名称", text: $provider)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    // API密钥值
                    GroupBox(label: 
                        Label("API密钥", systemImage: "key.fill")
                            .font(.headline)
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                if isValueVisible {
                                    TextField("API密钥值", text: $value)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.system(.body, design: .monospaced))
                                } else {
                                    SecureField("API密钥值", text: $value)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.system(.body, design: .monospaced))
                                }
                                
                                Button(action: {
                                    isValueVisible.toggle()
                                }) {
                                    Image(systemName: isValueVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.accentColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    // 提供商详细信息
                    if provider != "自定义" && selectedProvider != nil {
                        GroupBox(label: 
                            Label("提供商详细信息", systemImage: "building.2.fill")
                                .font(.headline)
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text("API基础URL")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("API基础URL", text: $providerBaseURL)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disabled(true)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("默认模型")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("默认模型", text: $providerDefaultModel)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disabled(true)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("描述")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(providerDescription)
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.textBackgroundColor))
                                        .cornerRadius(4)
                                }
                            }
                            .padding()
                        }
                        .padding(.horizontal)
                    } else if provider == "自定义" {
                        GroupBox(label: 
                            Label("自定义提供商信息", systemImage: "building.2.fill")
                                .font(.headline)
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text("API基础URL")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("请输入API基础URL", text: $providerBaseURL)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("默认模型")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("请输入默认模型", text: $providerDefaultModel)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("描述")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("请输入描述", text: $providerDescription)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .padding()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Spacer()
                
                Button("保存") {
                    saveChanges()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!isFormValid)
            }
            .padding()
        }
        .frame(width: 600, height: 700)
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !provider.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveChanges() {
        // 创建或获取提供商信息
        var providerInfo: APIProvider?
        if let existingProvider = APIProvider.findCommonProvider(byName: provider) {
            providerInfo = existingProvider
        } else {
            // 创建自定义提供商
            providerInfo = APIProvider(
                name: provider,
                homepage: "",
                baseURL: providerBaseURL,
                description: providerDescription,
                logoName: nil,
                defaultModel: providerDefaultModel
            )
        }
        
        // 更新API密钥
        keyStore.updateAPIKey(
            id: apiKey.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            provider: provider.trimmingCharacters(in: .whitespacesAndNewlines),
            value: value.trimmingCharacters(in: .whitespacesAndNewlines),
            providerID: providerInfo?.id
        )
        dismiss()
    }
}

#Preview {
    let keyStore = APIKeyStore()
    let previewKey = APIKey(
        name: "测试密钥",
        provider: "OpenAI",
        value: "sk-1234567890abcdef1234567890abcdef"
    )
    return APIKeyEditView(keyStore: keyStore, apiKey: previewKey)
}
