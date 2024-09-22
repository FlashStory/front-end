import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var navigationPath = NavigationPath()
    @State private var tabBarHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        HomeView(navigationPath: $navigationPath)
                            .padding(.bottom, tabBarHeight)
                            .tag(0)
                        
                        PostsView(collectionId: "66ef2bc3a375cf13126ffa57")
                            .padding(.bottom, tabBarHeight)
                            .tag(1)
                        
                        LibraryView(navigationPath: $navigationPath)
                            .padding(.bottom, tabBarHeight)
                            .tag(2)
                        
                        ProfileView()
                            .padding(.bottom, tabBarHeight)
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    CustomTabBar(selectedTab: $selectedTab) { height in
                        tabBarHeight = height
                    }
                    .opacity(navigationPath.isEmpty ? 1 : 0)
                    .animation(.easeInOut, value: navigationPath.isEmpty)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationDestination(for: String.self) { collectionId in
                PostsView(collectionId: collectionId)
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var onTabBarHeightChange: (CGFloat) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Spacer()
                tabButton(title: "Home", icon: "house", selectedIcon: "house.fill", tag: 0)
                Spacer()
                tabButton(title: "Explore", icon: "safari", selectedIcon: "safari.fill", tag: 1)
                Spacer()
                tabButton(title: "Library", icon: "book", selectedIcon: "book.fill", tag: 2)
                Spacer()
                tabButton(title: "Profile", icon: "person", selectedIcon: "person.fill", tag: 3)
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, verticalSizeClass == .compact ? 0 : 10)
            .background(Color(.systemBackground))
        }
        .background(GeometryReader { geometry in
            Color.clear
                .onAppear {
                    onTabBarHeightChange(geometry.size.height)
                }
        })
    }
    
    func tabButton(title: String, icon: String, selectedIcon: String, tag: Int) -> some View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tag ? selectedIcon : icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text(title)
                    .font(.system(size: 10))
            }
        }
        .foregroundColor(selectedTab == tag ? .primary : .gray)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            
            ContentView()
                .previewDevice("iPhone SE (3rd generation)")
            
            ContentView()
                .previewDevice("iPad Air (5th generation)")
        }
    }
}
