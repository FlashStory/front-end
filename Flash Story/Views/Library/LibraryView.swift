import SwiftUI

// MARK: - View Models

class LibraryViewModel: ObservableObject {
    @AppStorage("lastViewedCollectionPositions") private var lastViewedPositionsData: Data = Data()
    
    @Published var collections: [CollectionView] = []
    @Published var lastViewedPositions: [String: Int] = [:]
    @Published var isLoading: Bool = false
    @Published var selectedTab: TabType = .inProgress
    
    private let collectionService = CollectionService()
    
    enum TabType: String, CaseIterable {
        case inProgress = "In Progress"
        case finished = "Finished"
    }
    
    init() {
        loadLastViewedPositions()
    }
    
    private func loadLastViewedPositions() {
        if let decodedPositions = try? JSONDecoder().decode([String: Int].self, from: lastViewedPositionsData) {
            lastViewedPositions = decodedPositions
        }
    }
    
    func fetchCollections() {
        isLoading = true
        Task {
            do {
                let fetchedCollections = try await collectionService.getAllCollections()
                DispatchQueue.main.async {
                    self.collections = fetchedCollections.filter { self.lastViewedPositions[$0.id] != nil }
                    self.isLoading = false
                }
            } catch {
                print("Error fetching collections: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateProgress() {
        loadLastViewedPositions()
        fetchCollections()
    }
    
    func progressForCollection(_ collection: CollectionView) -> (current: Int, total: Int) {
        let lastPosition = lastViewedPositions[collection.id] ?? 0
        let currentPost = min(lastPosition + 1, collection.posts.count)
        return (currentPost, collection.posts.count)
    }
    
    // Only show collections where the user has read all posts
    var finishedCollections: [CollectionView] {
        collections.filter { collection in
            let progress = progressForCollection(collection)
            return progress.current == progress.total
        }
    }
    
    // Show collections that the user is still reading
    var inProgressCollections: [CollectionView] {
        collections.filter { collection in
            let progress = progressForCollection(collection)
            return progress.current < progress.total
        }
    }
    
    // Restart a finished collection
    func restartCollection(_ collection: CollectionView) {
        lastViewedPositions[collection.id] = 0
        saveLastViewedPositions()
        updateProgress()
    }
    
    // Delete a collection from AppStorage and the view
    func deleteCollection(_ collection: CollectionView) {
        collections.removeAll { $0.id == collection.id }
        lastViewedPositions.removeValue(forKey: collection.id)
        saveLastViewedPositions()
    }
    
    private func saveLastViewedPositions() {
        if let encoded = try? JSONEncoder().encode(lastViewedPositions) {
            lastViewedPositionsData = encoded
        }
    }
}

// MARK: - Main View

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @Binding var navigationPath: NavigationPath
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Collections", selection: $viewModel.selectedTab) {
                    ForEach(LibraryViewModel.TabType.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.collections.isEmpty {
                        emptyLibraryView
                    } else {
                        if viewModel.selectedTab == .inProgress {
                            inProgressTab
                        } else {
                            finishedTab
                        }
                    }
                }
            }
            .onAppear {
                viewModel.updateProgress()
            }
        }
    }
    
    private var inProgressTab: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.inProgressCollections) { collection in
                    NavigationLink(destination: PostsView(collectionId: collection.id)) {
                        CollectionCard(
                            collection: collection,
                            progress: viewModel.progressForCollection(collection),
                            onDelete: { viewModel.deleteCollection(collection) }
                        )
                    }
                }
            }
            .padding()
        }
    }


    private var finishedTab: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.finishedCollections) { collection in
                    CollectionCard(
                        collection: collection,
                        progress: nil,
                        onRestart: { viewModel.restartCollection(collection) },
                        onDelete: { viewModel.deleteCollection(collection) }
                    )
                }
            }
            .padding()
        }
    }

    
    private var emptyLibraryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Your library is empty")
                .font(.title2)
            Text("Collections you start reading will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct CollectionCard: View {
    let collection: CollectionView
    let progress: (current: Int, total: Int)?
    var onRestart: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(collection.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            
            if let progress = progress {
                ProgressView(value: Double(progress.current), total: Double(progress.total))
                    .accentColor(.blue)
                Text("\(progress.current)/\(progress.total) posts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            
            if let onRestart = onRestart {
                Button(action: onRestart) {
                    Text("Restart")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


// MARK: - Preview

#Preview {
    LibraryView(navigationPath: .constant(NavigationPath()))
}
