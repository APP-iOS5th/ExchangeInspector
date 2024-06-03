//
//  ExchangeRate.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/4/24.
//

struct ExchangeRate: Codable {
	let result: Int?
	let currencyCode: String?
	let currencyName: String?
	let rate: String?
	let change: String?
	let changePercentage: String?

	enum CodingKeys: String, CodingKey {
		case result
		case currencyCode = "cur_unit"
		case currencyName = "cur_nm"
		case rate = "deal_bas_r"
		case change = "bkpr"
		case changePercentage = "yy_efee_r"
	}
}

