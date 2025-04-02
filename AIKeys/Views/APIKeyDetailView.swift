import SwiftUI

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

struct APIKeyDetailView: View {
    @ObservedObject var keyStore: APIKeyStore
    let apiKey: APIKey
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingDeleteConfirmation = false
    @State private var isValueVisible = false
    @State private var copiedToClipboard = false
    @ObservedObject var validationViewModel: APIKeyValidationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView

                Divider()

                infoSection

                // 添加提供商详细信息部分
                if hasProviderDetails {
                    providerSection
                }

                keySection

                // 添加验证部分
                validationSection

                keychainSection

                Spacer()

                deleteButton
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("API密钥详情")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("删除", systemImage: "trash")
                }
                .help("删除此API密钥")
            }
        }
        .alert("确认删除", isPresented: $showingDeleteConfirmation) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                keyStore.deleteAPIKey(apiKey)
                dismiss()
            }
        } message: {
            Text("确定要删除这个API密钥吗？此操作无法撤销。")
        }
        .onAppear {
            // 在视图出现时加载持久化的验证状态
            validationViewModel.checkSavedValidation(apiKey: apiKey)
        }
    }

    // 判断是否有提供商详细信息
    private var hasProviderDetails: Bool {
        return !apiKey.providerHomepage.isEmpty
            || !apiKey.providerBaseURL.isEmpty
            || !apiKey.providerDescription.isEmpty
    }

    private var headerView: some View {
        HStack(spacing: 16) {
            if let iconImage = apiKey.providerInfo?.iconImage {
                iconImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                fallbackHeaderIconView
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(apiKey.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(apiKey.provider)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    private var fallbackHeaderIconView: some View {
        Circle()
            .fill(providerColor)
            .frame(width: 48, height: 48)
            .overlay(
                Text(String(apiKey.provider.prefix(1).uppercased()))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            )
    }

    private var infoSection: some View {
        GroupBox(label: Text("基本信息").font(.headline)) {
            VStack(spacing: 12) {
                DetailRow(title: "名称", value: apiKey.name, icon: "tag")
                DetailRow(
                    title: "服务提供商",
                    value: apiKey.provider,
                    icon: "building.2"
                )
                DetailRow(
                    title: "添加日期",
                    value: apiKey.dateAdded.formatted(
                        date: .long,
                        time: .shortened
                    ),
                    icon: "calendar"
                )
            }
            .padding(.vertical, 8)
        }
    }

    // 新增的提供商详细信息部分
    private var providerSection: some View {
        GroupBox(label: Text("提供商信息").font(.headline)) {
            VStack(spacing: 12) {
                if !apiKey.providerHomepage.isEmpty {
                    LinkRow(
                        title: "官方网站",
                        value: apiKey.providerHomepage,
                        icon: "globe",
                        url: URL(string: apiKey.providerHomepage)
                    )
                }

                if !apiKey.providerBaseURL.isEmpty {
                    LinkRow(
                        title: "API基础URL",
                        value: apiKey.providerBaseURL,
                        icon: "link",
                        url: URL(string: apiKey.providerBaseURL)
                    )
                }

                if !apiKey.providerDescription.isEmpty {
                    DetailRow(
                        title: "描述",
                        value: apiKey.providerDescription,
                        icon: "info.circle"
                    )
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var keySection: some View {
        GroupBox(label: Text("API密钥").font(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    if isValueVisible {
                        Text(apiKey.value)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(8)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(4)
                    } else {
                        Text(String(repeating: "•", count: 20))
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(4)
                    }

                    Spacer()

                    Button(action: {
                        isValueVisible.toggle()
                    }) {
                        Image(systemName: isValueVisible ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.borderless)
                    .help(isValueVisible ? "隐藏API密钥" : "显示API密钥")
                }

                HStack(spacing: 16) {
                    Button(action: {
                        #if os(iOS)
                            UIPasteboard.general.string = apiKey.value
                        #elseif os(macOS)
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(apiKey.value, forType: .string)
                        #endif

                        copiedToClipboard = true

                        // 3秒后重置提示
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            copiedToClipboard = false
                        }
                    }) {
                        Label("复制到剪贴板", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)

                    if copiedToClipboard {
                        Text("已复制!")
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // 新增的验证部分
    private var validationSection: some View {
        GroupBox(label: Text("API密钥验证").font(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
                ValidationStatusView(status: validationViewModel.status)

                HStack {
                    Button(action: {
                        validationViewModel.validateAPIKey(apiKey: apiKey)
                    }) {
                        Label("验证API密钥", systemImage: "checkmark.shield")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(validationViewModel.status == .validating)

                    if validationViewModel.status == .validating {
                        ProgressView()
                            .padding(.leading, 8)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var keychainSection: some View {
        GroupBox(label: Text("Keychain信息").font(.headline)) {
            DetailRow(
                title: "Keychain项ID",
                value: keyStore.getKeychainItemID(for: apiKey),
                icon: "key"
            )
            .padding(.vertical, 8)
        }
    }

    private var deleteButton: some View {
        Button(
            role: .destructive,
            action: {
                showingDeleteConfirmation = true
            }
        ) {
            Label("删除API密钥", systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.red)
    }

    private var providerColor: Color {
        let hue = Double(apiKey.provider.hashValue % 360) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
}

// 详情行视图
struct DetailRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.accentColor)

            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}

// 带链接的详情行视图
struct LinkRow: View {
    let title: String
    let value: String
    let icon: String
    let url: URL?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.accentColor)

            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            if let url = url {
                Link(value, destination: url)
                    .multilineTextAlignment(.trailing)
            } else {
                Text(value)
                    .multilineTextAlignment(.trailing)
                    .textSelection(.enabled)
            }
        }
    }
}

#Preview {
    let keyStore = APIKeyStore()
    let previewKey = APIKey(
        name: "测试密钥",
        provider: "OpenAI",
        value: "sk-1234567890abcdef1234567890abcdef"
    )
    let validationViewModel = APIKeyValidationViewModel(apiKeyStore: keyStore)
    return APIKeyDetailView(keyStore: keyStore, apiKey: previewKey, validationViewModel: validationViewModel)
}
