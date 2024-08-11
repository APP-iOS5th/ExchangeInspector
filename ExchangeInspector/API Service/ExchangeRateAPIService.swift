//
//  ExchangeRateAPIService.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/14/24.
//

import Foundation

class ExchangeRateAPIService {
	func getExchangeRates(for date: String, apiKey: String, completion: @escaping (Result<[ExchangeRate], Error>) -> Void) {
		guard var urlComponents = URLComponents(string: "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON") else {
			completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
			return
		}
		
		urlComponents.queryItems = [
			URLQueryItem(name: "authkey", value: apiKey),
			URLQueryItem(name: "searchdate", value: date),
			URLQueryItem(name: "data", value: "AP01")
		]
		
		guard let url = urlComponents.url else {
			completion(.failure(NSError(domain: "InvalidURLComponents", code: -1, userInfo: nil)))
			return
		}
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
				return
			}
			
			do {
				let jsonString = String(data: data, encoding: .utf8)
				
				if jsonString == "[]" {
					completion(.success([]))
					return
				}
				
				let exchangeRates = try JSONDecoder().decode([ExchangeRate].self, from: data)
				completion(.success(exchangeRates))
			} catch {
				completion(.failure(error))
			}
		}
		
		task.resume()
	}
}
