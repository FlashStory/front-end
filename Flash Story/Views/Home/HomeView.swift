import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var showAllTopics = false
    
    let bigTopics = [
        "Nature": ["Ocean Life", "Space Exploration", "Rainforests", "Desert Ecosystems", "Mountain Ranges"],
        "Country Facts": ["United States", "Japan", "Brazil", "Egypt", "Australia", "India", "France"],
        "Historical Events": ["Ancient Civilizations", "World Wars", "Industrial Revolution", "Space Race", "Civil Rights Movements"]
    ]
    
    let otherTopics = [
        "Sci-Fi Stories", "Mystery Stories", "Motivational Quotes", "Fun Facts", "Technology Breakthroughs",
        "Art History", "Scientific Discoveries", "Culinary Wonders", "Ancient Myths", "Bizarre Animals"
    ]
    
    let favoriteTopics = ["Ocean Life", "Sci-Fi Stories", "Ancient Civilizations", "Technology Breakthroughs"]
    
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    SearchBar(text: $searchText)
                    
                    HotTopicsView()
                    
                    FactOfTheDayView()
                    
                    FavoritesView(topics: favoriteTopics)
                    
                    ForEach(bigTopics.keys.sorted(), id: \.self) { topic in
                        BigTopicView(title: topic, subtopics: bigTopics[topic] ?? [])
                    }
                    
                    MoreTopicsView(topics: otherTopics, showAllAction: { showAllTopics = true })
                }
                .padding()
            }
            .navigationTitle("Flash Story")
            .sheet(isPresented: $showAllTopics) {
                AllTopicsView(topics: otherTopics + bigTopics.keys.sorted())
            }
        }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search topics or facts", text: $text)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct HotTopicsView: View {
    let hotTopics = ["Viral Space Photo", "Unexpected Animal Friendship", "Historical Mystery Solved", "Breakthrough in Renewable Energy", "Ancient Artifact Discovery"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hot Topics")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(hotTopics, id: \.self) { topic in
                        TopicCard(title: topic, color: .orange, icon: "flame.fill")
                    }
                }
            }
        }
    }
}

struct FactOfTheDayView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Fact of the Day")
                .font(.headline)
            
            Text("Did you know that honeybees can recognize human faces?")
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

struct FavoritesView: View {
    let topics: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Favorites")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(topics, id: \.self) { topic in
                        TopicCard(title: topic, color: .red, icon: "heart.fill")
                    }
                }
            }
        }
    }
}

struct BigTopicView: View {
    let title: String
    let subtopics: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(subtopics, id: \.self) { subtopic in
                        TopicCard(title: subtopic, color: .blue, icon: "book.fill")
                    }
                }
            }
        }
    }
}

struct MoreTopicsView: View {
    let topics: [String]
    let showAllAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("More Topics")
                    .font(.headline)
                Spacer()
                Button("Show All", action: showAllAction)
                    .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(topics.prefix(4), id: \.self) { topic in
                    TopicCard(title: topic, color: .purple, icon: "square.grid.2x2.fill")
                }
            }
        }
    }
}

struct TopicCard: View {
    let title: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
                .frame(width: 120, height: 80)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(color)
                )
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(width: 120, height: 40)
                .lineLimit(2)
        }
        .frame(height: 120)
    }
}

struct AllTopicsView: View {
    let topics: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(topics, id: \.self) { topic in
                Text(topic)
            }
            .navigationTitle("All Topics")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
