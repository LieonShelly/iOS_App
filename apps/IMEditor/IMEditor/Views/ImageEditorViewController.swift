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
    
    // 裁剪框视图
    private var cropBoxView: CropBoxView!
    // 记录图像在视图中的实际显示区域
    private var imageFrame: CGRect = .zero
    // 裁剪按钮
    private var cropButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 1. 初始化 MTKView
        metalView = MTKView(frame: view.bounds)
        metalView.backgroundColor = .white
        view.addSubview(metalView)
        
        // 2. 初始化 Metal 渲染器
        renderer = MetalRenderer(mtkView: metalView)
        
        // 3. 设置裁剪框
        setupCropBox()
        
        // 4. 设置裁剪按钮
        setupCropButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metalView.drawableSize = metalView.bounds.size
        
        // 更新裁剪框位置
        updateCropBoxFrame()
        
        // 更新裁剪按钮位置
        cropButton.frame = CGRect(x: view.bounds.width - 80, y: view.bounds.height - 100, width: 60, height: 40)
    }
    
    // 设置裁剪框
    private func setupCropBox() {
        cropBoxView = CropBoxView(frame: .zero)
        cropBoxView.delegate = self
        view.addSubview(cropBoxView)
        
        // 添加手势识别器用于缩放
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        // 添加手势识别器用于移动整个裁剪框
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCropBoxMove(_:)))
        // 添加手势识别器用于在裁剪框内平移图像
        let panImageGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        
        cropBoxView.addGestureRecognizer(pinchGesture)
        cropBoxView.addGestureRecognizer(moveGesture)
        cropBoxView.addGestureRecognizer(panImageGesture)
        
        // 确保移动手势不会与角落的拖动手势冲突
        for corner in [cropBoxView.topLeftCorner, cropBoxView.topRightCorner, 
                      cropBoxView.bottomLeftCorner, cropBoxView.bottomRightCorner] {
            moveGesture.require(toFail: corner.gestureRecognizers!.first!)
            panImageGesture.require(toFail: corner.gestureRecognizers!.first!)
        }
        
        // 确保移动整个裁剪框的手势优先级高于内部图像平移
        panImageGesture.require(toFail: moveGesture)
    }
    
    // 更新裁剪框位置为图像的实际显示区域
    private func updateCropBoxFrame() {
        guard let texture = renderer.texture else { return }
        
        let imageSize = CGSize(width: texture.width, height: texture.height)
        let viewSize = metalView.bounds.size
        
        // 计算图像在视图中的实际显示区域
        let padding: CGFloat = 20.0 // 左右各20pt的间距
        let paddingRatio = (padding * 2) / viewSize.width
        let maxWidth = viewSize.width * (1.0 - paddingRatio)
        
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        let effectiveViewAspect = viewSize.width * (1.0 - paddingRatio) / viewSize.height
        
        var displayWidth: CGFloat = maxWidth
        var displayHeight: CGFloat = viewSize.height
        
        if imageAspect > effectiveViewAspect {
            // 图像宽度适应屏幕宽度减去padding
            displayHeight = maxWidth / imageAspect
        } else {
            // 图像高度适应屏幕高度
            displayWidth = imageAspect * viewSize.height
        }
        
        let x = (viewSize.width - displayWidth) / 2
        let y = (viewSize.height - displayHeight) / 2
        
        imageFrame = CGRect(x: x, y: y, width: displayWidth, height: displayHeight)
        cropBoxView.frame = imageFrame
    }
    
    // 处理缩放手势
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            // 将缩放系数传递给渲染器
            renderer.zoom(factor: Float(gesture.scale))
            // 每次更新后重置缩放手势的比例
            gesture.scale = 1.0
        default:
            break
        }
    }
    
    // 处理移动整个裁剪框的手势
    @objc private func handleCropBoxMove(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: view)
            
            // 移动整个裁剪框
            cropBoxView.center = CGPoint(
                x: cropBoxView.center.x + translation.x,
                y: cropBoxView.center.y + translation.y
            )
            
            // 通知裁剪框位置变化
            cropBoxView.delegate?.cropBoxDidMove(cropBoxView)
            
            // 重置手势的平移
            gesture.setTranslation(.zero, in: view)
        default:
            break
        }
    }
    
    // 处理裁剪框内图像平移手势
    @objc private func handleImagePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            // 获取平移的距离
            let translation = gesture.translation(in: cropBoxView)
            
            // 将平移转换为归一化坐标系下的偏移
            // 平移方向需要反转，因为图像移动方向与手指移动方向相反
            let deltaX = Float(-translation.x / cropBoxView.bounds.width) * 2.0 // 转换到 -1 到 1 的范围
            let deltaY = Float(-translation.y / cropBoxView.bounds.height) * 2.0 // 转换到 -1 到 1 的范围
            
            // 将平移偏移传递给渲染器
            renderer.pan(deltaX: deltaX, deltaY: deltaY)
            
            // 每次更新后重置平移手势的位移
            gesture.setTranslation(.zero, in: cropBoxView)
        default:
            break
        }
    }
    
    // 设置裁剪按钮
    private func setupCropButton() {
        cropButton = UIButton(type: .system)
        cropButton.setTitle("裁剪", for: .normal)
        cropButton.backgroundColor = UIColor.systemBlue
        cropButton.setTitleColor(.white, for: .normal)
        cropButton.layer.cornerRadius = 20
        cropButton.frame = CGRect(x: view.bounds.width - 80, y: view.bounds.height - 100, width: 60, height: 40)
        cropButton.addTarget(self, action: #selector(cropButtonTapped), for: .touchUpInside)
        view.addSubview(cropButton)
    }
    
    @objc private func cropButtonTapped() {
        performCrop()
    }
}

