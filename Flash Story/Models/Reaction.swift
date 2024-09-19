//
//  Reaction.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

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
}
