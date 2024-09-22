import SwiftUI

// MARK: - View Model
class SavedPostsViewModel: ObservableObject {
    @Published var savedPosts: [Post] = []
    @Published var isLoading = false
    
    private let savedPostsManager = SavedPostsManager.shared
    private let postService = PostService()
    
    func loadSavedPosts() {
        isLoading = true
        let savedPostIds = savedPostsManager.getSavedPostIds()
        
        Task {
            do {
                let posts = try await withThrowingTaskGroup(of: Post.self) { group in
                    for id in savedPostIds {
                        group.addTask {
                            try await self.postService.getPostById(postId: id)
                        }
                    }
                    
                    var loadedPosts: [Post] = []
                    for try await post in group {
                        loadedPosts.append(post)
                    }
                    return loadedPosts
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.savedPosts = posts
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                    print("Failed to load saved posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deletePosts(at offsets: IndexSet) {
        for index in offsets {
            let postId = savedPosts[index].id
            savedPostsManager.unsavePost(postId: postId)
        }
        savedPosts.remove(atOffsets: offsets)
    }
}

// MARK: - Main View

struct SavedPostsView: View {
    @StateObject private var viewModel = SavedPostsViewModel()
    @State private var selectedPost: Post?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(viewModel.savedPosts) { post in
                SavedPostRow(post: post)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPost = post
                    }
            }
            .onDelete(perform: deletePost)
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
            viewModel.loadSavedPosts()
        }
        .overlay(Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.savedPosts.isEmpty {
                Text("No saved posts yet")
                    .foregroundColor(.secondary)
            }
        })
        .sheet(item: $selectedPost) { post in
            SavedPostDetailView(post: post)
        }
    }
    
    private func deletePost(at offsets: IndexSet) {
        viewModel.deletePosts(at: offsets)
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
        Text("Saved Posts")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct SavedPostRow: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(post.content.first ?? "")
                    .font(.headline)
                    .lineLimit(2)
                Text(post.collectionName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            Divider()
                .background(.primary)
                .opacity(0.3)
                .padding(.top, 4)
        }
    }
}


struct SavedPostDetailView: View {
    let post: Post
    @State private var currentPage = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 16) {
                Text(post.collectionName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, geometry.size.width * 0.05)
                
                VStack(spacing: 0) {
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
                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.7)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}




#Preview{
    SavedPostsView()
}
