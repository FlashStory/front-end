import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)
                    PostsView()
                        .tag(1)
                    LibraryView()
                        .tag(2)
                    ProfileView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: geometry.size.height - 50)
                
                CustomTabBar(selectedTab: $selectedTab)
                    .frame(height: 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
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
        .overlay(Divider(), alignment: .top)
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
