import Foundation

struct CommandPart: Identifiable {
    let id = UUID()
    let text: String
    let meaning: String
    let effect: String
    let type: PartType

    enum PartType {
        case keyword
        case subcommand
        case flag
        case argument
    }
}
