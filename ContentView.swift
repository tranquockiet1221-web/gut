import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var manager = ModManager()
    @State private var isImporting = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Truy cập trực tiếp")
                                .font(.subheadline.weight(.semibold))
                            Text(manager.statusMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(manager.mods.filter(\.isEnabled).count)/\(manager.mods.count) bật")
                            .font(.caption.monospacedDigit())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.secondary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                } header: {
                    Text("Hệ thống")
                }
                
                Section {
                    if manager.filteredMods.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "folder.badge.plus")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("Chưa có tệp nào trong thư mục Mods")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Nhấn nút + để nhập tệp từ ứng dụng Tệp (Files) hoặc chép vào thư mục LocalHub/Mods.")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(manager.filteredMods) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.body.weight(.medium))
                                    Text("\(item.fileName) • \(item.formattedSize)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { item.isEnabled },
                                    set: { _ in manager.toggleMod(item) }
                                ))
                                .labelsHidden()
                            }
                        }
                        .onDelete(perform: manager.deleteMods)
                    }
                } header: {
                    Text("Danh sách Mods")
                }
            }
            .navigationTitle("LocalHub")
            .searchable(text: $manager.searchText, prompt: "Tìm kiếm mod...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        manager.scanModsDirectory()
                    } label: {
                        Label("Làm mới", systemImage: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isImporting = true
                    } label: {
                        Label("Thêm tệp", systemImage: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let firstURL = urls.first {
                        manager.importFile(from: firstURL)
                    }
                case .failure(let error):
                    manager.statusMessage = "Lỗi chọn tệp: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
