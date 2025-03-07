//
//  ListService.swift
//  DemoApp
//
//  Created by Comate on 2025/3/7.
//

import Foundation
import Combine

// 朋友圈数据服务类
class ListService {
    // 基础URL
    private let baseURL = "https://apifoxmock.com/m1/5946593-5634569-default/moments"
    private let token = "JapJysb5u-n8yGO7__FEB"
    
    // 使用Combine框架获取朋友圈数据
    func fetchMoments() -> AnyPublisher<[Moment], Error> {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // 添加token参数
        urlComponents.queryItems = [URLQueryItem(name: "apifoxToken", value: token)]
        
        guard let url = urlComponents.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MomentResponse.self, decoder: JSONDecoder())
            .map { response in
                // 将API数据转换为应用内模型
                return response.map { $0.toMoment() }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // 使用异步函数获取朋友圈数据（Swift 5.5+ async/await）
    func fetchMomentsAsync() async throws -> [Moment] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        // 添加token参数
        urlComponents.queryItems = [URLQueryItem(name: "apifoxToken", value: self.token)]
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MomentResponse.self, from: data)
        
        // 将API数据转换为应用内模型
        return response.map { $0.toMoment() }
    }
    
    // 使用传统回调方式获取朋友圈数据
    func fetchMoments(completion: @escaping (Result<[Moment], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // 添加token参数
        urlComponents.queryItems = [URLQueryItem(name: "apifoxToken", value: token)]
        
        guard let url = urlComponents.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(MomentResponse.self, from: data)
                let moments = response.map { $0.toMoment() }
                
                DispatchQueue.main.async {
                    completion(.success(moments))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
