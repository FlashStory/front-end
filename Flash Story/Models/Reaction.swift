//
//  Reaction.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

struct Reactions: Codable {
    var like: Int
    var mindBlowing: Int
    var alreadyKnew: Int
    var hardToBelieve: Int
    var interesting: Int
    
    enum CodingKeys: String, CodingKey {
        case like, mindBlowing, alreadyKnew, hardToBelieve, interesting
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
    
    var name: String {
        switch self {
        case .like: return "Like"
        case .mindBlowing: return "Mind Blowing"
        case .alreadyKnew: return "Already Knew"
        case .hardToBelieve: return "Hard to Believe"
        case .interesting: return "Interesting"
        }
    }
}
