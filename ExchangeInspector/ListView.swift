//
//  ListView.swift
//  환율 리스트 뷰
//
//  Created by 한상현 on 6/3/24.
//

import UIKit

// MARK: - DataModel
struct ExchangeRate: Codable {
	let result: Int?
	let currencyCode: String? // 통화코드
	let currencyName: String? // 통화이름
	let rate: String?
	var changePercentage: String?

	enum CodingKeys: String, CodingKey {
		case result = "result"
		case currencyCode = "cur_unit"
		case currencyName = "cur_nm"
		case rate = "deal_bas_r"
		case changePercentage = "yy_efee_r"
	}
}

// MARK: - API Service
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

		print("Request URL: \(url.absoluteString)")

		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("API request failed: \(error)")
				completion(.failure(error))
				return
			}

			guard let data = data else {
				print("No data received")
				completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
				return
			}

			do {
				let jsonString = String(data: data, encoding: .utf8)
				print("Response JSON: \(jsonString ?? "No data")")
				let exchangeRates = try JSONDecoder().decode([ExchangeRate].self, from: data)
				completion(.success(exchangeRates))
			} catch {
				print("Failed to decode response: \(error)")
				completion(.failure(error))
			}
		}

		task.resume()
	}
}

// MARK: - Exchange Rate Service
class ExchangeRateService {
	private let apiService = ExchangeRateAPIService()

