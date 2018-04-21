//
//  ApiManager.swift
//  Parking
//
//  Created by Carter Levin on 3/28/18.
//  Copyright © 2018 CEL. All rights reserved.
//

import Foundation



func convertToDictionary(text: String) -> [String: Any]? {
  if let data = text.data(using: .utf8) {
    do {
      return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
      print(error.localizedDescription)
    }
  }
  return nil
}


class ApiManager {
  static let BaseURL = "http://35.185.43.213:8000/"
  class func processImage(imageName: String, success: @escaping ([String : Any]) -> ()) {
    let url = URL(string: ApiManager.BaseURL)!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    let body = ["file_name" : imageName]
    let jsonBody = try? JSONSerialization.data(withJSONObject: body)
    request.httpBody = jsonBody
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
      guard let data = data, error == nil else {                                                 // check for fundamental networking error
        print(error)
        return
      }
      if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
        print("statusCode should be 200, but is \(httpStatus.statusCode)")
        print(response)
      }
      do {
        let dic_data = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        success(dic_data!)
      } catch {
        print(error.localizedDescription)
      }
    }
    task.resume()
  }
}
