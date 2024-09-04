//
//  ViewController.swift
//  Camera
//
//  Created by 김소진 on 9/3/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var cameraPreviewView: CameraView!
    var captureSession: AVCaptureSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        // CameraPreviewView 설정
        cameraPreviewView = CameraView(frame: view.bounds)
        view.addSubview(cameraPreviewView)
        
        // 카메라 세션 설정
        setupCameraSession()

        // 촬영 버튼 액션 설정
        cameraPreviewView.captureButton.addTarget(self, action: #selector(didTapCaptureButton), for: .touchUpInside)
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
            cameraPreviewView.setSession(captureSession)
            
            captureSession.startRunning()
            
        } catch {
            print("카메라 설정 오류: \(error)")
        }
    }
    
    // 촬영 버튼이 눌렸을 때 호출되는 메서드
    @objc func didTapCaptureButton() {
        print("촬영 버튼이 눌렸습니다.")
        // 사진 촬영 로직 구현
    }
}


//class ViewController: UIViewController {
//    
//    var captureSession: AVCaptureSession!
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
//    var photoOutput: AVCapturePhotoOutput!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Capture session 설정
//        captureSession = AVCaptureSession()
//        // 고해상도 사진 품질 출력을 캡쳐하는 데 적합한 설
//        captureSession.sessionPreset = .photo
//        
//        // VCaptureDevice.default(for: .video) : 기본 후면 카메라 장치를 선택
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
//            print("카메라를 찾을 수 없습니다.")
//            return
//        }
//        
//        do {
//            // 카메라를(captureDevice) 캡처 세션에 연결하기 위해 사용
//            let cameraInput = try AVCaptureDeviceInput(device: captureDevice)
//            
//            // 입력 장치를 세션에 추가할 수 있는지 확인
//            if captureSession.canAddInput(cameraInput) {
//                // 가능하면 추가
//                captureSession.addInput(cameraInput)
//            } else {
//        
//            }
//            
//            // AVCapturePhotoOutput()은 사진 촬영을 처리하는 객체
//            photoOutput = AVCapturePhotoOutput()
//            
//            // 출력 장치를 세션에 추가할 수 있는지 확인
//            if captureSession.canAddOutput(photoOutput) {
//                // 가능하면 추가
//                captureSession.addOutput(photoOutput)
//            }
//            captureSession.sessionPreset = .photo
//            captureSession.commitConfiguration()
//            
//            // 미리보기 레이어 설정
//            // 실시간 비디오 피드 표시
//            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            videoPreviewLayer.videoGravity = .resizeAspectFill
//            videoPreviewLayer.frame = view.layer.bounds
//            view.layer.addSublayer(videoPreviewLayer)
//            
//            // 세션 시작
//            
//            
//        } catch {
//            print("카메라를 설정할 수 없습니다: \(error)")
//        }
//        
//        
//        
//    }
//
//
//}
//
//extension ViewController: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
//        guard let imageData = photo.fileDataRepresentation() else {
//            print("사진 데이터를 가져올 수 없습니다.")
//            return
//        }
//        
//        let capturedImage = UIImage(data: imageData)
//        print("사진이 저장되었습니다.")
//    }
//}
