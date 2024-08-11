//
//  ExchangeRateService.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/10/24.
//

import Foundation

class ExchangeRateService {
	private let apiService = ExchangeRateAPIService()

	func fetchExchangeRates(apiKey: String, completion: @escaping ([ExchangeRate], [ExchangeRate]) -> Void) {
		let today = getDate(daysAgo: 0)
		let yesterday = getLastBusinessDay()

		var todayRates: [ExchangeRate] = []
		var yesterdayRates: [ExchangeRate] = []

		let group = DispatchGroup()

		group.enter()
		apiService.getExchangeRates(for: today, apiKey: apiKey) { result in
			switch result {
			case .success(let rates):
				todayRates = rates
			case .failure:
				break
			}
			group.leave()
		}

		group.enter()
		apiService.getExchangeRates(for: yesterday, apiKey: apiKey) { result in
			switch result {
			case .success(let rates):
				yesterdayRates = rates
			case .failure:
				break
			}
			group.leave()
		}

		group.notify(queue: .main) {
			completion(todayRates, yesterdayRates)
		}
	}

	private func getDate(daysAgo: Int) -> String {
		let koreanTimeZone = TimeZone(identifier: "Asia/Seoul")!
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = koreanTimeZone
		dateFormatter.dateFormat = "yyyyMMdd"
		let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
		return dateFormatter.string(from: date)
	}

	private func getLastBusinessDay() -> String {
		var date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
		let calendar = Calendar(identifier: .gregorian)
		while isWeekend(date: date) {
			date = calendar.date(byAdding: .day, value: -1, to: date)!
		}
		return getDate(from: date)
	}

	private func isWeekend(date: Date) -> Bool {
		let calendar = Calendar(identifier: .gregorian)
		let components = calendar.dateComponents([.weekday], from: date)
		if let weekday = components.weekday {
			return weekday == 7 || weekday == 1 // Saturday or Sunday
		}
		return false
	}

	private func getDate(from date: Date) -> String {
		let koreanTimeZone = TimeZone(identifier: "Asia/Seoul")!
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = koreanTimeZone
		dateFormatter.dateFormat = "yyyyMMdd"
		return dateFormatter.string(from: date)
	}
}
