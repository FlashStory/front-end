import SwiftUI

struct ProfileView: View {

    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                ProfileHeader()

                NavigationLinksSection()
            }
            .padding()
        }
        .ignoresSafeArea(edges: .top)
    }

}

struct ProfileHeader: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
                .background(Circle().fill(Color.white).shadow(radius: 5))

            Text("Flash Story User")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

        }
        .padding()
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 10)
    }
}

struct NavigationLinksSection: View {
    var body: some View {
        VStack(spacing: 25) {
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
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
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
        fetchProfileData()
    }

    private func fetchProfileData() {
        savedPosts = [Post]() // Simulate posts fetching
        favoriteCollections = [Collection]() // Simulate collections fetching
    }
}

#Preview {
    ProfileView()
}
