import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var showingResetConfirmation = false
    @State private var selectedNode = "Infura"
    @State private var apiKey = ""
    @State private var requireFaceID = true
    
    let nodeOptions = ["Infura", "Alchemy", "Custom"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ethereum Network")) {
                    Picker("Node Provider", selection: $selectedNode) {
                        ForEach(nodeOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    if selectedNode != "Custom" {
                        SecureField("API Key", text: $apiKey)
                    } else {
                        TextField("RPC URL", text: $apiKey)
                    }
                    
                    Button("Test Connection") {
                        // Implement connection test
                    }
                }
                
                Section(header: Text("Security")) {
                    Toggle("Require Face ID for Transactions", isOn: $requireFaceID)
                    
                    NavigationLink(destination: Text("Change Passcode View")) {
                        Text("Change Backup Passcode")
                    }
                }
                
                Section(header: Text("Advanced")) {
                    Button("Export Private Key") {
                        // Implement with Face ID verification
                    }
                    .foregroundColor(.blue)
                    
                    Button("Reset Wallet") {
                        showingResetConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Wallet", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    walletManager.resetWallet()
                }
            } message: {
                Text("This will delete your wallet from this device. Make sure you have backed up your private key before proceeding.")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WalletManager())
    }
} 