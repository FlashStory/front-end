//
//  LibraryView.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/18/24.
//

import SwiftUI

struct LibraryView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var collections: [Collection] = [
        Collection(name: "Science Facts", posts: Array(repeating: Post(content: ["Sample content"], collection: "Science", reactions: [:]), count: 5)),
        Collection(name: "Historical Eventsss", posts: Array(repeating: Post(content: ["Sample content"], collection: "History", reactions: [:]), count: 8)),
        Collection(name: "Tech Innovations", posts: Array(repeating: Post(content: ["Sample content"], collection: "Technology", reactions: [:]), count: 3)),
        Collection(name: "Nature Wonders", posts: Array(repeating: Post(content: ["Sample content"], collection: "Nature", reactions: [:]), count: 6))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(collections) { collection in
                    NavigationLink(destination: CollectionDetailView(collection: collection)) {
                        CollectionCard(collection: collection)
                    }
                }
            }
            .padding()
        }
    }
}

struct CollectionCard: View {
    let collection: Collection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(collection.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundStyle(Color.primary)
            
            ProgressView(value: Double(collection.posts.count), total: 10)
                .accentColor(.blue)
            
            Text("\(collection.posts.count)/10 posts")
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
                Text(post.collection)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
        }
        .navigationTitle(collection.name)
    }
}


#Preview {
    LibraryView()
}
