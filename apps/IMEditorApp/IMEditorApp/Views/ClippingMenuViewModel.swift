//
//  ClippingMenuViewModel.swift
//  IMEditorApp
//
//  Created by Renjun Li on 2025/4/21.
//

import Foundation
import Combine

struct ClippingMenuEntity: Identifiable {
    var id: String = UUID().uuidString
    let index: Int
    let iconName: String
    var isSelect: Bool
    let minValue: CGFloat = 0
    let maxValue: CGFloat = 100
    var progress: CGFloat
    
    
    init(id: String = UUID().uuidString, index: Int, iconName: String, isSelect: Bool, progress: CGFloat = 0) {
        self.id = id
        self.iconName = iconName
        self.isSelect = isSelect
        self.progress = progress
        self.index = index
    }
}


class ClippingMenuViewModel: ObservableObject {
    
    @Published var menuList: [ClippingMenuEntity] = [
        ClippingMenuEntity(index: 0, iconName: "rotate.3d", isSelect: true, progress: 0.5),
        ClippingMenuEntity(index: 1, iconName: "rotate.3d", isSelect: false, progress: 0.5),
        ClippingMenuEntity(index: 2, iconName: "rotate.3d", isSelect: false, progress: 0.5),
        ClippingMenuEntity(index: 3, iconName: "rotate.3d", isSelect: false, progress: 0.5),
        ClippingMenuEntity(index: 4, iconName: "rotate.3d", isSelect: false, progress: 0.5),
    ]
    
    @Published var selectedMenu: ClippingMenuEntity?
    @Published var selectedProgress: CGFloat = 0
    var didUpdateProgress: ((_ index: Int, _ progress: CGFloat) -> Void)?
    
    var anyCancellables: Set<AnyCancellable> = .init()
    
    init() {
        $selectedProgress.sink {[weak self] value in
            self?.updateProgress(value)
        }
        .store(in: &anyCancellables)
        selectedMenu = menuList.first
        selectedProgress = selectedMenu?.progress ?? 0
    }
    
    
    func onTapItem(_ menu: ClippingMenuEntity) {
        guard let index = menuList.firstIndex(where: { $0.id == menu.id}) else { return }
        var newList = menuList.map { menu in
             var men = menu
             men.isSelect = false
             return men
         }
        var select = menu
        select.isSelect = true
        newList[index] = select
        self.menuList = newList
        self.selectedMenu = select
        selectedProgress = select.progress
    }
    
    func updateProgress(_ progress: CGFloat) {
        guard var selectedMenu else { return }
        selectedMenu.progress = progress
        guard let index = menuList.firstIndex(where: { $0.id == selectedMenu.id}) else { return }
        menuList[index] = selectedMenu
        didUpdateProgress?(index, selectedMenu.progress)
    }
}
