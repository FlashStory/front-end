//
//  LibraryView.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/18/24.
//

import SwiftUI

// MARK: - View Models

class LibraryViewModel: ObservableObject {
    @AppStorage("lastViewedCollectionPositions") private var lastViewedPositionsData: Data = Data()
    
    @Published var collections: [CollectionView] = []
    @Published var lastViewedPositions: [String: Int] = [:]
    @Published var isLoading: Bool = false
    
    private let collectionService = CollectionService()
    
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
                    self.collections = fetchedCollections
                    self.filterReadCollections()
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
    
    private func filterReadCollections() {
        collections = collections.filter { collection in
            lastViewedPositions[collection.id] != nil
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
}

// MARK: - Main View

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @Binding var navigationPath: NavigationPath
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.collections.isEmpty {
                    emptyLibraryView
                } else {
                    libraryContentView
                }
            }
            .onAppear {
                viewModel.updateProgress()
            }
        }
    }
    
    private var libraryContentView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.collections) { collection in
                    NavigationLink(destination: PostsView(collectionId: collection.id)) {
                        CollectionCard(collection: collection, progress: viewModel.progressForCollection(collection))
                    }
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
    let progress: (current: Int, total: Int)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(collection.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundStyle(Color.primary)
            
            ProgressView(value: Double(progress.current), total: Double(progress.total))
                .accentColor(.blue)
            
            Text("\(progress.current)/\(progress.total) posts")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CollectionDetailView: View {
    let collection: Collection
    
    var body: some View {
        List(collection.posts, id: \.id) { post in
            VStack(alignment: .leading, spacing: 5) {
                Text(post.content[0])
                    .font(.body)
                Text(post.collectionName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
        }
        .navigationTitle(collection.name)
    }
}


#Preview {
    LibraryView(navigationPath: .constant(NavigationPath()))
}
