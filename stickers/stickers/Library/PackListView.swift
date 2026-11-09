import SwiftUI
import SwiftData

struct PackListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \StickerPack.createdAt) private var packs: [StickerPack]

    @State private var showingNewPack = false
    @State private var newName = ""
    @State private var packToRename: StickerPack?
    @State private var renameText = ""
    @State private var packToDelete: StickerPack?

    private var library: PackLibrary { PackLibrary(context: context, files: .default) }

    var body: some View {
        NavigationStack {
            Group {
                if packs.isEmpty {
                    ContentUnavailableView {
                        Label("Nenhum pacote", systemImage: "square.stack")
                    } description: {
                        Text("Crie um pacote para começar a montar suas figurinhas.")
                    } actions: {
                        Button("Criar pacote") { showingNewPack = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(packs) { pack in
                        NavigationLink(value: pack) { row(pack) }
                            .swipeActions {
                                Button("Apagar", role: .destructive) { packToDelete = pack }
                                Button("Renomear") { renameText = pack.name; packToRename = pack }
                                    .tint(.blue)
                            }
                    }
                }
            }
            .navigationTitle("Figurinhas")
            .navigationDestination(for: StickerPack.self) { PackDetailView(pack: $0) }
            .toolbar {
                Button("Novo pacote", systemImage: "plus") { showingNewPack = true }
            }
            .alert("Novo pacote", isPresented: $showingNewPack) {
                TextField("Nome", text: $newName)
                Button("Criar") { library.createPack(named: newName); newName = "" }
                    .disabled(PackLibrary.validName(newName) == nil)
                Button("Cancelar", role: .cancel) { newName = "" }
            } message: {
                Text("Informe um nome para o pacote.")
            }
            .alert("Renomear pacote", isPresented: Binding(
                get: { packToRename != nil }, set: { if !$0 { packToRename = nil } }
            )) {
                TextField("Nome", text: $renameText)
                Button("Salvar") { if let pack = packToRename { library.rename(pack, to: renameText) } }
                    .disabled(PackLibrary.validName(renameText) == nil)
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("O nome não pode ficar vazio.")
            }
            .confirmationDialog("Apagar o pacote e todas as suas figurinhas?",
                                isPresented: Binding(get: { packToDelete != nil }, set: { if !$0 { packToDelete = nil } }),
                                titleVisibility: .visible) {
                Button("Apagar", role: .destructive) { if let pack = packToDelete { library.delete(pack) } }
            }
        }
    }

    private func row(_ pack: StickerPack) -> some View {
        HStack {
            PackIconView(pack: pack)
            VStack(alignment: .leading) {
                Text(pack.name).font(.headline)
                Text("\(pack.stickers.count) figurinhas").font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
