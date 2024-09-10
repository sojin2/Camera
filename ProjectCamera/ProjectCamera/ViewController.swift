//
//  ViewController.swift
//  ProjectCamera
//
//  Created by 김소진 on 9/10/24.
//
import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var cameraPreviewView: CameraView!
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CameraPreviewView 설정
        cameraPreviewView = CameraView(frame: view.bounds)
        view.addSubview(cameraPreviewView)
        
        // 카메라 세션 설정
        setupCameraSession()
        
        // 이미지 저장 폴더 생성
        saveImageToFolder()
        
        // 촬영 버튼 액션 설정
        cameraPreviewView.captureBtn.addTarget(self, action: #selector(didTapCaptureButton), for: .touchUpInside)
        cameraPreviewView.saveBtn.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        cameraPreviewView.cancelBtn.addTarget(self, action: #selector(deleteAllImagesInFolder), for: .touchUpInside)
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
            
            // 사진 출력 설정
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
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
        
        // 사진 캡처 설정
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        // 사진 촬영
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        
    }
    
    @objc func didTapSaveButton() {
        print("완료 버튼이 눌렸습니다.")
        
        
    }
    
    // AVCapturePhotoCaptureDelegate 메서드: 사진 촬영 완료 시 호출
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("사진 촬영 오류: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("이미지 데이터를 얻을 수 없습니다.")
            return
        }
        
        // UIImage로 변환
        let capturedImage = UIImage(data: imageData)
        
        // 썸네일 업데이트
        if let image = capturedImage {
            cameraPreviewView.updateThumbnail(with: image)
            var _ = saveImageToDocumentsDirectory(image: image, fileName: "image_\(UUID().uuidString).jpg")
        }
    }
    
}

extension ViewController {
    // 폴더 생성
    func saveImageToFolder() {
        let fileManager = FileManager.default
        let folderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ImageFolder")
        
        // 폴더가 없으면 생성
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("폴더 생성 오류: \(error)")
            }
        }
    }
    
    // 이미지 저장
    func saveImageToDocumentsDirectory(image: UIImage, fileName: String) -> URL? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let fileManager = FileManager.default
            
            // ImageFolder 경로로 변경
            let folderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ImageFolder")
            
            // 폴더가 없으면 생성
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("폴더 생성 오류: \(error)")
                    return nil
                }
            }
            
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("Image saved to: \(fileURL)")
                return fileURL
            } catch {
                print("Error saving file: \(error)")
                return nil
            }
        }
        return nil
    }
    
    // 폴더 삭제
    @objc func deleteAllImagesInFolder() {
        let fileManager = FileManager.default
        let folderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ImageFolder")
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [])
            
            for filePath in filePaths {
                try fileManager.removeItem(at: filePath)
                print("Deleted: \(filePath)")
            }
            
            // 폴더도 삭제하려면 아래 줄을 추가
            try fileManager.removeItem(at: folderURL)
            print("All files and folder deleted.")
            
        } catch {
            print("Error deleting files: \(error)")
        }
    }
}
