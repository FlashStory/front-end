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
    
    func getPostById(postId: String) async throws -> Post {
        let url = URL(string: "\(baseURL)/posts/\(postId)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "PostService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post not found"])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Post.self, from: data)
    }
    
    func getRandomPosts(count: Int) async throws -> [Post] {
        let url = URL(string: "\(baseURL)/posts/random?count=\(count)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([Post].self, from: data)
    }
    
    func reactToPost(postId: String, reaction: String, amount: Int) async throws -> Reactions {
        let url = URL(string: "\(baseURL)/posts/\(postId)/react")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["reaction": reaction, "amount": amount]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Reactions.self, from: data)
    }
}
