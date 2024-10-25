//
//  QRCodeScannerView.swift
//  UIComponent
//
//  Created by Renjun Li on 2024/10/24.
//

import SwiftUI
import AVFoundation
import Combine

public struct QRCodeScannerView: View {
    enum Constants {
        static let scanPadding: CGFloat = 70
        static let lineWidth: CGFloat = 16
        static let lineH: CGFloat = 3
    }
    @State private var scanOffset: CGFloat = 0.0
    @State private var scanOpacity: Double = 0.0
    @State private var scanSize: Double = 0.0
    private let lineWidth: CGFloat = Constants.lineWidth
    private let lineH: CGFloat = Constants.lineH
    @ObservedObject var service: ScannerService
    
    public init(service: ScannerService) {
        self.service = service
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let parentWidth = proxy.size.width
            let parentH = proxy.size.height
            let scanSize = parentWidth - Constants.scanPadding * 2
            let scanCenter = CGPoint(x: parentWidth * 0.5, y: parentH * 0.5)
            ZStack {
                QRCodeScannerPreViewView(service: service)
                Color.black
                    .opacity(0.7)
                    .mask(
                        Rectangle()
                            .fill(style: FillStyle(eoFill: true))
                            .overlay(content: {
                                Rectangle()
                                    .frame(width: scanSize, height: scanSize)
                                    .position(x: scanCenter.x,
                                              y: scanCenter.y)
                                    .blendMode(.destinationOut)
                            })
                    )
                    .compositingGroup()
                    .overlay(
                        ZStack {
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 上边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(scanSize * 0.5) + lineWidth * 0.5,
                                    y: -scanSize * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 左边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(scanSize * 0.5) + lineH * 0.5,
                                    y: -scanSize * 0.5 + lineWidth * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 上边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineWidth * 0.5,
                                    y: -scanSize * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 右边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineH * 0.5,
                                    y: -scanSize * 0.5 + lineWidth * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 下边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(scanSize * 0.5) + lineWidth * 0.5,
                                    y: scanSize * 0.5 - lineH * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 左边框
                                .foregroundColor(.red)
                                .offset(
                                    x: -(scanSize * 0.5) + lineH * 0.5,
                                    y: scanSize * 0.5 - lineWidth * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineWidth, height: lineH) // 下边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineWidth * 0.5,
                                    y: scanSize * 0.5 - lineH * 0.5
                                )
                            
                            Rectangle()
                                .frame(width: lineH, height: lineWidth) // 右边框
                                .foregroundColor(.red)
                                .offset(
                                    x: scanSize * 0.5 - lineH * 0.5,
                                    y: scanSize * 0.5 - lineWidth * 0.5
                                )
                        }
                    )
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: scanSize, height: 2)
                    .position(x: scanCenter.x, y: scanCenter.y + scanOffset)
                    .opacity(scanOpacity)
                    .onAppear {
                        startOffsetAnimation(scanSize * 0.5, endValue: -scanSize * 0.5)
                        startOpacityAnimation()
                    }
                
                titleView
                bottomView
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var titleView: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.backward")
                    .frame(width: 24, height: 24)
                    .padding(.leading, 20)
                Spacer()
            }
            .frame(height: 48)
            .padding(.top, LayoutConstants.safeArea.top)
            
            Text("scan")
                .foregroundStyle(.white)
                .padding(.top, 34)
            Spacer()
        }
        
    }
    
    private var bottomView: some View {
        VStack {
            Spacer()
            HStack {
                VStack(spacing: 12) {
                    Image(systemName: "keyboard.fill")
                        .frame(width: 50, height: 50)
                    Text("输入设备号")
                }
                .foregroundStyle(.white)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "flashlight.on.fill")
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            service.isTochOn = !service.isTochOn
                        }
                    Text("输入设备号")
                }
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
        
    }
    
    private func startOffsetAnimation(_ initValue: CGFloat, endValue: CGFloat) {
        withAnimation(.easeInOut(duration: 2.0)) {
            scanOffset = initValue
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            scanOffset = endValue
            startOffsetAnimation(initValue, endValue: endValue)
        })
    }
    
    private func startOpacityAnimation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            scanOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            withAnimation(.easeInOut(duration: 0.5)) {
                scanOpacity = 0.0
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            startOpacityAnimation()
        })
    }
}


#Preview {
    QRCodeScannerView(service: ScannerService())
}


enum LayoutConstants {
    static var safeArea: UIEdgeInsets {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return keyWindow?.safeAreaInsets ?? .zero
    }
}


struct QRCodeScannerPreViewView: UIViewControllerRepresentable {
    @ObservedObject var service: ScannerService
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        service.setupCamera(viewController: viewController)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
}


public class ScannerService: NSObject, AVCaptureMetadataOutputObjectsDelegate, ObservableObject {
    @Published var isTochOn: Bool = false {
        didSet {
            toggleTorch(on: isTochOn)
        }
    }
    @Published var qrCodeString: String?
    private var captureSession: AVCaptureSession
    private var cancellables: Set<AnyCancellable> = .init()
    
    public init(captureSession: AVCaptureSession = AVCaptureSession())  {
        self.captureSession = captureSession
        super.init()
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.startScanning()
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.stopScanning()
            }
            .store(in: &cancellables)
    }
    
    func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func setupCamera(viewController: UIViewController) {
        checkCameraAuthorization {[weak self] authorized in
            if let self, authorized {
                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
                let videoInput: AVCaptureDeviceInput
                
                do {
                    videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                } catch {
                    return
                }
                
                if (self.captureSession.canAddInput(videoInput)) {
                    self.captureSession.addInput(videoInput)
                } else {
                    return
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                
                if (self.captureSession.canAddOutput(metadataOutput)) {
                    self.captureSession.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.qr]
                } else {
                    return
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer.frame = viewController.view.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                viewController.view.layer.addSublayer(previewLayer)
                self.startScanning()
            } else {
                
            }
        }
    }
    
    func startScanning() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func stopScanning() {
        captureSession.stopRunning()
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error setting torch: \(error)")
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            stopScanning()
            qrCodeString = stringValue
        }
    }
}
