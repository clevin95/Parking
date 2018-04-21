//
//  File.swift
//  Parking
//
//  Created by Carter Levin on 3/27/18.
//  Copyright © 2018 CEL. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3

class AwsManager {
  
  class func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  class func generateName() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .medium
    return formatter.string(from: date)
  }
  
  class func sendImage(image: UIImage, success: @escaping (String) -> ()) {
    let reduced: UIImage = image.resized(withPercentage: 0.1 )!
    if let data = UIImagePNGRepresentation(reduced) {
      let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
      try? data.write(to: filename)
      let accessKey = "AKIAJACS3JWHBLW5KX7Q"
      let secretKey = "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"
      let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
      let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
      AWSServiceManager.default().defaultServiceConfiguration = configuration
      let remoteName = generateName()
      let S3BucketName = "parking-signs"
      let uploadRequest = AWSS3TransferManagerUploadRequest()!
      uploadRequest.body = filename
      uploadRequest.key = remoteName
      uploadRequest.bucket = S3BucketName
      uploadRequest.contentType = "image/jpeg"
      uploadRequest.acl = .publicRead
      
      let transferManager = AWSS3TransferManager.default()
      transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
        
        if let error = task.error as? NSError {
          if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
            switch code {
            case .cancelled, .paused:
              break
            default:
              print("Error uploading: \(uploadRequest.key) Error: \(error)")
            }
          } else {
            print("Error uploading: \(uploadRequest.key) Error: \(error)")
          }
          return nil
        }
        
        let uploadOutput = task.result
        success(uploadRequest.key!)
        return nil
      })
    }
  }
}
