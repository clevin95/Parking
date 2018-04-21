//
//  ViewController.swift
//  Camera
//
//  Created by Rizwan on 16/06/17.
//  Copyright © 2017 Rizwan. All rights reserved.
//
import UIKit
import AVFoundation
import SnapKit
import NVActivityIndicatorView

class ViewController: UIViewController {
  let ButtonWidth = 65.0
  var previewView: UIView = UIView()
  var previewLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textColor = UIColor.green
    label.isHidden = true
    return label
  }()
  var captureButton: BaseButton = BaseButton()
  var buttonBorder: UIView = UIView()
  var messageLabel: UILabel = UILabel()
  var loadingView: NVActivityIndicatorView = {
    return NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballClipRotatePulse, color: .red, padding: 0.0)
  }()
  var captureSession: AVCaptureSession?
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var capturePhotoOutput: AVCapturePhotoOutput?
  var qrCodeFrameView: UIView?
  func setUpConstraints() {
    previewView.snp.makeConstraints({(make) -> Void in
      make.edges.equalTo(self.view)
    })
    captureButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view).inset(30.0)
      make.height.width.equalTo(ButtonWidth)
      make.centerX.equalTo(self.view)
    }
    buttonBorder.snp.makeConstraints { (make) in
      make.edges.equalTo(captureButton).inset(-5)
    }
    previewLabel.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    loadingView.snp.makeConstraints { (make) in
      make.edges.equalTo(captureButton).inset(-20)
    }
  }
  
  func setUpViews() {
    captureButton.backgroundColor = UIColor.gray
    captureButton.alpha = 0.3
    captureButton.addTarget(self, action: #selector(onTapTakePhoto), for: UIControlEvents.touchUpInside)
    captureButton.layer.cornerRadius = CGFloat(ButtonWidth / 2.0)
    buttonBorder.backgroundColor = UIColor.clear
    buttonBorder.layer.cornerRadius = captureButton.layer.cornerRadius + 5
    buttonBorder.layer.borderWidth = 3
    buttonBorder.layer.borderColor = UIColor.gray.cgColor
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(previewView)
    view.addSubview(buttonBorder)
    view.addSubview(captureButton)
    view.addSubview(messageLabel)
    view.addSubview(previewLabel)
    view.addSubview(loadingView)
    setUpViews()
    setUpConstraints()
    captureButton.clipsToBounds = true
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter
    guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
      fatalError("No vidoe device found")
    }
    
    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      // Initialize the captureSession object
      captureSession = AVCaptureSession()
      
      // Set the input devcie on the capture session
      captureSession?.addInput(input)
      
      // Get an instance of ACCapturePhotoOutput class
      capturePhotoOutput = AVCapturePhotoOutput()
      capturePhotoOutput?.isHighResolutionCaptureEnabled = true
      
      // Set the output on the capture session
      captureSession?.addOutput(capturePhotoOutput!)
      
      // Initialize a AVCaptureMetadataOutput object and set it as the input device
      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession?.addOutput(captureMetadataOutput)
      
      // Set delegate and use the default dispatch queue to execute the call back
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
      
      //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      previewView.layer.addSublayer(videoPreviewLayer!)
      
      //start video capture
      captureSession?.startRunning()
      
      messageLabel.isHidden = true
      
      //Initialize QR Code Frame to highlight the QR code
      qrCodeFrameView = UIView()
      
      if let qrCodeFrameView = qrCodeFrameView {
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        view.bringSubview(toFront: qrCodeFrameView)
      }
    } catch {
      //If any error occurs, simply print it out
      print(error)
      return
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    videoPreviewLayer?.frame = view.bounds
    if let previewLayer = videoPreviewLayer ,(previewLayer.connection?.isVideoOrientationSupported)! {
      previewLayer.connection?.videoOrientation = UIApplication.shared.statusBarOrientation.videoOrientation ?? .portrait
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc func onTapTakePhoto() {
    // Make sure capturePhotoOutput is valid
    guard let capturePhotoOutput = self.capturePhotoOutput else { return }
    
    // Get an instance of AVCapturePhotoSettings class
    let photoSettings = AVCapturePhotoSettings()
    
    // Set photo settings for our need
    photoSettings.isAutoStillImageStabilizationEnabled = true
    photoSettings.isHighResolutionPhotoEnabled = true
    photoSettings.flashMode = .auto
    
    // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
    capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
  }
  
  func updateWithResponse(jsonResponse: [String : Any]) {
    endLoading()
    if (jsonResponse["red"] as? [AnyObject])?.count == 0 && (jsonResponse["green"] as? [AnyObject])?.count == 0 {
      // Show error if no signs were detected
      showRetry()
    } else {
      let status = SignContoller.checkSigns(signs: jsonResponse as! [String : [[String : NSObject]]])
      if status == 0 {
        showNotPermitted()
      } else if status == 1 {
        
      } else if status == 2 {
        showPermitted()
      }
    }
    // This is for debugging
    previewLabel.text = String(describing: jsonResponse)
  }
  
  // MARK: - Loading helpers
  func startLoading() {
    buttonBorder.isHidden = true
    captureButton.isHidden = true
    loadingView.startAnimating()
  }
  
  func endLoading() {
    buttonBorder.isHidden = false
    captureButton.isHidden = false
    loadingView.stopAnimating()
  }
  
  // MARK: - Success failure helpers
  func showPermitted() {
    let alertView = SCLAlertView()
    alertView.showSuccess("You can park!")
  }
  
  func showPermittedWithMeter() {
    let alertView = SCLAlertView()
    alertView.showSuccess("You can park!", subTitle: "Make sure to pay the meter!")
  }
  
  func showNotPermitted() {
    let alertView = SCLAlertView()
    alertView.showError("Looks like you can't park right now ):")
  }
  
  func showRetry() {
    let alertView = SCLAlertView()
    alertView.showWarning("Something Went Wrong", subTitle: "Try getting closer to the sign and taking another picture")
  }
}

extension ViewController : AVCapturePhotoCaptureDelegate {
  func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                   didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                   previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                   resolvedSettings: AVCaptureResolvedPhotoSettings,
                   bracketSettings: AVCaptureBracketedStillImageSettings?,
                   error: Error?) {
    // Make sure we get some photo sample buffer
    guard error == nil,
      let photoSampleBuffer = photoSampleBuffer else {
        print("Error capturing photo: \(String(describing: error))")
        return
    }
    
    // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
    guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
      return
    }
    
    // Initialise an UIImage with our image data
    let capturedImage = UIImage.init(data: imageData , scale: 1.0)
    startLoading()
    previewLabel.text = ""
    if let image = capturedImage {
      //TO DO: send to server
      AwsManager.sendImage(image: image, success: { (image_name) in
        ApiManager.processImage(imageName: image_name, success: { (response_json) in
          DispatchQueue.main.async {
            self.updateWithResponse(jsonResponse: response_json)
          }
        })
      })
    }
  }
}

extension ViewController : AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection) {
    // Check if the metadataObjects array is contains at least one object.
    if metadataObjects.count == 0 {
      qrCodeFrameView?.frame = CGRect.zero
      messageLabel.isHidden = true
      return
    }
    
    // Get the metadata object.
    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
    if metadataObj.type == AVMetadataObject.ObjectType.qr {
      // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
      let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
      qrCodeFrameView?.frame = barCodeObject!.bounds
      
      if metadataObj.stringValue != nil {
        messageLabel.isHidden = false
        messageLabel.text = metadataObj.stringValue
      }
    }
  }
}

extension UIInterfaceOrientation {
  var videoOrientation: AVCaptureVideoOrientation? {
    switch self {
    case .portraitUpsideDown: return .portraitUpsideDown
    case .landscapeRight: return .landscapeRight
    case .landscapeLeft: return .landscapeLeft
    case .portrait: return .portrait
    default: return nil
    }
  }
}
