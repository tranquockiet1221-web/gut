import Foundation

struct ModItem: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var fileName: String
    var fileSize: Int64
    var isEnabled: Bool
    var lastModified: Date
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}
