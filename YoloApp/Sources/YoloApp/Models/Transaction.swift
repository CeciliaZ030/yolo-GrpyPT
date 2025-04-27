import Foundation

enum TransactionStatus: String {
    case pending
    case confirmed
    case failed
}

enum TransactionType: String {
    case transfer = "Transfer"
    case swap = "Swap"
    case approval = "Approval"
    case stake = "Stake"
    case unstake = "Unstake"
    case other = "Contract Interaction"
}

struct Transaction: Identifiable {
    let id = UUID()
    let hash: String
    let timestamp: Date
    let from: String
    let to: String
    let value: Double
    let gasUsed: Double
    let status: TransactionStatus
    let type: TransactionType
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
} 