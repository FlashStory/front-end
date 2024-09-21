import SwiftUI

// MARK: - View Models

class HomeViewModel: ObservableObject {
    @Published var collections: [CollectionView] = []
    @Published var searchText = ""
    @Published var showAllTopics = false
    
    let bigTopics: [String: [String]] = [
        "Nature": ["Ocean Life", "Space Exploration", "Rainforests", "Desert Ecosystems", "Mountain Ranges"],
        "Country Facts": ["United States", "Japan", "Brazil", "Egypt", "Australia", "India", "France"],
        "Historical Events": ["Ancient Civilizations", "World Wars", "Industrial Revolution", "Space Race", "Civil Rights Movements"]
    ]
    
    let otherTopics = [
        "Sci-Fi Stories", "Mystery Stories", "Motivational Quotes", "Fun Facts", "Technology Breakthroughs",
        "Art History", "Scientific Discoveries", "Culinary Wonders", "Ancient Myths", "Bizarre Animals"
    ]
    
    let favoriteTopics = ["Ocean Life", "Sci-Fi Stories", "Ancient Civilizations", "Technology Breakthroughs"]
    
    private let collectionService = CollectionService()
    
    func fetchCollections() {
        Task {
            do {
                let fetchedCollections = try await collectionService.getAllCollections()
                DispatchQueue.main.async {
                    self.collections = fetchedCollections
                }
            } catch {
                print("Error fetching collections: \(error)")
            }
        }
    }
}

// MARK: - Main View

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SearchBar(text: $viewModel.searchText)
                    HotTopicsView(collections: viewModel.collections.prefix(5), navigationPath: $navigationPath)
                    FactOfTheDayView()
                    FavoritesView(collections: viewModel.collections.filter { viewModel.favoriteTopics.contains($0.name) }, navigationPath: $navigationPath)
                    
                    ForEach(viewModel.bigTopics.keys.sorted(), id: \.self) { topic in
                        BigTopicView(title: topic, collections: viewModel.collections.filter { viewModel.bigTopics[topic]?.contains($0.name) ?? false }, navigationPath: $navigationPath)
                    }
                    
                    MoreTopicsView(collections: viewModel.collections.filter { viewModel.otherTopics.contains($0.name) }, showAllAction: { viewModel.showAllTopics = true }, navigationPath: $navigationPath)
                }
                .padding()
            }
//            .navigationTitle("Flash Story")
            .sheet(isPresented: $viewModel.showAllTopics) {
                AllTopicsView(collections: viewModel.collections, navigationPath: $navigationPath)
            }
            .onAppear {
                viewModel.fetchCollections()
            }
        }
}

// MARK: - Subviews

struct HotTopicsView: View {
    let collections: ArraySlice<CollectionView>
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hot Topics")
                .font(.title2)
                .fontWeight(.semibold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Array(collections), id: \.id) { collection in
                        NavigationLink(destination: PostsView(collectionId: collection.id)) {
                            TopicCard(title: collection.name, avatarURL: collection.avatar)
                        }
                    }
                }
            }
        }
    }
}

struct FavoritesView: View {
    let collections: [CollectionView]
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Favorites")
                .font(.title2)
                .fontWeight(.semibold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(collections, id: \.id) { collection in
                        NavigationLink(destination: PostsView(collectionId: collection.id)) {
                            TopicCard(title: collection.name, avatarURL: collection.avatar)
                        }
                    }
                }
            }
        }
    }
}

struct BigTopicView: View {
    let title: String
    let collections: [CollectionView]
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(collections, id: \.id) { collection in
                        NavigationLink(destination: PostsView(collectionId: collection.id)) {
                            TopicCard(title: collection.name, avatarURL: collection.avatar)
                        }
                    }
                }
            }
        }
    }
}

struct MoreTopicsView: View {
    let collections: [CollectionView]
    let showAllAction: () -> Void
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("More Topics")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: showAllAction) {
                    Text("Show All")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(collections.prefix(4), id: \.id) { collection in
                    NavigationLink(destination: PostsView(collectionId: collection.id)) {
                        TopicCard(title: collection.name, avatarURL: collection.avatar)
                    }
                }
            }
        }
    }
}

struct AllTopicsView: View {
    let collections: [CollectionView]
    @Environment(\.presentationMode) var presentationMode
    @Binding var navigationPath: NavigationPath
    @State private var searchText = ""
    
    var filteredCollections: [CollectionView] {
        if searchText.isEmpty {
            return collections
        } else {
            return collections.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredCollections, id: \.id) { collection in
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigationPath.append(collection.id)
                            }
                        }) {
                            HStack {
                                AsyncImage(url: URL(string: collection.avatar)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text(collection.name)
                                    .font(.body)
                                    .padding(.leading, 8)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
//            .navigationTitle("All Topics")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TopicCard: View {
    let title: String
    let avatarURL: String
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: avatarURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo").foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(width: 120, height: 40)
                .lineLimit(2)
                .foregroundStyle(Color.primary)
        }
        .frame(height: 120)
        .padding(.top, 6)
    }
}

struct FactOfTheDayView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Fact of the Day").font(.headline)
            Text("Did you know that honeybees can recognize human faces?")
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search topics or facts", text: $text)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        HomeView(navigationPath: .constant(NavigationPath()))
    }
}
