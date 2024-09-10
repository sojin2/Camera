//
//  CameraView.swift
//  ProjectCamera
//
//  Created by 김소진 on 9/10/24.
//

import UIKit
import AVFoundation

class CameraView: UIView {

    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    let previewView: UIView = {
        let preview = UIView()
        preview.backgroundColor = .clear
        preview.contentMode = .scaleAspectFill
        preview.translatesAutoresizingMaskIntoConstraints = false  
        return preview
    }()
    
    let captureBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 35
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let saveBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // 카메라 미리보기 레이어 설정
        videoPreviewLayer = AVCaptureVideoPreviewLayer()
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        // previewView에 videoPreviewLayer 추가
        previewView.layer.addSublayer(videoPreviewLayer)
        
        addSubview(previewView)
        addSubview(captureBtn)
        addSubview(thumbnailImageView)
        addSubview(saveBtn)
        addSubview(cancelBtn)
        setConstraints()
    }
    
    func setConstraints() {
        // previewView에 대한 제약 조건
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: topAnchor),
            previewView.bottomAnchor.constraint(equalTo: bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cancelBtn.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancelBtn.widthAnchor.constraint(equalToConstant: 70),
            cancelBtn.heightAnchor.constraint(equalToConstant: 70),
            cancelBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            saveBtn.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            saveBtn.widthAnchor.constraint(equalToConstant: 70),
            saveBtn.heightAnchor.constraint(equalToConstant: 70),
            saveBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])

        // 버튼의 제약 조건 설정 (화면 하단 중앙에 배치)
        NSLayoutConstraint.activate([
            captureBtn.widthAnchor.constraint(equalToConstant: 70),
            captureBtn.heightAnchor.constraint(equalToConstant: 70),
            captureBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
            captureBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        // 썸네일 이미지 뷰의 제약 조건 설정 (왼쪽 하단 구석에 배치)
        NSLayoutConstraint.activate([
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 100),
            thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            thumbnailImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFocusTap))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleFocusTap(gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)

        // 포커스와 노출을 맞추는 메서드
        focus(at: touchPoint)

        // 포커스 사각형 그리기
        showFocusRectangle(at: touchPoint)
    }
    
    private func focus(at point: CGPoint) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        do {
            try device.lockForConfiguration()

            // 포커스와 노출 설정
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
        // 기존 포커스 사각형 제거
        viewWithTag(100)?.removeFromSuperview()
        
        // 포커스 사각형 그리기
        let focusRectangle = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        focusRectangle.center = point
        focusRectangle.layer.borderColor = UIColor.yellow.cgColor
        focusRectangle.layer.borderWidth = 2
        focusRectangle.tag = 100
        
        addSubview(focusRectangle)

        // 사라짐 애니메이션
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: {
            focusRectangle.alpha = 0
        }) { _ in
            focusRectangle.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // videoPreviewLayer가 previewView의 전체 크기를 차지하도록 설정
        videoPreviewLayer.frame = previewView.bounds
    }
    
    // 미리보기 레이어에 세션 연결
    func setSession(_ session: AVCaptureSession) {
        videoPreviewLayer.session = session
    }
    
    // 최근 사진 업데이트
    func updateThumbnail(with image: UIImage) {
        thumbnailImageView.image = image
    }
}
