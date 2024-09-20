//
//  ProfileView.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/18/24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ProfileHeader()
               
                NavigationLinksSection()
            }
            .padding()
        }
//        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .background(backgroundColor)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color(.systemGroupedBackground)
    }
}

struct ProfileHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Flash Story User")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .cornerRadius(15)
    }
}

struct NavigationLinksSection: View {
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: SavedPostsView()) {
                NavigationRow(title: "Saved Posts", iconName: "bookmark.fill")
            }
            
            NavigationLink(destination: FavoriteCollectionsView()) {
                NavigationRow(title: "Favorite Collections", iconName: "star.fill")
            }
        }
    }
}

struct NavigationRow: View {
    let title: String
    let iconName: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                radius: 5, x: 0, y: 2)
    }
}

// Placeholder views for navigation
struct SavedPostsView: View {
    var body: some View {
        Text("Saved Posts")
            .navigationTitle("Saved Posts")
    }
}

struct FavoriteCollectionsView: View {
    var body: some View {
        Text("Favorite Collections")
            .navigationTitle("Favorite Collections")
    }
}

class ProfileViewModel: ObservableObject {
    @Published var savedPosts: [Post] = []
    @Published var favoriteCollections: [Collection] = []
    
    init() {
        // Fetch data or initialize with dummy data
        fetchProfileData()
    }
    
    private func fetchProfileData() {
        // Simulating data fetch
        savedPosts = [Post]() // Your Post objects
        favoriteCollections = [Collection]() // Your Collection objects
    }
}

#Preview {
    ProfileView()
}
