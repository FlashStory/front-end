//
//  Collection.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

struct Collection: Identifiable {
    let id = UUID()
    let name: String
    let posts: [Post]
}
