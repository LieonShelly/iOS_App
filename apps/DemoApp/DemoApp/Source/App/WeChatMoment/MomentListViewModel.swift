//
//  MomentListViewModel.swift
//  DemoApp
//
//  Created by Renjun Li on 2025/3/7.
//

import Foundation
import Combine
import SwiftUI

class MomentListViewModel: ObservableObject {
    //发布朋友圈列表数据
    @Published var moments: [Moment] = []
    
    // 加载状态
    @Published var isLoading = false
    
    // 错误信息
    @Published var errorMessage: String?// 服务实例
    private let service = ListService()
    
    // 用于存储和管理订阅
    private var cancellables = Set<AnyCancellable>()
    
    init() { }// 使用Combine加载数据
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        service.fetchMoments()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] moments in
                self?.moments = moments
                // 过滤掉无效数据
                self?.moments = moments.filter { !$0.content.isEmpty || !$0.images.isEmpty }
            })
            .store(in: &cancellables)
    }
    
    // 使用异步函数加载数据
    @MainActor
    func loadDataAsync() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let moments = try await service.fetchMomentsAsync()
            self.moments = moments.filter { !$0.content.isEmpty || !$0.images.isEmpty }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    // 使用回调方式加载数据
    func loadDataWithCallback() {
        isLoading = true
        errorMessage = nil
        
        service.fetchMoments { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let moments):
                    self?.moments = moments.filter { !$0.content.isEmpty || !$0.images.isEmpty }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 刷新数据
    func refresh() {
        loadData()
    }
}
