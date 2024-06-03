//
//  ExchangeRateAPI.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/4/24.
//

import Foundation
import Moya

enum ExchangeRateAPI {
	case getExchangeRates(authKey: String, searchDate: String, data: String)
}

extension ExchangeRateAPI: TargetType {
	var baseURL: URL {
		return URL(string: "https://www.koreaexim.go.kr")!
	}
	
	var path: String {
		switch self {
		case .getExchangeRates:
			return "/site/program/financial/exchangeJSON"
		}
	}
	
	var method: Moya.Method {
		return .get
	}
	
	var task: Task {
		switch self {
		case .getExchangeRates(let authKey, let searchDate, let data):
			return .requestParameters(parameters: ["authkey": authKey, "searchdate": searchDate, "data": data], encoding: URLEncoding.default)
		}
	}
	
	var headers: [String: String]? {
		return ["Content-type": "application/json"]
	}
	
	var sampleData: Data {
		return Data()
	}
}
