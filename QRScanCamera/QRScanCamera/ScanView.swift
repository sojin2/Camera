//
//  ScanView.swift
//  QRScanCamera
//
//  Created by 김소진 on 9/5/24.
//

import Foundation
import UIKit
import AVFoundation

protocol ScanViewDelegate: AnyObject {
    func didDetectQRCode(_ code: String)
}

class ScanView: UIView {

    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice?

    weak var delegate: ScanViewDelegate?

    let previewView: UIView = {
        let preview = UIView()
        preview.backgroundColor = .clear
        preview.contentMode = .scaleAspectFill
        preview.translatesAutoresizingMaskIntoConstraints = false
        return preview
    }()
    
    let qrCodeFrameView: UIView = {
        let qrCodeFrameView = UIView()
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        qrCodeFrameView.translatesAutoresizingMaskIntoConstraints = false
        return qrCodeFrameView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTapGesture()
        setupPinchGesture()  // 핀치 제스처 추가
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer()
        videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.layer.addSublayer(videoPreviewLayer)
        
        addSubview(previewView)
        addSubview(qrCodeFrameView)
        setConstraints()
        
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: topAnchor),
            previewView.bottomAnchor.constraint(equalTo: bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    // 포커스
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFocusTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    // 줌인 줌아웃
    private func setupPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        self.addGestureRecognizer(pinchGesture)
    }

    @objc private func handleFocusTap(gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        focus(at: touchPoint)
        showFocusRectangle(at: touchPoint)
    }

    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let device = captureDevice else { return }
        
        let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
        let minZoomFactor: CGFloat = 1.0
        var newZoomFactor = device.videoZoomFactor * gesture.scale

        newZoomFactor = min(max(newZoomFactor, minZoomFactor), maxZoomFactor)

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = newZoomFactor
            device.unlockForConfiguration()
        } catch {
            print("줌 설정 오류: \(error)")
        }

        gesture.scale = 1.0
    }

    private func focus(at point: CGPoint) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        do {
            try device.lockForConfiguration()

            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
                device.focusMode = .autoFocus
            }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
                device.exposureMode = .autoExpose
            }

            device.unlockForConfiguration()
        } catch {
            print("포커스 설정 오류: \(error)")
        }
    }

    private func showFocusRectangle(at point: CGPoint) {
        viewWithTag(100)?.removeFromSuperview()
        
        let focusRectangle = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        focusRectangle.center = point
        focusRectangle.layer.borderColor = UIColor.yellow.cgColor
        focusRectangle.layer.borderWidth = 2
        focusRectangle.tag = 100
        
        addSubview(focusRectangle)

        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: {
            focusRectangle.alpha = 0
        }) { _ in
            focusRectangle.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = previewView.bounds
    }

    func setSession(_ session: AVCaptureSession) {
        videoPreviewLayer.session = session
        captureDevice = AVCaptureDevice.default(for: .video)
    }
    
    func configureQRCodeDetection(session: AVCaptureSession) {
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]  // QR 코드만 인식하도록 설정
        } else {
            print("메타데이터 출력을 추가할 수 없습니다.")
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // 메타데이터 객체가 비어 있으면 QR 코드 프레임을 숨김
        if metadataObjects.isEmpty {
            qrCodeFrameView.frame = CGRect.zero
            return
        }
        
        // QR 코드 인식
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if metadataObject.type == .qr {
                // QR 코드가 화면에 보이는 위치를 변환하여 표시
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
                qrCodeFrameView.frame = barCodeObject!.bounds
                
                if let qrCodeString = metadataObject.stringValue {
                    print("QR 코드 인식됨: \(qrCodeString)")
                    // QR 코드 인식 후 원하는 작업 수행
                }
            }
        }
    }
}

