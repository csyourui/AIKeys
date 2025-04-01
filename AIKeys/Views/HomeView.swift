import SwiftUI

struct HomeView: View {
    @Binding var showingAddSheet: Bool
    @ObservedObject var keyStore: APIKeyStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 应用图标和标题
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)

                    Text("API密钥管理器")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("安全存储和管理您的API密钥")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)

                // 应用统计信息
                HStack(spacing: 40) {
                    statsView(
                        count: keyStore.apiKeys.count,
                        title: "已保存密钥",
                        icon: "key"
                    )

                    statsView(
                        count: Set(keyStore.apiKeys.map { $0.provider }).count,
                        title: "服务提供商",
                        icon: "building.2"
                    )
                }
                .padding(.vertical, 20)

                // 快速操作
                VStack(alignment: .leading, spacing: 16) {
                    Text("快速操作")
                        .font(.headline)

                    HStack(spacing: 20) {
                        actionButton(
                            title: "添加新密钥",
                            icon: "plus.circle",
                            action: {
                                showingAddSheet = true
                            }
                        )

                        if !keyStore.apiKeys.isEmpty {
                            actionButton(
                                title: "查看所有密钥",
                                icon: "list.bullet",
                                action: {
                                    // 这个操作由NavigationSplitView自动处理
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 20)

                // 使用提示
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("使用提示", systemImage: "lightbulb")
                            .font(.headline)

                        tipView(icon: "1.circle", tip: "添加API密钥：点击添加按钮或使用⌘N快捷键")
                        tipView(icon: "2.circle", tip: "查看密钥详情：从左侧列表选择一个密钥")
                        tipView(icon: "3.circle", tip: "复制密钥：在详情页面点击复制按钮")
                        tipView(icon: "4.circle", tip: "删除密钥：在详情页面点击删除按钮")
                    }
                    .padding(8)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func statsView(count: Int, title: String, icon: String) -> some View
    {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.blue)

            Text("\(count)")
                .font(.system(size: 36, weight: .bold))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 100)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func actionButton(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))

                Text(title)
                    .font(.callout)
                    .multilineTextAlignment(.center)
            }
            .frame(minWidth: 100, minHeight: 80)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.controlBackgroundColor))
            )
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func tipView(icon: String, tip: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            Text(tip)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    HomeView(showingAddSheet: .constant(false), keyStore: APIKeyStore())
}
