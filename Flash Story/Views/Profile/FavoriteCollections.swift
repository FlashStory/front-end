import SwiftUI

// MARK: - View Model

class FavoriteCollectionsViewModel: ObservableObject {
    @Published var favoriteCollections: [String: String] = [:]
    @Published var isLoading = false
    
    private let favoriteCollectionsManager = FavoriteCollectionsManager.shared
    
    func loadFavoriteCollections() {
        isLoading = true
        favoriteCollections = favoriteCollectionsManager.getFavoriteCollections()
        isLoading = false
    }
    
    func deleteCollections(_ collectionsToDelete: [String]) {
        for collectionId in collectionsToDelete {
            favoriteCollectionsManager.removeFavorite(collectionId: collectionId)
        }
        loadFavoriteCollections()
    }
}

// MARK: - Main View

struct FavoriteCollectionsView: View {
    @StateObject private var viewModel = FavoriteCollectionsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(Array(viewModel.favoriteCollections), id: \.key) { collectionId, collectionName in
                FavoriteCollectionRow(collectionName: collectionName)
            }
            .onDelete(perform: deleteCollection)
            .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                customBackButton
            }
            ToolbarItem(placement: .principal) {
                titleLabel
            }
        }
        .onAppear {
            viewModel.loadFavoriteCollections()
        }
        .overlay(Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.favoriteCollections.isEmpty {
                Text("No favorite collections yet")
                    .foregroundColor(.secondary)
            }
        })
    }
    
    private func deleteCollection(at offsets: IndexSet) {
        let collectionsToDelete = offsets.map { Array(viewModel.favoriteCollections.keys)[$0] }
        viewModel.deleteCollections(collectionsToDelete)
    }
    
    private var customBackButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
                .imageScale(.large)
        }
    }
    
    private var titleLabel: some View {
        Text("Favorite Collections")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct FavoriteCollectionRow: View {
    let collectionName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(collectionName)
                .font(.headline)
                .lineLimit(2)
            Divider()
                .background(.primary)
                .opacity(0.3)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}
