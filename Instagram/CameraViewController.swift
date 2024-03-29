//
//  CameraViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    private var output  = AVCapturePhotoOutput()
    private var captureSession:AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let camerView = UIView()
    
    private let shutterButton:UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.backgroundColor = nil
        return button
    }()
    
    private let photoPickerButton:UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        let image = UIImage(systemName: "photo", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Take Photo"
        view.addSubview(camerView)
        view.addSubview(shutterButton)
        view.addSubview(photoPickerButton)
        setUpNavBar()
        checkCameraPermission()
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        photoPickerButton.addTarget(self, action: #selector(didTapPickPhoto), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        if let session = captureSession, !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        camerView.frame = view.bounds
        previewLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        
        let buttonSize = view.width/4
        shutterButton.frame = CGRect(x: (view.width-buttonSize)/2, y: view.safeAreaInsets.top + view.width+100, width: buttonSize, height: buttonSize)
        
        shutterButton.layer.cornerRadius = buttonSize/2
        
        photoPickerButton.frame = CGRect(x: shutterButton.right+15, y: shutterButton.bottom-buttonSize/1.5, width: buttonSize/1.5, height: buttonSize/1.5)
    }
    
    @objc func didTapTakePhoto(){
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc func didTapPickPhoto(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    
    private func setUpCamera() {
        captureSession = AVCaptureSession()

        guard let captureSession = self.captureSession else {return}
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            }catch {
                print(error)
            }
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            // Layer
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            camerView.layer.addSublayer(previewLayer)
            captureSession.startRunning()
        }
    }
    
    
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) {
        case .notDetermined:
            // request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            break
        @unknown default:
            break
        }
    }
    
    private func setUpNavBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        
    }
    
    @objc func didTapClose(){
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }

}

extension CameraViewController:AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Camera
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),let image = UIImage(data: data) else {return}
        captureSession?.stopRunning()
        
        guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 640, height: 640), scaleMode: .aspectFill) else {return}
        
        showEditPhoto(image: resizedImage)
    }
    
    // MARK: - Photo Library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        
        guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 640, height: 640), scaleMode: .aspectFill) else {return}
        
        showEditPhoto(image: resizedImage)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func showEditPhoto(image:UIImage) {
        
        let vc = PostEditViewController(image: image)
        if #available(iOS 14.0, *) {
            vc.navigationItem.backButtonDisplayMode = .minimal
        } else {
            // Fallback on earlier versions
            vc.navigationItem.backButtonTitle = ""
        }
        navigationController?.pushViewController(vc, animated: false)
        
    }
    
}
