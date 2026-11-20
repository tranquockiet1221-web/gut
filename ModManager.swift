import Foundation
import Combine

@MainActor
final class ModManager: ObservableObject {
    @Published var mods: [ModItem] = []
    @Published var statusMessage: String = "Sẵn sàng (Không yêu cầu key)"
    @Published var searchText: String = ""
    
    private let fileManager = FileManager.default
    private let stateStorageKey = "LocalHub.EnabledModStates.v1"
    
    var filteredMods: [ModItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return mods
        }
        return mods.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.fileName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var modsDirectoryURL: URL? {
        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return docs.appendingPathComponent("Mods", isDirectory: true)
    }
    
    init() {
        setupAndScan()
    }
    
    func setupAndScan() {
        guard let modsURL = modsDirectoryURL else {
            statusMessage = "Lỗi: Không tìm thấy thư mục Documents"
            return
        }
        
        do {
            if !fileManager.fileExists(atPath: modsURL.path) {
                try fileManager.createDirectory(at: modsURL, withIntermediateDirectories: true)
            }
            copyBundledModsIfNeeded(to: modsURL)
            scanModsDirectory()
        } catch {
            statusMessage = "Lỗi khởi tạo: \(error.localizedDescription)"
        }
    }
    
    private func copyBundledModsIfNeeded(to destinationDir: URL) {
        guard let bundledModsURL = Bundle.main.resourceURL?.appendingPathComponent("Mods", isDirectory: true),
              fileManager.fileExists(atPath: bundledModsURL.path) else {
            return
        }
        
        guard let bundledFiles = try? fileManager.contentsOfDirectory(at: bundledModsURL, includingPropertiesForKeys: nil) else {
            return
        }
        
        for fileURL in bundledFiles {
            let fileName = fileURL.lastPathComponent
            if fileName == ".gitkeep" || fileURL.hasDirectoryPath { continue }
            let destURL = destinationDir.appendingPathComponent(fileName)
            if !fileManager.fileExists(atPath: destURL.path) {
                try? fileManager.copyItem(at: fileURL, to: destURL)
            }
        }
    }
    
    func scanModsDirectory() {
        guard let modsURL = modsDirectoryURL else { return }
        let savedStates = loadSavedStates()
        
        do {
            let resourceKeys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey]
            let fileURLs = try fileManager.contentsOfDirectory(at: modsURL, includingPropertiesForKeys: resourceKeys)
            
            var loadedItems: [ModItem] = []
            for url in fileURLs {
                let values = try? url.resourceValues(forKeys: Set(resourceKeys))
                if values?.isDirectory == true { continue }
                
                let fileName = url.lastPathComponent
                if fileName == ".gitkeep" || fileName.hasPrefix(".") { continue }
                
                let displayName = url.deletingPathExtension().lastPathComponent
                let size = Int64(values?.fileSize ?? 0)
                let modified = values?.contentModificationDate ?? Date()
                let isEnabled = savedStates[fileName] ?? false
                
                loadedItems.append(
                    ModItem(
                        id: fileName,
                        name: displayName,
                        fileName: fileName,
                        fileSize: size,
                        isEnabled: isEnabled,
                        lastModified: modified
                    )
                )
            }
            
            mods = loadedItems.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            statusMessage = "Đã nạp \(mods.count) tệp từ thư mục Mods"
        } catch {
            statusMessage = "Lỗi đọc thư mục: \(error.localizedDescription)"
        }
    }
    
    func toggleMod(_ item: ModItem) {
        guard let index = mods.firstIndex(where: { $0.id == item.id }) else { return }
        mods[index].isEnabled.toggle()
        saveStates()
        let stateText = mods[index].isEnabled ? "BẬT" : "TẮT"
        statusMessage = "\(mods[index].name): \(stateText)"
    }
    
    func importFile(from sourceURL: URL) {
        guard let modsURL = modsDirectoryURL else { return }
        let accessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let destURL = modsURL.appendingPathComponent(sourceURL.lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destURL)
            scanModsDirectory()
            statusMessage = "Đã thêm: \(sourceURL.lastPathComponent)"
        } catch {
            statusMessage = "Lỗi nhập tệp: \(error.localizedDescription)"
        }
    }
    
    func deleteMods(at offsets: IndexSet) {
        guard let modsURL = modsDirectoryURL else { return }
        let itemsToDelete = offsets.map { filteredMods[$0] }
        
        for item in itemsToDelete {
            let targetURL = modsURL.appendingPathComponent(item.fileName)
            try? fileManager.removeItem(at: targetURL)
        }
        
        scanModsDirectory()
        saveStates()
        statusMessage = "Đã xóa \(itemsToDelete.count) tệp"
    }
    
    private func loadSavedStates() -> [String: Bool] {
        UserDefaults.standard.dictionary(forKey: stateStorageKey) as? [String: Bool] ?? [:]
    }
    
    private func saveStates() {
        var dict: [String: Bool] = [:]
        for item in mods {
            dict[item.fileName] = item.isEnabled
        }
        UserDefaults.standard.set(dict, forKey: stateStorageKey)
    }
}
