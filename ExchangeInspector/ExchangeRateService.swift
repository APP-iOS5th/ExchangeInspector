//
//  ExchangeRateService.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/4/24.
//

import Foundation
import Moya

class ExchangeRateService {
	let provider = MoyaProvider<ExchangeRateAPI>()
	
	func fetchExchangeRates(authKey: String, searchDate: String, data: String, completion: @escaping ([ExchangeRate]?) -> Void) {
		provider.request(.getExchangeRates(authKey: authKey, searchDate: searchDate, data: data)) { result in
			switch result {
			case .success(let response):
				do {
					let responseData = String(data: response.data, encoding: .utf8)
					print("Response Data: \(responseData ?? "No data")")
					
					let exchangeRates = try JSONDecoder().decode([ExchangeRate].self, from: response.data)
					completion(exchangeRates)
				} catch {
					print("Error decoding: \(error)")
					completion(nil)
				}
			case .failure(let error):
				print("Error: \(error)")
				completion(nil)
			}
		}
	}
}

