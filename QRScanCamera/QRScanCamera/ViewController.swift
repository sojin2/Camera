//
//  ViewController.swift
//  QRScanCamera
//
//  Created by 김소진 on 9/5/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, ScanViewDelegate {
    var scanView: ScanView!
    var captureSession: AVCaptureSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        // CameraPreviewView 설정
        scanView = ScanView(frame: view.bounds)
        view.addSubview(scanView)
        scanView.delegate = self
        
        // 카메라 세션 설정
        setupCameraSession()
    }
    
    // 카메라 세션 설정
    private func setupCameraSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        // 후면 카메라 설정
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("카메라를 찾을 수 없습니다.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            // 미리보기 레이어에 세션 연결
            scanView.setSession(captureSession)
            scanView.configureQRCodeDetection(session: captureSession)
            
            captureSession.startRunning()
            
        } catch {
            print("카메라 설정 오류: \(error)")
        }
    }
    
    func didDetectQRCode(_ code: String) {
        print("QR 코드 인식됨: \(code)")
        
        // QR 코드 데이터를 처리하거나 네트워크 요청
        handleQRCodeData(code)
    }
    
    func handleQRCodeData(_ code: String) {
        // QR 코드 데이터를 처리 로직
        print("QR 코드 처리 중: \(code)")
    }
}
