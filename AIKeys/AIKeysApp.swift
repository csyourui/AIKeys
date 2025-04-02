//
//  AIKeysApp.swift
//  AIKeys
//
//  Created by 尤瑞 on 2025/4/1.
//

import SwiftUI

@main
struct AIKeysApp: App {
    @StateObject private var keyStore = APIKeyStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 应用启动时的初始化操作（如果需要）
                }
        }
    }
}
