//
//  PostsView.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/18/24.
//

import SwiftUI

struct PostsView: View {
    @State private var posts = samplePosts
    @State private var currentIndex = 0

    var body: some View {
        GeometryReader { geometry in
            VerticalPagingView(
                currentIndex: $currentIndex,
                items: posts,
                itemContent: { post in
                    PostCardContainer(post: post)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            )
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
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
    @State private var savedState: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                PostCard(post: post)
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.7)
                
                HStack {
                    ReactionBar(reactions: post.reactions)
                    
                    Spacer()
                    
                    SaveButton(isSaved: $savedState)
                }
                .padding(.horizontal)
                .frame(width: geometry.size.width * 0.9)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct PostCard: View {
    let post: Post
    @State private var currentPage = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
//            Text(post.category.uppercased())
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .leading)
            
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

struct ReactionBar: View {
    @State var reactions: [Reaction: Int]
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(Reaction.allCases, id: \.self) { reaction in
                ReactionButton(reaction: reaction, count: reactions[reaction] ?? 0) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        reactions[reaction, default: 0] += 1
                    }
                }
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
            withAnimation {
                isSaved.toggle()
            }
        }) {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 24))
                .foregroundColor(isSaved ? .blue : .gray)
        }
    }
}

enum Reaction: String, CaseIterable {
    case like, mindBlowing, alreadyKnew, hardToBelieve, interesting
    
    var emoji: String {
        switch self {
        case .like: return "👍"
        case .mindBlowing: return "🤯"
        case .alreadyKnew: return "🤓"
        case .hardToBelieve: return "🤨"
        case .interesting: return "🤔"
        }
    }
}

struct Post: Identifiable {
    let id = UUID()
    let content: [String]
    let category: String
    var reactions: [Reaction: Int]
}

// Sample data
let samplePosts = [
    Post(
        content: [
            "A day on Venus is longer than its year. Venus rotates so slowly that it takes 243 Earth days to complete one rotation. A day on Venus is longer than its year. Venus rotates so slowly that it takes 243 Earth days to complete one rotation. A day on Venus is longer than its year. Venus rotates so slowly that it takes 243 Earth days to complete one rotation.",
            "But it only takes 225 Earth days to complete one orbit of the Sun.",
            "This means that on Venus, a day is longer than a year!"
        ],
        category: "Space Oddities",
        reactions: [.like: 120, .mindBlowing: 45, .alreadyKnew: 89, .hardToBelieve: 12, .interesting: 3]
    ),
    Post(
        content: [
            "The world's largest desert is Antarctica, not the Sahara.",
            "Antarctica is considered a desert because it receives very little precipitation.",
            "Despite being covered in ice, Antarctica's air is extremely dry, qualifying it as the world's largest desert."
        ],
        category: "Nature's Jaw-Droppers",
        reactions: [.like: 95, .mindBlowing: 30, .alreadyKnew: 72, .hardToBelieve: 5, .interesting: 2]
    ),
    Post(
        content: [
            "The first computer 'bug' was an actual insect.",
            "In 1947, operators of the Mark II computer at Harvard University found a moth trapped in a relay and taped it in their logbook.",
            "This incident popularized the term 'bug' in computer science, though the term existed before in other contexts."
        ],
        category: "Tech Time Bombs",
        reactions: [.like: 110, .mindBlowing: 25, .alreadyKnew: 45, .hardToBelieve: 80, .interesting: 0]
    )
]

//struct PostsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostsView()
//    }
//}

#Preview {
    PostsView()
}
