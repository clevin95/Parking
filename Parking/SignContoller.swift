//
//  SignContoller.swift
//  Parking
//
//  Created by Carter Levin on 4/18/18.
//  Copyright © 2018 CEL. All rights reserved.
//

import UIKit

class SignContoller: NSObject {
  
  class func checkOverlap(sign: [String : AnyObject]) -> Bool {
    print(sign)
    let date = Date()
    let myCalendar = Calendar(identifier: .gregorian)
    let weekday = myCalendar.component(.weekday, from: date)
    let hour = myCalendar.component(.hour, from: date)
    if let dates: [[String : AnyObject]] = sign["dates"] as? [[String : AnyObject]] {
      for date in dates {
        if let days: [Int] = date["days"] as? [Int] {
          if days.contains(weekday) {
            if let hours: [[String : Int]] = date["hours"] as? [[String : Int]] {
              for span in hours {
                guard span["begin"] != nil || span["end"] != nil else {continue}
                let start: Int = span["begin"]!
                let end: Int = span["end"]!
                if hour >= start && hour < end {
                  return true
                }
              }
            }
          }
        }
      }
    }
    return false
  }
  
  // Check if current date overlaps with current date
  // Return 0 if no parking 1 if parking with meter and 2 if no meter
  class func checkSigns(signs: [String: [[String : NSObject]]]) -> Int {
    let redSigns = signs["red"]!
    // Check if parking is not allowed
    for sign in redSigns {
      if checkOverlap(sign: sign) {return 0}
    }
    // Check if metered parking
    let greenSigns = signs["green"]!
    for sign in greenSigns {
      if checkOverlap(sign: sign) {return 1}
    }
    return 2
  }
  
  
}