	func fetchExchangeRates(apiKey: String, completion: @escaping ([ExchangeRate], [ExchangeRate]) -> Void) {
		let today = getDate(daysAgo: 0)
		let yesterday = getDate(daysAgo: 1)

		print("Fetching exchange rates for today: \(today) and yesterday: \(yesterday)")

		var todayRates: [ExchangeRate] = []
		var yesterdayRates: [ExchangeRate] = []

		let group = DispatchGroup()

		group.enter()
		apiService.getExchangeRates(for: today, apiKey: apiKey) { result in
			switch result {
			case .success(let rates):
				print("Successfully fetched today's rates")
				todayRates = rates
			case .failure(let error):
				print("Failed to fetch today's rates: \(error)")
			}
			group.leave()
		}

		group.enter()
		apiService.getExchangeRates(for: yesterday, apiKey: apiKey) { result in
			switch result {
			case .success(let rates):
				print("Successfully fetched yesterday's rates")
				yesterdayRates = rates
			case .failure(let error):
				print("Failed to fetch yesterday's rates: \(error)")
			}
			group.leave()
		}

		group.notify(queue: .main) {
			print("Today rates count: \(todayRates.count), Yesterday rates count: \(yesterdayRates.count)")
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
}

// MARK: - ViewController
class ListView: UIViewController {
	var exchangeRates: [ExchangeRate] = []
	let exchangeRateService = ExchangeRateService()
	let preferredCurrencies = ["USD", "CNH", "JPY(100)", "GBP", "EUR", "HKD"]
	var countdownTimer: Timer?
	var countdownLabel: UILabel!
	var timeRemaining: Int = 300 // 5분
	
	let exchangeRateView = UIStackView()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground

		let titleLabel = UILabel()
		titleLabel.text = "오늘의 환율"
		titleLabel.font = UIFont.systemFont(ofSize: 30)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .label

		countdownLabel = UILabel()
		countdownLabel.font = UIFont.systemFont(ofSize: 14)
		countdownLabel.translatesAutoresizingMaskIntoConstraints = false
		countdownLabel.textColor = .secondaryLabel

		let headerStackView = UIStackView(arrangedSubviews: [titleLabel, countdownLabel])
		headerStackView.axis = .horizontal
		headerStackView.spacing = 10
		headerStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerStackView)

		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)

		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)

		exchangeRateView.axis = .vertical
		exchangeRateView.spacing = 10
		exchangeRateView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(exchangeRateView)

		NSLayoutConstraint.activate([
			headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			headerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
			headerStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),

			scrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 20),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

			exchangeRateView.topAnchor.constraint(equalTo: contentView.topAnchor),
			exchangeRateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
			exchangeRateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
			exchangeRateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
		])

		updateData()
		Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
			self?.updateData()
		}
		startCountdownTimer()
	}

	func updateData() {
		guard let apiKey = loadAPIKey() else {
			print("API Key not found")
			return
		}
		print("Loaded API Key: \(apiKey)")
		
		exchangeRateService.fetchExchangeRates(apiKey: apiKey) { [weak self] todayRates, yesterdayRates in
			guard let self = self else { return }
			self.exchangeRates = self.compareRates(todayRates: todayRates, yesterdayRates: yesterdayRates)
			DispatchQueue.main.async {
				self.updateExchangeRateView()
				self.resetCountdown()
			}
		}
	}

	// MARK: - API Key Loading
	func loadAPIKey() -> String? {
		guard let filePath = Bundle.main.path(forResource: "API_KEY", ofType: "plist") else {
			print("Couldn't find file 'API_KEY.plist'.")
			return nil
		}

		let plist = NSDictionary(contentsOfFile: filePath)
		guard let apiKey = plist?.object(forKey: "API_KEY") as? String else {
			print("Couldn't find key 'API_KEY' in 'API_KEY.plist'.")
			return nil
		}

		return apiKey
	}

	// MARK: - Rate Comparison
	func compareRates(todayRates: [ExchangeRate], yesterdayRates: [ExchangeRate]) -> [ExchangeRate] {
		var updatedRates: [ExchangeRate] = []

		for todayRate in todayRates {
			print("Processing today rate: \(todayRate.currencyCode ?? "N/A")")
			guard let cleanedCode = todayRate.currencyCode?.trimmingCharacters(in: .whitespacesAndNewlines) else {
				print("Skipping due to invalid code")
				continue
			}
			if preferredCurrencies.contains(cleanedCode) {
				print("Preferred currency found: \(cleanedCode)")
				if let yesterdayRate = yesterdayRates.first(where: { $0.currencyCode == todayRate.currencyCode }) {
					print("Found yesterday's rate for currency: \(cleanedCode)")
					print("Today's rate: \(todayRate.rate ?? "N/A"), Yesterday's rate: \(yesterdayRate.rate ?? "N/A")")
					if let todayRateValue = Double(todayRate.rate?.replacingOccurrences(of: ",", with: "") ?? "") {
						if let yesterdayRateValue = Double(yesterdayRate.rate?.replacingOccurrences(of: ",", with: "") ?? "") {
							print("Valid rate values for currency: \(cleanedCode)")
							let changePercentage = calculateChangePercentage(todayRate: todayRateValue, yesterdayRate: yesterdayRateValue)
							var updatedRate = todayRate
							updatedRate.changePercentage = changePercentage
							updatedRates.append(updatedRate)
						} else {
							print("Invalid yesterday rate value for currency: \(cleanedCode)")
						}
					} else {
						print("Invalid today rate value for currency: \(cleanedCode)")
					}
				} else {
					print("Yesterday's rate not found for currency: \(cleanedCode)")
				}
			} else {
				print("Not a preferred currency: \(cleanedCode)")
			}
		}

		// preferredCurrencies 배열의 순서대로 정렬
		updatedRates.sort { preferredCurrencies.firstIndex(of: $0.currencyCode ?? "") ?? Int.max < preferredCurrencies.firstIndex(of: $1.currencyCode ?? "") ?? Int.max }

		print("Updated rates count: \(updatedRates.count)")
		for rate in updatedRates {
			print("Updated rate: \(rate.currencyCode ?? "N/A"), Change: \(rate.changePercentage ?? "N/A")")
		}

		return updatedRates
	}

	func calculateChangePercentage(todayRate: Double, yesterdayRate: Double) -> String {
		let change = ((todayRate - yesterdayRate) / yesterdayRate) * 100
		return String(format: "%.2f", change) + "%"
	}

	// MARK: - Exchange Rate View Update
	func updateExchangeRateView() {
		exchangeRateView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for rate in exchangeRates {
			let button = UIButton(type: .system)
			button.layer.borderWidth = 1
			button.layer.borderColor = UIColor.systemGray4.cgColor
			button.layer.cornerRadius = 8
			button.titleLabel?.numberOfLines = 0
			button.contentHorizontalAlignment = .leading

			var config = UIButton.Configuration.plain()
			config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
			button.configuration = config

			let attributedTitle = NSMutableAttributedString()

			let currencyNameAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
				.foregroundColor: UIColor.label
			]
			let currencyName = NSAttributedString(string: "\(rate.currencyCode ?? "N/A") \(rate.currencyName ?? "Unknown") \n", attributes: currencyNameAttributes)
			attributedTitle.append(currencyName)

			let rateValueAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .regular),
				.foregroundColor: UIColor.label
			]
			let rateValue = NSAttributedString(string: "\(rate.rate ?? "N/A") 원", attributes: rateValueAttributes)
			attributedTitle.append(rateValue)

			let changeSign = rate.changePercentage?.starts(with: "-") ?? false ? "▼" : "▲"
			let changeColor = rate.changePercentage?.starts(with: "-") ?? false ? UIColor.systemBlue : UIColor.systemRed
			let changePercentageString = "\(rate.changePercentage ?? "N/A")%"

			let changeValueAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 14, weight: .regular),
				.foregroundColor: changeColor
			]
			let changeValue = NSAttributedString(string: "\n\(changeSign) \(changePercentageString)", attributes: changeValueAttributes)
			attributedTitle.append(changeValue)

			button.setAttributedTitle(attributedTitle, for: .normal)

			exchangeRateView.addArrangedSubview(button)

			button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		}
	}

	@objc func buttonTapped(_ sender: UIButton) {
		let sheetViewController = UIViewController()
		sheetViewController.view.backgroundColor = .systemBackground
		sheetViewController.title = "환율 정보"

		if let sheetController = sheetViewController.sheetPresentationController {
			sheetController.detents = [.large()]
			sheetController.prefersEdgeAttachedInCompactHeight = true
		}

		present(sheetViewController, animated: true)
	}

	// MARK: - Countdown Timer
	func startCountdownTimer() {
		countdownTimer?.invalidate()
		countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
	}

	@objc func updateCountdown() {
		if timeRemaining > 0 {
			timeRemaining -= 1
			let minutes = timeRemaining / 60
			let seconds = timeRemaining % 60
			countdownLabel.text = String(format: "갱신까지 남은 시간: %02d:%02d", minutes, seconds)
		} else {
			timeRemaining = 300
			updateData()
		}
	}

	func resetCountdown() {
		timeRemaining = 300
	}
}