// MARK: - CropBoxViewDelegate
extension ImageEditorViewController: CropBoxViewDelegate {
    func cropBoxDidResize(_ cropBox: CropBoxView) {
        // 裁剪框大小改变时，需要重置图像变换
        renderer.resetTransform()
    }
    
    func cropBoxDidMove(_ cropBox: CropBoxView) {
        // 裁剪框位置改变时的处理
    }
    
    // 获取裁剪参数
    func getCropParameters() -> (originInImage: CGPoint, sizeInImage: CGSize)? {
        guard let texture = renderer.texture else { return nil }
        
        // 获取图像原始尺寸
        let imageSize = CGSize(width: texture.width, height: texture.height)
        // 获取图像在视图中的实际显示区域
        let displayFrame = renderer.getImageFrame(in: view.bounds.size)
        
        // 计算裁剪框相对于图像显示区域的位置和大小
        let cropFrameInDisplay = CGRect(
            x: (cropBoxView.frame.minX - displayFrame.minX) / displayFrame.width,
            y: (cropBoxView.frame.minY - displayFrame.minY) / displayFrame.height,
            width: cropBoxView.frame.width / displayFrame.width,
            height: cropBoxView.frame.height / displayFrame.height
        )
        
        // 转换为图像原始尺寸下的裁剪区域
        let originInImage = CGPoint(
            x: cropFrameInDisplay.minX * imageSize.width,
            y: cropFrameInDisplay.minY * imageSize.height
        )
        let sizeInImage = CGSize(
            width: cropFrameInDisplay.width * imageSize.width,
            height: cropFrameInDisplay.height * imageSize.height
        )
        
        return (originInImage, sizeInImage)
    }
    
    // 执行裁剪操作
    func performCrop() {
        guard let (origin, size) = getCropParameters() else { return }
        
        // 计算裁剪区域（转换为整数坐标）
        let fromX = Int(origin.x)
        let fromY = Int(origin.y)
        let width = Int(size.width)
        let height = Int(size.height)
        
        // 显示加载指示器
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // 调用Metal渲染器进行裁剪
        renderer.cropImage(fromX: fromX, fromY: fromY, width: width, height: height) { [weak self] success in
            // 移除加载指示器
            activityIndicator.removeFromSuperview()
            
            if success {
                // 裁剪成功，更新裁剪框位置
                self?.updateCropBoxFrame()
                
                // 显示成功提示
                let successLabel = UILabel()
                successLabel.text = "裁剪成功"
                successLabel.textAlignment = .center
                successLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                successLabel.textColor = .white
                successLabel.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
                successLabel.center = (self?.view.center)!
                successLabel.layer.cornerRadius = 10
                successLabel.clipsToBounds = true
                self?.view.addSubview(successLabel)
                
                // 2秒后隐藏提示
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIView.animate(withDuration: 0.3, animations: {
                        successLabel.alpha = 0
                    }) { _ in
                        successLabel.removeFromSuperview()
                    }
                }
            } else {
                // 裁剪失败，显示错误信息
                let alert = UIAlertController(title: "裁剪失败", message: "请调整裁剪区域后重试", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}

// MARK: - CropBoxView
protocol CropBoxViewDelegate: AnyObject {
    func cropBoxDidResize(_ cropBox: CropBoxView)
    func cropBoxDidMove(_ cropBox: CropBoxView)
}

class CropBoxView: UIView {
    weak var delegate: CropBoxViewDelegate?
    
    // 四个角的控制点 - 修改为公开属性
    var topLeftCorner = UIView()
    var topRightCorner = UIView()
    var bottomLeftCorner = UIView()
    var bottomRightCorner = UIView()
    
    // 边框
    private var borderView = UIView()
    
    // 网格线
    private var gridLines = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        // 设置边框
        borderView.frame = bounds
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.backgroundColor = .clear
        addSubview(borderView)
        
        // 设置网格线
        setupGridLines()
        
        // 设置四个角的控制点
        let cornerSize: CGFloat = 30
        
        topLeftCorner.frame = CGRect(x: -cornerSize/2, y: -cornerSize/2, width: cornerSize, height: cornerSize)
        topRightCorner.frame = CGRect(x: bounds.width-cornerSize/2, y: -cornerSize/2, width: cornerSize, height: cornerSize)
        bottomLeftCorner.frame = CGRect(x: -cornerSize/2, y: bounds.height-cornerSize/2, width: cornerSize, height: cornerSize)
        bottomRightCorner.frame = CGRect(x: bounds.width-cornerSize/2, y: bounds.height-cornerSize/2, width: cornerSize, height: cornerSize)
        
        [topLeftCorner, topRightCorner, bottomLeftCorner, bottomRightCorner].forEach { corner in
            corner.backgroundColor = .clear
            addSubview(corner)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCornerPan(_:)))
            corner.addGestureRecognizer(panGesture)
            corner.isUserInteractionEnabled = true
        }
        
        // 添加可视指示器
        addCornerIndicator(to: topLeftCorner)
        addCornerIndicator(to: topRightCorner)
        addCornerIndicator(to: bottomLeftCorner)
        addCornerIndicator(to: bottomRightCorner)
    }
    
