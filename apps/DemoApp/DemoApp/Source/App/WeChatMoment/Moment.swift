//
//  Moment.swift
//  DemoApp
//
//  Created by Comate on 2025/3/7.
//

import Foundation

// MARK: - 图片数据结构
struct ImageData: Codable {
    let url: String
}

// MARK: - 用户数据结构
struct SenderData: Codable {
    let username: String
    let nick: String
    let avatar: String
}

// MARK: - 评论数据结构
struct CommentData: Codable {
    let content: String
    let sender: SenderData
}

// MARK: - 朋友圈动态数据结构
struct MomentData: Codable, Identifiable {
    // 自定义ID，因为API返回的数据没有统一的ID字段
    var id = UUID()// 基本字段，都设为可选类型，因为JSON中有些字段可能不存在
    let content: String?
    let images: [ImageData]?
    let sender: SenderData?
    let comments: [CommentData]?
    
    // 错误字段，用于处理特殊情况
    let error: String?
    let unknownError: String?
    
    // CodingKeys 用于处理JSON字段映射
    enum CodingKeys: String, CodingKey {
        case content
        case images
        case sender
        case comments
        case error
        case unknownError = "unknown error"
        
    }

    // 将API数据转换为应用内使用的Moment模型
    func toMoment() -> Moment {
        // 提取图片URL
        let imageUrls = images?.map { $0.url } ?? []
        
        // 提取评论文本
        let commentTexts = comments?.map { "\($0.sender.nick): \($0.content)" } ?? []
        
        return Moment(
            userName: sender?.nick ?? "Nil",
            userAvatar: sender?.avatar ?? "Nil",
            content: content ?? "",
            images: imageUrls,
            likes: 0, // API中没有likes字段，默认为0
            comments: commentTexts
        )
    }
    
    // 自定义解码初始化方法，处理可能的错误情况
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解码所有可选字段
        content = try? container.decodeIfPresent(String.self, forKey: .content) ?? nil
        images = try? container.decodeIfPresent([ImageData].self, forKey: .images)
        sender = try? container.decode(SenderData.self, forKey: .sender) ?? nil // sender是必需的
        comments = try? container.decodeIfPresent([CommentData].self, forKey: .comments) ?? nil
        error = try? container.decodeIfPresent(String.self, forKey: .error) ?? nil
        unknownError = try? container.decodeIfPresent(String.self, forKey: .unknownError) ?? nil
    }
}

// MARK: - 应用内使用的朋友圈模型
struct Moment: Identifiable {
    let id = UUID()
    let userName: String
    let userAvatar: String
    let content: String
    let images: [String]
    let likes: Int
    let comments: [String]
}

// MARK: - 用于解析API返回的数据结构
typealias MomentResponse = [MomentData]
