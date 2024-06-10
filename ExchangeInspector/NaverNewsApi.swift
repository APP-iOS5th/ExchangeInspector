//
//  NaverNewsApi.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/3/24.
//  Naver Api 연결 및 에러 출력

import Foundation
import UIKit

class NaverNewsApi {
    static var shared = NaverNewsApi()
    let jsonDecoder: JSONDecoder = JSONDecoder()
    
    func requestNews(queryValue: String, completion: @escaping ([Item]?) -> Void) {
        let clientID: String = NaverClient().naverClientID
        let clientKey: String = NaverClient().naverClientSecret
        
        let query: String = "https://openapi.naver.com/v1/search/news.json?query=\(queryValue)"
        let encodedQuery: String = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: encodedQuery)!
        
        var requestURL = URLRequest(url: queryURL)
        requestURL.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        requestURL.addValue(clientKey, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let task = URLSession.shared.dataTask(with: requestURL) { data, response, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let searchInfo: News = try self.jsonDecoder.decode(News.self, from: data)
                completion(searchInfo.items)
            } catch {
                print("Error decoding data: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