    private func addCornerIndicator(to corner: UIView) {
        let indicator = UIView(frame: CGRect(x: corner.bounds.width/2 - 10, y: corner.bounds.height/2 - 10, width: 20, height: 20))
        indicator.backgroundColor = .clear
        indicator.layer.borderWidth = 2
        indicator.layer.borderColor = UIColor.white.cgColor
        indicator.layer.cornerRadius = 10
        corner.addSubview(indicator)
    }
    
    private func setupGridLines() {
        // 清除现有网格线
        gridLines.forEach { $0.removeFromSuperview() }
        gridLines.removeAll()
        
        // 创建网格线（3x3网格，每行和每列各2条线）
        for i in 1...2 {
            // 水平线
            let horizontalLine = UIView()
            horizontalLine.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            horizontalLine.frame = CGRect(x: 0, y: bounds.height * CGFloat(i) / 3, width: bounds.width, height: 0.5)
            addSubview(horizontalLine)
            gridLines.append(horizontalLine)
            
            // 垂直线
            let verticalLine = UIView()
            verticalLine.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            verticalLine.frame = CGRect(x: bounds.width * CGFloat(i) / 3, y: 0, width: 0.5, height: bounds.height)
            addSubview(verticalLine)
            gridLines.append(verticalLine)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新边框和网格线
        borderView.frame = bounds
        setupGridLines()
        
        // 更新四个角的位置
        let cornerSize: CGFloat = 30
        topLeftCorner.frame = CGRect(x: -cornerSize/2, y: -cornerSize/2, width: cornerSize, height: cornerSize)
        topRightCorner.frame = CGRect(x: bounds.width-cornerSize/2, y: -cornerSize/2, width: cornerSize, height: cornerSize)
        bottomLeftCorner.frame = CGRect(x: -cornerSize/2, y: bounds.height-cornerSize/2, width: cornerSize, height: cornerSize)
        bottomRightCorner.frame = CGRect(x: bounds.width-cornerSize/2, y: bounds.height-cornerSize/2, width: cornerSize, height: cornerSize)
    }
    
    @objc private func handleCornerPan(_ gesture: UIPanGestureRecognizer) {
        guard let corner = gesture.view else { return }
        
        let translation = gesture.translation(in: self.superview)
        
        // 保存原始框架以在必要时恢复
        let originalFrame = self.frame
        var newFrame = originalFrame
        
        // 根据拖动的角调整框架
        if corner === topLeftCorner {
            newFrame.origin.x += translation.x
            newFrame.origin.y += translation.y
            newFrame.size.width -= translation.x
            newFrame.size.height -= translation.y
        } else if corner === topRightCorner {
            newFrame.origin.y += translation.y
            newFrame.size.width += translation.x
            newFrame.size.height -= translation.y
        } else if corner === bottomLeftCorner {
            newFrame.origin.x += translation.x
            newFrame.size.width -= translation.x
            newFrame.size.height += translation.y
        } else if corner === bottomRightCorner {
            newFrame.size.width += translation.x
            newFrame.size.height += translation.y
        }
        
        // 验证新框架的最小尺寸
        let minSize: CGFloat = 50
        if newFrame.size.width >= minSize && newFrame.size.height >= minSize {
            self.frame = newFrame
            delegate?.cropBoxDidResize(self)
        } else {
            // 如果新尺寸太小，恢复原始框架
            self.frame = originalFrame
        }
        
        // 重置手势的平移
        gesture.setTranslation(.zero, in: self.superview)
    }
}
