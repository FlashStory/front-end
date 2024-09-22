//
//  PostsView.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/18/24.
//

import SwiftUI

// MARK: - View Models
class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var collectionName: String = ""
    @Published var currentIndex = 0
    @Published var isFavorite: Bool = false
    private let postService = PostService()
    private let positionTracker = CollectionPositionTracker()
    let collectionId: String
    
    init(collectionId: String) {
        self.collectionId = collectionId
        self.isFavorite = FavoriteCollectionsManager.shared.isFavorite(collectionId: collectionId)
    }
    
    func fetchPosts() {
        isLoading = true
        Task {
            do {
                let fetchedPosts = try await postService.getPostsByCollection(collectionId: collectionId)
                DispatchQueue.main.async {
                    self.posts = fetchedPosts
                    self.collectionName = fetchedPosts.first?.collectionName ?? ""
                    self.isLoading = false
                    self.scrollToLastViewedPosition()
                    self.updateLastViewedPosition(self.currentIndex)
                }
            } catch {
                print("Error fetching posts: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Handle error (e.g., show an alert)
                }
            }
        }
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        if isFavorite {
            FavoriteCollectionsManager.shared.addFavorite(collectionId: collectionId, name: collectionName)
        } else {
            FavoriteCollectionsManager.shared.removeFavorite(collectionId: collectionId)
        }
    }
    
    func toggleSaved(postId: String) {
        if SavedPostsManager.shared.isSaved(postId: postId) {
            SavedPostsManager.shared.unsavePost(postId: postId)
        } else {
            SavedPostsManager.shared.savePost(postId: postId)
        }
        objectWillChange.send()
    }
    
    func isSaved(postId: String) -> Bool {
        SavedPostsManager.shared.isSaved(postId: postId)
    }
    
    func scrollToLastViewedPosition() {
        currentIndex = positionTracker.getLastViewedPosition(collectionId: collectionId)
    }
    
    func updateLastViewedPosition(_ position: Int) {
        positionTracker.saveLastViewedPosition(collectionId: collectionId, position: position)
    }
}


class FavoriteCollectionsManager: ObservableObject {
    static let shared = FavoriteCollectionsManager()
    
    @AppStorage("favoriteCollections") private var favoriteCollectionsData: Data = Data()
    
    private var favoriteCollections: [String: String] {
        get {
            (try? JSONDecoder().decode([String: String].self, from: favoriteCollectionsData)) ?? [:]
        }
        set {
            favoriteCollectionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func addFavorite(collectionId: String, name: String) {
        favoriteCollections[collectionId] = name
    }
    
    func removeFavorite(collectionId: String) {
        favoriteCollections.removeValue(forKey: collectionId)
    }
    
    func isFavorite(collectionId: String) -> Bool {
        favoriteCollections.keys.contains(collectionId)
    }
}


class SavedPostsManager: ObservableObject {
    static let shared = SavedPostsManager()
    
    @AppStorage("savedPosts") private var savedPostsData: Data = Data()
    
    private var savedPosts: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: savedPostsData)) ?? []
        }
        set {
            savedPostsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func savePost(postId: String) {
        savedPosts.insert(postId)
    }
    
    func unsavePost(postId: String) {
        savedPosts.remove(postId)
    }
    
    func isSaved(postId: String) -> Bool {
        savedPosts.contains(postId)
    }
}


class CollectionPositionTracker: ObservableObject {
    @AppStorage("lastViewedCollectionPositions") private var lastViewedPositionsData: Data = Data()
    
