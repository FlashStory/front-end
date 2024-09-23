import SwiftUI

class ExploreViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var currentIndex = 0
    private let postService = PostService()
    
    func fetchRandomPosts() {
       guard !isLoading else { return }
       isLoading = true
       Task {
           do {
               let fetchedPosts = try await postService.getRandomPosts(count: 10)
               DispatchQueue.main.async {
                   self.posts.append(contentsOf: fetchedPosts)
                   self.isLoading = false
               }
           } catch {
               print("Error fetching random posts: \(error)")
               DispatchQueue.main.async {
                   self.isLoading = false
                   // Handle error (e.g., show an alert)
               }
           }
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
    
    func reactToPost(postId: String, reaction: String) {
        Task {
            do {
                let currentReaction = UserReactionTracker.shared.getReaction(postId: postId)
                
                if currentReaction == reaction {
                    let updatedReactions = try await postService.reactToPost(postId: postId, reaction: reaction, amount: -1)
                    UserReactionTracker.shared.removeReaction(postId: postId)
                    updatePostReactions(postId: postId, reactions: updatedReactions)
                } else {
                    if let currentReaction = currentReaction {
                        _ = try await postService.reactToPost(postId: postId, reaction: currentReaction, amount: -1)
                    }
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
    
    func toggleFavorite(for post: Post) {
        if FavoriteCollectionsManager.shared.isFavorite(collectionId: post.collectionId) {
            FavoriteCollectionsManager.shared.removeFavorite(collectionId: post.collectionId)
        } else {
            FavoriteCollectionsManager.shared.addFavorite(collectionId: post.collectionId, name: post.collectionName)
        }
        objectWillChange.send()
    }
    
    func isFavorite(for post: Post) -> Bool {
        FavoriteCollectionsManager.shared.isFavorite(collectionId: post.collectionId)
    }
}

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if viewModel.posts.isEmpty && viewModel.isLoading {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    VerticalPagingView(
                        currentIndex: $viewModel.currentIndex,
                        items: viewModel.posts,
                        itemContent: { post in
                            ExplorePostCardContainer(post: post, viewModel: viewModel)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    )
//                    iOS 17 +
//                    .onChange(of: viewModel.currentIndex) { oldValue, newValue in
//                        if newValue >= Int(Double(viewModel.posts.count) * 0.7) {
//                            viewModel.fetchRandomPosts()
//                        }
//                    }
                    .onChange(of: viewModel.currentIndex) { newValue in
                        if newValue >= Int(Double(viewModel.posts.count) * 0.7) {
                            viewModel.fetchRandomPosts()
                        }
                    }
                }
                
                VStack {
                    HStack {
                        Spacer()
                        if !viewModel.posts.isEmpty {
                            collectionNameLabel
                        }
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
            if viewModel.posts.isEmpty {
                viewModel.fetchRandomPosts()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var collectionNameLabel: some View {
        Text(viewModel.posts[viewModel.currentIndex].collectionName)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            if viewModel.currentIndex < viewModel.posts.count {
                let currentPost = viewModel.posts[viewModel.currentIndex]
                viewModel.toggleFavorite(for: currentPost)
            }
        }) {
            Image(systemName: viewModel.posts.isEmpty ? "heart" : (viewModel.isFavorite(for: viewModel.posts[viewModel.currentIndex]) ? "heart.fill" : "heart"))
                .foregroundColor(viewModel.posts.isEmpty ? .gray : (viewModel.isFavorite(for: viewModel.posts[viewModel.currentIndex]) ? .red : .gray))
                .font(.title3)
        }
    }
}

struct ExplorePostCardContainer: View {
    let post: Post
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                PostCard(post: post)
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.7)
                
                HStack {
                    ExploreReactionBar(viewModel: viewModel, post: post)
                    
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

struct ExploreReactionBar: View {
    @ObservedObject var viewModel: ExploreViewModel
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
