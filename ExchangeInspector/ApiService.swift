//
//  ApiManger.swift
//  ExchangeInspector
//
//  Created by 어재선 on 6/9/24.
//

import UIKit

struct ExchangeRateModel: Codable {
    let exchangeRates: [ExchangeRate]
}

struct ExchangeRate: Codable {

    let cur_unit: String
    let deal_bas_r: String
    let cur_nm: String
}
struct ApiService{
    static let shared = ApiService()
    let url = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON?"
    let apiKey = "dNbyuQOGbYXb26ido5zgI1Y8luD43iAZ"
    let searchdate = "20240607"
    // AP01 : 환율 AP02 : 대출금리 AP03 : 국제금리
    let data = "AP01"
    
    func fetchExchangeRates(completion: @escaping (Result<Any, Error>) -> ()) {
        let urlString = "\(url)authkey=\(apiKey)&searchdate=\(searchdate)&data=\(data)"
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print(error!)
                return
            }
            
            // 에러가 발생하지 않다면 if let 구문으로 들어와 data (옵셔널 데이터)를 언래핑 하게 된다.
            if let safeData = data {
                do{
                    let decodeData = try JSONDecoder().decode(ExchangeRateModel.self, from: safeData)
                    completion(.success(decodeData))
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        }
        
        task.resume()
        }
            
    }

    
    
}
