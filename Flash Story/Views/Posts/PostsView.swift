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
    
    func reactToPost(postId: String, reaction: String) {
        Task {
            do {
                let currentReaction = UserReactionTracker.shared.getReaction(postId: postId)
                
                if currentReaction == reaction {
                    // User is un-reacting
                    let updatedReactions = try await postService.reactToPost(postId: postId, reaction: reaction, amount: -1)
                    UserReactionTracker.shared.removeReaction(postId: postId)
                    updatePostReactions(postId: postId, reactions: updatedReactions)
                } else {
                    // User is changing reaction or reacting for the first time
                    if let currentReaction = currentReaction {
                        // Remove the previous reaction
                        _ = try await postService.reactToPost(postId: postId, reaction: currentReaction, amount: -1)
                    }
                    // Add the new reaction
                    let updatedReactions = try await postService.reactToPost(postId: postId, reaction: reaction, amount: 1)
                    UserReactionTracker.shared.setReaction(postId: postId, reaction: reaction)
                    updatePostReactions(postId: postId, reactions: updatedReactions)
                }
            } catch {
                print("Error reacting to post: \(error)")
            }
        }
    }

    private func updatePostReactions(postId: String, reactions: Reactions) {
        DispatchQueue.main.async {
            if let index = self.posts.firstIndex(where: { $0.id == postId }) {
                self.posts[index].reactions = reactions
            }
            self.objectWillChange.send()
        }
    }
    
    func getUserReaction(postId: String) -> String? {
        return UserReactionTracker.shared.getReaction(postId: postId)
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
    
    func getFavoriteCollections() -> [String: String] {
        return favoriteCollections
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
    
    func getSavedPostIds() -> [String] {
        Array(savedPosts)
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


class UserReactionTracker: ObservableObject {
    static let shared = UserReactionTracker()
    
    @AppStorage("userReactions") private var userReactionsData: Data = Data()
    
    private var userReactions: [String: String] {
        get {
            (try? JSONDecoder().decode([String: String].self, from: userReactionsData)) ?? [:]
        }
        set {
            userReactionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func setReaction(postId: String, reaction: String) {
        userReactions[postId] = reaction
    }
    
    func getReaction(postId: String) -> String? {
        return userReactions[postId]
    }
    
    func removeReaction(postId: String) {
        userReactions.removeValue(forKey: postId)
    }
}

// MARK: - Main View
struct PostsView: View {
    @StateObject private var viewModel: PostsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var dragOffset: CGFloat = 0
    @State private var isDraggingFromEdge: Bool = false

    // Define a threshold for the drag gesture to be considered as coming from the edge
    private let edgeThreshold: CGFloat = 20

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
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDraggingFromEdge {
                            isDraggingFromEdge = value.startLocation.x <= edgeThreshold
                        }
                        
                        if isDraggingFromEdge {
                            dragOffset = max(0, value.translation.width)
                        }
                    }
                    .onEnded { value in
                        if isDraggingFromEdge {
                            if value.translation.width > geometry.size.width / 3 {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    dragOffset = geometry.size.width
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    dragOffset = 0
                                }
                            }
                        }
                        isDraggingFromEdge = false
                    }
            )
        }
        .onAppear {
            viewModel.fetchPosts()
        }
        .navigationBarBackButtonHidden()
    }
    
    private var backButton: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.2)) {
                dragOffset = UIScreen.main.bounds.width
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.presentationMode.wrappedValue.dismiss()
            }
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
    
    @State private var hasScrolled = false
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        itemContent(item)
                            .containerRelativeFrame(.vertical)
                            .id(index)
                    }
                }
            }
            .scrollBounceBehavior(.automatic)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: Binding(
                get: { currentIndex as Int? },
                set: { if let newValue = $0 { currentIndex = newValue } }
            ))
            .ignoresSafeArea()
            .onAppear {
                scrollProxy = proxy
            }
        }
        .task {
            // Wait a short moment to ensure the view is fully loaded
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            scrollToInitialPosition()
        }
    }
    
    private func scrollToInitialPosition() {
        guard !hasScrolled, let proxy = scrollProxy else { return }
        
        withAnimation {
            proxy.scrollTo(currentIndex, anchor: .top)
        }
        
        hasScrolled = true
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
                    ReactionBar(viewModel: viewModel, post: post)
                    
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
    @ObservedObject var viewModel: PostsViewModel
    let post: Post
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(Reaction.allCases, id: \.self) { reaction in
                ReactionButton(
                    reaction: reaction,
                    count: reactionCount(for: reaction),
                    isSelected: viewModel.getUserReaction(postId: post.id) == reaction.rawValue
                ) {
                    viewModel.reactToPost(postId: post.id, reaction: reaction.rawValue)
                }
            }
        }
    }
    
    private func reactionCount(for reaction: Reaction) -> Int {
        switch reaction {
        case .like: return post.reactions.like
        case .mindBlowing: return post.reactions.mindBlowing
        case .alreadyKnew: return post.reactions.alreadyKnew
        case .hardToBelieve: return post.reactions.hardToBelieve
        case .interesting: return post.reactions.interesting
        }
    }
}

struct ReactionButton: View {
    let reaction: Reaction
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPressed = false
            }
            action()
        }) {
            VStack {
                if isSelected {
                    Text(reaction.name)
                        .font(.caption2)
                        .foregroundColor(isSelected ? .orange : .primary)
                        .lineLimit(1)
                        .fixedSize()
                }
                Text(reaction.emoji)
                    .font(.title3)
                    .overlay(
                        Rectangle()
                            .foregroundColor(.gray)
                            .opacity(isSelected ? 0 : 0.5)
                            .blendMode(.destinationOut)
                    )
                    .compositingGroup()
                Text("\(count)")
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
        }
        .scaleEffect(isPressed ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
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
