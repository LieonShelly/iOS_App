//
//  ImageEditorViewController.swift
//  IMEditor
//
//  Created by Renjun Li on 2025/4/4.
//

import UIKit
import MetalKit

class ImageEditorViewController: UIViewController {
    var metalView: MTKView!
    var renderer: MetalRenderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 1. 初始化 MTKView
        metalView = MTKView(frame: view.bounds)
        metalView.backgroundColor = .white
        view.addSubview(metalView)
        
        // 2. 初始化 Metal 渲染器
        renderer = MetalRenderer(mtkView: metalView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metalView.drawableSize = metalView.bounds.size
    }
}
