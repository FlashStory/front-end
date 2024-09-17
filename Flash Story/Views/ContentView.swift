//
//  ContentView.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/17/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            Text("Posts")
                .tabItem {
                    Label("Posts", systemImage: "list.bullet")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
