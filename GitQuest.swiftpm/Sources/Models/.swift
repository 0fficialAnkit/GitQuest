import Foundation

struct CommandPartExplanation: Identifiable {
    let id = UUID()
    let part: String
    let meaning: String
    let purposeInCommand: String
}
