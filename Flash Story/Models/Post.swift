//
//  Post.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

struct Post: Identifiable {
    let id = UUID()
    let content: [String]
    let collection: String
    var reactions: [Reaction: Int]
}
