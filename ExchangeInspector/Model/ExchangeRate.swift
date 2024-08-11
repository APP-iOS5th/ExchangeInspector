//
//  ExchangeRate.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/14/24.
//

import Foundation

struct ExchangeRate: Codable {
	let result: Int?  // API 결과 코드
	let currencyCode: String?  // 통화코드
	let currencyName: String?  // 통화이름
	let rate: String?  // 환율
	var changePercentage: String?  // 변동 퍼센트

	enum CodingKeys: String, CodingKey {
		case result = "result"
		case currencyCode = "cur_unit"
		case currencyName = "cur_nm"
		case rate = "deal_bas_r"
		case changePercentage = "yy_efee_r"
	}
}
