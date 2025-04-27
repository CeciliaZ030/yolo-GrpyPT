import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var walletManager: WalletManager
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack {
                        ForEach(chatViewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    if let lastMessage = chatViewModel.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(.leading)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Chat")
        .sheet(item: $chatViewModel.transactionPackage) { package in
            TransactionReviewView(package: package)
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = Message(text: messageText, isFromUser: true)
        chatViewModel.addMessage(userMessage)
        let userInput = messageText
        messageText = ""
        
        // Process user message
        chatViewModel.processUserMessage(userInput)
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            Text(message.text)
                .padding(12)
                .background(message.isFromUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.isFromUser ? .white : .primary)
                .cornerRadius(18)
                .padding(message.isFromUser ? .leading : .trailing, 60)
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView()
                .environmentObject(ChatViewModel())
                .environmentObject(WalletManager())
        }
    }
} 