import SwiftUI
import LocalAuthentication

struct TransactionReviewView: View {
    let package: TransactionPackage
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAuthentication = false
    @State private var transactionStatus: TransactionStatus?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Summary")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(package.summary)
                            .font(.headline)
                        
                        Text(package.explanation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Contract Calls")) {
                    ForEach(package.steps) { step in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Step \(step.order): \(step.title)")
                                .font(.headline)
                            
                            Text(step.explanation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if step.isExpanded {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Contract: \(step.contractAddress.prefix(6))...\(step.contractAddress.suffix(4))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Function: \(step.functionName)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if !step.parameters.isEmpty {
                                        Text("Parameters:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        ForEach(step.parameters) { param in
                                            Text("\(param.name): \(param.value)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.leading)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                                .padding(.leading)
                            }
                            
                            Button(step.isExpanded ? "Hide Details" : "Show Details") {
                                // Toggle step expansion
                            }
                            .font(.caption)
                            .padding(.top, 2)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Estimated Cost")) {
                    HStack {
                        Text("Gas Fee")
                        Spacer()
                        Text("\(package.estimatedGasETH) ETH")
                        Text("($\(String(format: "%.2f", package.estimatedGasUSD)))")
                            .foregroundColor(.secondary)
                    }
                    
                    if let status = transactionStatus {
                        HStack {
                            Text("Status")
                            Spacer()
                            
                            switch status {
                            case .pending:
                                Label("Pending", systemImage: "clock.fill")
                                    .foregroundColor(.orange)
                            case .confirmed:
                                Label("Confirmed", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            case .failed:
                                Label("Failed", systemImage: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Review Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(transactionStatus == nil ? "Approve" : "Close") {
                        if transactionStatus == nil {
                            showingAuthentication = true
                        } else {
                            dismiss()
                        }
                    }
                    .disabled(transactionStatus == .pending)
                    .bold()
                }
            }
            .alert("Authenticate", isPresented: $showingAuthentication) {
                Button("Cancel", role: .cancel) {}
                Button("Use Face ID") {
                    authenticateAndSign()
                }
            } message: {
                Text("Authenticate with Face ID to sign this transaction.")
            }
        }
    }
    
    private func authenticateAndSign() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign transaction with Face ID") { success, error in
                DispatchQueue.main.async {
                    if success {
                        // Set state to pending
                        transactionStatus = .pending
                        
                        // Send to WalletManager for signing and submitting
                        walletManager.signAndSubmitTransaction(package) { result in
                            switch result {
                            case .success:
                                transactionStatus = .confirmed
                            case .failure:
                                transactionStatus = .failed
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TransactionReviewView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionReviewView(package: TransactionPackage.mockTransaction())
            .environmentObject(WalletManager())
    }
} 