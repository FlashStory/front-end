//
//  dummyData.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

let dummyCollections: [Collection] = [
    Collection(
        id: "asdds321312a",
        name: "Science Facts",
        avatar: "https://www.pexels.com/photo/grayscale-photo-of-people-between-buildings-1217258/",
        posts: Array(repeating: Post(
            id: UUID().uuidString,
            content: ["Sample science content"],
            collectionId: "asdds321312a",
            collectionName: "Science Facts",
            reactions: Reactions(like: 10, mindBlowing: 5, alreadyKnew: 2, hardToBelieve: 1, interesting: 3)
        ), count: 5)
    ),
    Collection(
        id: "a213sddsa",
        name: "Historical Events",
        avatar: "https://www.pexels.com/photo/grayscale-photo-of-people-between-buildings-1217258/",
        posts: Array(repeating: Post(
            id: UUID().uuidString,
            content: ["Sample history content"],
            collectionId: "a213sddsa",
            collectionName: "Historical Events",
            reactions: Reactions(like: 8, mindBlowing: 3, alreadyKnew: 4, hardToBelieve: 0, interesting: 2)
        ), count: 8)
    ),
    Collection(
        id: "asd132dsa",
        name: "Tech Innovations",
        avatar: "https://www.pexels.com/photo/grayscale-photo-of-people-between-buildings-1217258/",
        posts: Array(repeating: Post(
            id: UUID().uuidString,
            content: ["Sample tech content"],
            collectionId: "asd132dsa",
            collectionName: "Tech Innovations",
            reactions: Reactions(like: 15, mindBlowing: 7, alreadyKnew: 1, hardToBelieve: 2, interesting: 5)
        ), count: 3)
    ),
    Collection(
        id: "as2ddsa",
        name: "Nature Wonders",
        avatar: "https://www.pexels.com/photo/grayscale-photo-of-people-between-buildings-1217258/",
        posts: Array(repeating: Post(
            id: UUID().uuidString,
            content: ["Sample nature content"],
            collectionId: "as2ddsa",
            collectionName: "Nature Wonders",
            reactions: Reactions(like: 12, mindBlowing: 6, alreadyKnew: 3, hardToBelieve: 1, interesting: 4)
        ), count: 6)
    ),
    Collection(
        id: "asdd32sa",
        name: "Space Oddities",
        avatar: "https://www.pexels.com/photo/grayscale-photo-of-people-between-buildings-1217258/",
        posts: Array(repeating: Post(
            id: UUID().uuidString,
            content: ["Sample space content"],
            collectionId: "asdd32sa",
            collectionName: "Space Oddities",
            reactions: Reactions(like: 20, mindBlowing: 10, alreadyKnew: 5, hardToBelieve: 3, interesting: 7)
        ), count: 4)
    ),
    Collection(
        id: "asd12dsa",
        name: "Futuristic Technologies",
        avatar: "https://www.pexels.com/photo/grayscale-photo-of-people-between-buildings-1217258/",
        posts: Array(repeating: Post(
            id: UUID().uuidString,
            content: ["Sample future tech content"],
            collectionId: "asd12dsa",
            collectionName: "Futuristic Technologies",
            reactions: Reactions(like: 18, mindBlowing: 9, alreadyKnew: 2, hardToBelieve: 4, interesting: 6)
        ), count: 2)
    )
]

// Dummy posts for preview (you can keep this as is)
let dummyPosts: [Post] = [
    Post(
        id: UUID().uuidString,
        content: ["Sample science content"],
        collectionId: "asdds321312a",
        collectionName: "Science Facts",
        reactions: Reactions(like: 10, mindBlowing: 5, alreadyKnew: 2, hardToBelieve: 1, interesting: 3)
    ),
    Post(
        id: UUID().uuidString,
        content: ["Sample history content"],
        collectionId: "a213sddsa",
        collectionName: "Historical Events",
        reactions: Reactions(like: 8, mindBlowing: 3, alreadyKnew: 4, hardToBelieve: 0, interesting: 2)
    ),
    Post(
        id: UUID().uuidString,
        content: ["Sample tech content"],
        collectionId: "asd132dsa",
        collectionName: "Tech Innovations",
        reactions: Reactions(like: 15, mindBlowing: 7, alreadyKnew: 1, hardToBelieve: 2, interesting: 5)
    )
]
