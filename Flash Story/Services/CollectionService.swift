//
//  CollectionService.swift
//  Flash Story
//
//  Created by Hiếu Nguyễn Minh on 9/19/24.
//

import Foundation

class CollectionService {
    private let baseURL = "http://localhost:3000/api"
    
    func getAllCollections() async throws -> [CollectionView] {
        let url = URL(string: "\(baseURL)/collections")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([CollectionView].self, from: data)
    }
}
