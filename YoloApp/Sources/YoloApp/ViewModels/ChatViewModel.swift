import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var transactionPackage: TransactionPackage?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let apiClient = APIClient()
    
    init() {
        // Add a welcome message
        let welcomeMessage = Message(
            text: "👋 Hey there! I'm your AI assistant. You can ask me to perform crypto transactions using natural language. Try saying something like 'Swap 0.1 ETH for USDC on Uniswap' or 'Withdraw my stETH from Lido'.",
            isFromUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func addMessage(_ message: Message) {
        messages.append(message)
    }
    
    func processUserMessage(_ text: String) {
        isLoading = true
        
        // In a real app, this would send the text to the backend for processing
        // For demo, we'll simulate a response
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Check if it looks like a transaction request
            if self.isTransactionRequest(text) {
                // Add an AI response
                let aiResponse = Message(
                    text: "I understand you want to make a transaction. Let me prepare that for you...",
                    isFromUser: false
                )
                self.addMessage(aiResponse)
                
                // Simulate preparing a transaction package
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // For demo, show a mock transaction
                    self.transactionPackage = TransactionPackage.mockTransaction()
                    self.isLoading = false
                }
            } else {
                // Regular chat response
                let aiResponse = Message(
                    text: self.generateChatResponse(to: text),
                    isFromUser: false
                )
                self.addMessage(aiResponse)
                self.isLoading = false
            }
        }
    }
    
    private func isTransactionRequest(_ text: String) -> Bool {
        let transactionKeywords = [
            "swap", "transfer", "send", "buy", "sell", "withdraw", "deposit",
            "stake", "unstake", "bridge", "approve", "uniswap", "eth", "usdc"
        ]
        
        let lowercasedText = text.lowercased()
        return transactionKeywords.contains { lowercasedText.contains($0) }
    }
    
    private func generateChatResponse(to text: String) -> String {
        // In a real app, this would call an LLM
        // For demo, we'll provide some canned responses
        
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("hello") || lowercasedText.contains("hi") {
            return "Hello! How can I help with your crypto today?"
        } else if lowercasedText.contains("help") {
            return "I can help you perform various crypto operations using natural language. Try asking me to swap tokens, check balances, or manage your DeFi positions."
        } else if lowercasedText.contains("balance") || lowercasedText.contains("how much") {
            return "To check your balance, you can view the Wallet tab. Currently you have 1.234 ETH, 5000 USDC, and 0.5 stETH."
        } else if lowercasedText.contains("thank") {
            return "You're welcome! Anything else I can help with?"
        } else {
            return "I'm not sure how to respond to that. Try asking me to perform a crypto transaction like 'Swap 0.1 ETH for USDC on Uniswap'."
        }
    }
} 