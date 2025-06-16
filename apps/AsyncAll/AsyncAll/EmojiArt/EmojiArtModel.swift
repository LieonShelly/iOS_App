//
//  EmojiArtModel.swift
//  AsyncAll
//
//  Created by Renjun Li on 2025/6/16.
//

import Foundation

class EmojiArtModel: ObservableObject {
    @Published @MainActor private(set) var imageFeed: [ImageFile] = []
    private(set) var verifiedCount = 0
    
    func loadImages() async throws {
        await MainActor.run {
            imageFeed.removeAll()
        }
        
        guard let url = URL(string: "http://localhost:8080/gallery/images") else {
          throw "Could not create endpoint URL"
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded with an error."
        }
        guard let list = try? JSONDecoder().decode([ImageFile].self, from: data) else {
            throw "The server response was not recognized"
        }
        await MainActor.run {
            imageFeed = list
        }
    }
}



struct ImageFile: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let url: String
    let price: Double
    let checksum: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        price = try container.decode(Double.self, forKey: .price)
        checksum = try container.decode(String.self, forKey: .checksum)
    }
}
