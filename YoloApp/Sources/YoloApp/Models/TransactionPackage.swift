import Foundation

struct TransactionParameter: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let type: String
}

struct TransactionStep: Identifiable {
    let id = UUID()
    let order: Int
    let title: String
    let explanation: String
    let contractAddress: String
    let functionName: String
    let parameters: [TransactionParameter]
    var isExpanded: Bool = false
}

struct TransactionPackage: Identifiable {
    let id = UUID()
    let summary: String
    let explanation: String
    let steps: [TransactionStep]
    let estimatedGasETH: String
    let estimatedGasUSD: Double
    
    static func mockTransaction() -> TransactionPackage {
        return TransactionPackage(
            summary: "Swap 0.1 ETH for USDC on Uniswap",
            explanation: "This transaction will swap your ETH for USDC using Uniswap's automated market maker.",
            steps: [
                TransactionStep(
                    order: 1,
                    title: "Approve Uniswap Router",
                    explanation: "First, we need to allow Uniswap to access your ETH for the swap.",
                    contractAddress: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
                    functionName: "approve",
                    parameters: [
                        TransactionParameter(name: "spender", value: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", type: "address"),
                        TransactionParameter(name: "amount", value: "100000000000000000", type: "uint256")
                    ]
                ),
                TransactionStep(
                    order: 2,
                    title: "Execute Swap",
                    explanation: "Now, we'll execute the swap from ETH to USDC through Uniswap.",
                    contractAddress: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
                    functionName: "swapExactETHForTokens",
                    parameters: [
                        TransactionParameter(name: "amountOutMin", value: "25000000", type: "uint256"),
                        TransactionParameter(name: "path", value: "[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48]", type: "address[]"),
                        TransactionParameter(name: "to", value: "0x1234567890abcdef1234567890abcdef12345678", type: "address"),
                        TransactionParameter(name: "deadline", value: "1719999999", type: "uint256")
                    ]
                )
            ],
            estimatedGasETH: "0.003",
            estimatedGasUSD: 9.45
        )
    }
} 