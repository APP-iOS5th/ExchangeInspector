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
		fetchLastValidRates(for: yesterday, apiKey: apiKey) { result in
			switch result {
			case .success(let rates):
				yesterdayRates = rates
			case .failure:
				break
			}
			group.leave()
		}

		group.notify(queue: .main) {
			if todayRates.isEmpty, !yesterdayRates.isEmpty {
				todayRates = yesterdayRates
			}
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

	private func fetchLastValidRates(for date: String, apiKey: String, completion: @escaping (Result<[ExchangeRate], Error>) -> Void) {
		var currentDate = date

		func attemptFetch() {
			apiService.getExchangeRates(for: currentDate, apiKey: apiKey) { result in
				switch result {
				case .success(let rates):
					if rates.isEmpty {
						if let previousDate = self.getPreviousDate(from: currentDate) {
							currentDate = previousDate
							attemptFetch()
						} else {
							completion(.failure(NSError(domain: "NoValidRates", code: -1, userInfo: nil)))
						}
					} else {
						completion(.success(rates))
					}
				case .failure:
					if let previousDate = self.getPreviousDate(from: currentDate) {
						currentDate = previousDate
						attemptFetch()
					} else {
						completion(.failure(NSError(domain: "NoValidRates", code: -1, userInfo: nil)))
					}
				}
			}
		}

		attemptFetch()
	}

	private func getPreviousDate(from dateString: String) -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMdd"
		if let date = dateFormatter.date(from: dateString) {
			let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
			return dateFormatter.string(from: previousDate)
		}
		return nil
	}
}

