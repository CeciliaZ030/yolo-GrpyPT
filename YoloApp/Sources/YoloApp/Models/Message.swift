import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(text: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
} 