    private var lastViewedPositions: [String: Int] {
        get {
            (try? JSONDecoder().decode([String: Int].self, from: lastViewedPositionsData)) ?? [:]
        }
        set {
            lastViewedPositionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func saveLastViewedPosition(collectionId: String, position: Int) {
        lastViewedPositions[collectionId] = position
    }
    
    func getLastViewedPosition(collectionId: String) -> Int {
        lastViewedPositions[collectionId] ?? 0
    }
}

// MARK: - Main View
struct PostsView: View {
    @StateObject private var viewModel: PostsViewModel
    @Environment(\.presentationMode) var presentationMode

    init(collectionId: String) {
        _viewModel = StateObject(wrappedValue: PostsViewModel(collectionId: collectionId))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    VerticalPagingView(
                        currentIndex: $viewModel.currentIndex,
                        items: viewModel.posts,
                        itemContent: { post in
                            PostCardContainer(post: post, viewModel: viewModel)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    )
                    .onChange(of: viewModel.currentIndex) { oldValue, newValue in
                        viewModel.updateLastViewedPosition(newValue)
                    }
                }
                
                VStack {
                    HStack {
                        backButton
                        Spacer()
                        collectionNameLabel
                        Spacer()
                        favoriteButton
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                }
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            viewModel.fetchPosts()
        }
        .navigationBarBackButtonHidden()
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
                .font(.title3)
        }
    }
    
    private var collectionNameLabel: some View {
        Text(viewModel.collectionName)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            viewModel.toggleFavorite()
        }) {
            Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(viewModel.isFavorite ? .red : .gray)
                .font(.title3)
        }
    }
}


struct VerticalPagingView<Item: Identifiable, Content: View>: View {
    @Binding var currentIndex: Int
    let items: [Item]
    let itemContent: (Item) -> Content

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            itemContent(item)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .id(index)
                        }
                    }
                }
                .content.offset(y: CGFloat(currentIndex) * -geometry.size.height)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .gesture(
                    DragGesture()
                        .onEnded({ value in
                            if value.translation.height < 0 && currentIndex < items.count - 1 {
                                withAnimation {
                                    currentIndex += 1
                                }
                            } else if value.translation.height > 0 && currentIndex > 0 {
                                withAnimation {
                                    currentIndex -= 1
                                }
                            }
                            scrollProxy.scrollTo(currentIndex, anchor: .top)
                        })
                )
            }
        }
    }
}

struct PostCardContainer: View {
    let post: Post
    @ObservedObject var viewModel: PostsViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                PostCard(post: post)
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.7)
                
                HStack {
                    ReactionBar(reactions: post.reactions)
                    
                    Spacer()
                    
                    SaveButton(isSaved: Binding(
                        get: { viewModel.isSaved(postId: post.id) },
                        set: { _ in viewModel.toggleSaved(postId: post.id) }
                    ))
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .frame(width: geometry.size.width * 0.9)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct ReactionBar: View {
    @State var reactions: Reactions
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(Reaction.allCases, id: \.self) { reaction in
                ReactionButton(reaction: reaction, count: reactionCount(for: reaction)) {
                    incrementReaction(reaction)
                }
            }
        }
    }
    
    private func reactionCount(for reaction: Reaction) -> Int {
        switch reaction {
        case .like: return reactions.like
        case .mindBlowing: return reactions.mindBlowing
        case .alreadyKnew: return reactions.alreadyKnew
        case .hardToBelieve: return reactions.hardToBelieve
        case .interesting: return reactions.interesting
        }
    }
    
    private func incrementReaction(_ reaction: Reaction) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            switch reaction {
            case .like: reactions.like += 1
            case .mindBlowing: reactions.mindBlowing += 1
            case .alreadyKnew: reactions.alreadyKnew += 1
            case .hardToBelieve: reactions.hardToBelieve += 1
            case .interesting: reactions.interesting += 1
            }
        }
    }
}


struct PostCard: View {
    let post: Post
    @State private var currentPage = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            TabView(selection: $currentPage) {
                ForEach(post.content.indices, id: \.self) { index in
                    Text(post.content[index])
                        .font(.title3)
                        .padding()
                        .lineSpacing(10)
                        .tracking(0.5)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            PageControl(numberOfPages: post.content.count, currentPage: $currentPage)
                .padding(.bottom)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
}

struct PageControl: View {
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.gray : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct ReactionButton: View {
    let reaction: Reaction
    let count: Int
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack {
                Text(reaction.emoji)
                    .font(.title3)
                Text("\(count)")
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
        }
        .scaleEffect(isPressed ? 1.5 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
    }
}

struct SaveButton: View {
    @Binding var isSaved: Bool
    
    var body: some View {
        Button(action: {
            isSaved.toggle()
        }) {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 24))
                .foregroundColor(isSaved ? .blue : .gray)
        }
    }
}

#Preview {
    PostsView(collectionId: "66ef2bc3a375cf13126ffa57")
}
