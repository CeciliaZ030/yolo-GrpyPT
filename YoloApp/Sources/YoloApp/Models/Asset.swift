import Foundation

struct Asset: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let balance: Double
    let decimals: Int
    let contractAddress: String?
    let usdValue: Double?
    
    init(symbol: String, name: String, balance: Double, decimals: Int = 18, contractAddress: String? = nil, usdValue: Double? = nil) {
        self.symbol = symbol
        self.name = name
        self.balance = balance
        self.decimals = decimals
        self.contractAddress = contractAddress
        self.usdValue = usdValue
    }
} 