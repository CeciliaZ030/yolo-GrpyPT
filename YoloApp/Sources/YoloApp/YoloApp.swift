import SwiftUI

@main
struct YoloApp: App {
    @StateObject private var walletManager = WalletManager()
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(walletManager)
                .environmentObject(chatViewModel)
        }
    }
} 