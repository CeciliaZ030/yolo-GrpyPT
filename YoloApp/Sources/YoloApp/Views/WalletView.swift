import SwiftUI

struct WalletView: View {
    @EnvironmentObject var walletManager: WalletManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Wallet")) {
                    if let address = walletManager.walletAddress {
                        HStack {
                            Text("Address")
                            Spacer()
                            Text(address.prefix(6) + "..." + address.suffix(4))
                                .font(.system(.body, design: .monospaced))
                            Button(action: {
                                UIPasteboard.general.string = address
                            }) {
                                Image(systemName: "doc.on.doc")
                            }
                        }
                    } else {
                        Button("Create Wallet") {
                            walletManager.createWallet()
                        }
                    }
                }
                
                Section(header: Text("Assets")) {
                    if walletManager.assets.isEmpty {
                        Text("No assets found")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(walletManager.assets) { asset in
                            AssetRow(asset: asset)
                        }
                    }
                }
                
                Section(header: Text("Recent Transactions")) {
                    if walletManager.transactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(walletManager.transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
            }
            .navigationTitle("Wallet")
            .refreshable {
                walletManager.refreshWallet()
            }
        }
    }
}

struct AssetRow: View {
    let asset: Asset
    
    var body: some View {
        HStack {
            Image(systemName: "dollarsign.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(asset.symbol)
                    .font(.headline)
                Text(asset.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(String(format: "%.4f", asset.balance))
                    .font(.headline)
                if let usdValue = asset.usdValue {
                    Text("$\(String(format: "%.2f", usdValue))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.status == .confirmed ? "checkmark.circle.fill" : "clock.fill")
                .foregroundColor(transaction.status == .confirmed ? .green : .orange)
            
            VStack(alignment: .leading) {
                Text(transaction.type.rawValue)
                    .font(.headline)
                Text(transaction.hash.prefix(10) + "..." + transaction.hash.suffix(6))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(transaction.formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
            .environmentObject(WalletManager())
    }
} 