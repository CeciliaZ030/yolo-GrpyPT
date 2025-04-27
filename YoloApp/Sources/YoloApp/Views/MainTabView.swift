import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var walletManager: WalletManager
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    var body: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.fill")
                }
            
            WalletView()
                .tabItem {
                    Label("Wallet", systemImage: "wallet.pass.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(WalletManager())
            .environmentObject(ChatViewModel())
    }
} 