//
//  APIService.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/12/06.
//

import Foundation
import SwiftyJSON
import Alamofire

class APIService {
  static let shared = APIService()
  typealias CompletionHandler = (Int, JSON) -> ()

  func fetchCafeInfo(pos: (x: Double, y: Double), query: String, result: @escaping CompletionHandler) {
    let url = "https://dapi.kakao.com/v2/local/search/keyword.json"

    let header: HTTPHeaders = [
      "Authorization": Bundle.main.apiKey,
      "Content-Type": "multipart/form-data"
    ]
    
    let params: Parameters = [
      "x": "\(pos.x)",
      "y": "\(pos.y)",
      "radius": 20000,
      "query": query,
      "category_group_code": "CE7"
    ]
    
    AF.request(
      url,
      method: .get,
      parameters: params, headers: header).validate(statusCode: 200...500).responseJSON { response in
      switch response.result {
      case .success(let value):
        let json = JSON(value)
        let code = response.response?.statusCode ?? 500
        result(code, json)
        
      case .failure(let error):
        print("ERROR: \(error)")
      }
    }
  }
}
