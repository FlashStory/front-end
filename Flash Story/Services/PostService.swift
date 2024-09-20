//
//  PostService.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

class PostService {
    private let baseURL = "http://localhost:3000/api"
    
    func getPostsByCollection(collectionId: String) async throws -> [Post] {
        let url = URL(string: "\(baseURL)/posts/collection/\(collectionId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([Post].self, from: data)
    }
}
