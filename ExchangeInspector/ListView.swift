//
//  ListView.swift
//  환율 리스트 뷰
//
//  Created by 한상현 on 6/3/24.
//

import UIKit

// MARK: - DataModel
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
				
				// 응답이 빈 배열인지 확인
				if jsonString == "[]" {
					print("API response is an empty array")
					completion(.success([]))
					return
				}
				
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

// MARK: - ViewController
class ListView: UIViewController {
	var exchangeRates: [ExchangeRate] = []  // 환율 데이터 배열
	let exchangeRateService = ExchangeRateService()  // 환율 서비스 인스턴스
	let preferredCurrencies = ["USD", "CNH", "JPY(100)", "GBP", "EUR", "HKD"]  // 선호하는 통화 목록
	var countdownTimer: Timer?  // 카운트다운 타이머
	var countdownLabel: UILabel!  // 카운트다운을 표시하는 레이블
	var timeRemaining: Int = 300  // 남은 시간 (5분)

	let exchangeRateView = UIStackView()  // 환율 데이터를 표시하는 스택뷰

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground

		let titleLabel = UILabel()
		titleLabel.text = "오늘의 환율"
		titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
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

	// API 키를 로드하고 데이터를 업데이트함
	func updateData() {
		guard let apiKey = loadAPIKey() else {
			print("API Key not found")
			return
		}
		print("Loaded API Key: \(apiKey)")

		exchangeRateService.fetchExchangeRates(apiKey: apiKey) { [weak self] todayRates, yesterdayRates in
			guard let self = self else { return }
			let currentTime = Calendar.current.dateComponents([.hour], from: Date()).hour ?? 0
			if todayRates.isEmpty || currentTime < 11 {
				print("오늘의 환율 데이터가 비어 있거나 현재 시간이 오전 11시 이전이므로 어제의 데이터를 사용합니다")
				self.exchangeRates = yesterdayRates.filter { self.preferredCurrencies.contains($0.currencyCode ?? "") }
			} else {
				self.exchangeRates = self.compareRates(todayRates: todayRates, yesterdayRates: yesterdayRates)
			}
			self.exchangeRates.sort {
				let index1 = self.preferredCurrencies.firstIndex(of: $0.currencyCode ?? "") ?? Int.max
				let index2 = self.preferredCurrencies.firstIndex(of: $1.currencyCode ?? "") ?? Int.max
				return index1 < index2
			}
			DispatchQueue.main.async {
				self.updateExchangeRateView()
				self.resetCountdown()
			}
		}
	}


	// MARK: - API Key Loading
	// API 키 로드하는 함수
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
	// 오늘과 어제의 환율 데이터를 비교하여 변동 퍼센트를 계산함
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

		// preferredCurrencies 배열의 순서대로 정렬함
		updatedRates.sort {
			let index1 = preferredCurrencies.firstIndex(of: $0.currencyCode ?? "") ?? Int.max
			let index2 = preferredCurrencies.firstIndex(of: $1.currencyCode ?? "") ?? Int.max
			return index1 < index2
		}

		print("Updated rates count: \(updatedRates.count)")
		for rate in updatedRates {
			print("Updated rate: \(rate.currencyCode ?? "N/A"), Change: \(rate.changePercentage ?? "N/A")")
		}

		return updatedRates
	}

	// 변동 퍼센트를 계산함
	func calculateChangePercentage(todayRate: Double, yesterdayRate: Double) -> String {
		let change = ((todayRate - yesterdayRate) / yesterdayRate) * 100
		return String(format: "%.2f", change) + "%"
	}

	// MARK: - Exchange Rate View Update
	// 환율 데이터를 뷰에 업데이트함
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
			let changePercentageString = "\(rate.changePercentage ?? "N/A")"

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

	// 버튼을 눌렀을 때 시트로 환율 계산기 표시
	@objc func buttonTapped(_ sender: UIButton) {
		guard let buttonIndex = exchangeRateView.arrangedSubviews.firstIndex(of: sender) else {
			return
		}
		let selectedExchangeRate = exchangeRates[buttonIndex]
		
		let sheetViewController = CurrencyConverterViewController()
		sheetViewController.selectedExchangeRate = selectedExchangeRate
		sheetViewController.view.backgroundColor = .systemBackground

		if let sheetController = sheetViewController.sheetPresentationController {
			sheetController.detents = [.large()]
			sheetController.prefersEdgeAttachedInCompactHeight = true
		}

		present(sheetViewController, animated: true)
	}

	// MARK: - Countdown Timer
	// 카운트다운 타이머 시작
	func startCountdownTimer() {
		countdownTimer?.invalidate()
		countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
	}

	// 카운트다운 업데이트
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

	// 카운트다운 초기화
	func resetCountdown() {
		timeRemaining = 300
	}
}
