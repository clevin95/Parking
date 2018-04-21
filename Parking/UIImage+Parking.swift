//
//  UIImage+Parking.swift
//  Parking
//
//  Created by Carter Levin on 3/28/18.
//  Copyright © 2018 CEL. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
  func resized(withPercentage percentage: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  func resized(toWidth width: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
