//
//  ExchangeRateViewController.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/14/24.
//

import UIKit

class ExchangeRateViewController: UIViewController {
	var exchangeRates: [ExchangeRate] = []
	let exchangeRateService = ExchangeRateService()
	let preferredCurrencies = ["USD", "CNH", "JPY(100)", "GBP", "EUR", "HKD"]
	var countdownTimer: Timer?
	var timeRemaining: Int = 300
	
	let exchangeRateView = ExchangeRateView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view = exchangeRateView
		updateData()
		Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
			self?.updateData()
		}
		startCountdownTimer()
	}
	
	func updateData() {
		guard let apiKey = loadAPIKey() else {
			return
		}
		
		exchangeRateService.fetchExchangeRates(apiKey: apiKey) { [weak self] todayRates, yesterdayRates in
			guard let self = self else { return }
			let currentTime = Calendar.current.dateComponents([.hour], from: Date()).hour ?? 0
			if todayRates.isEmpty || currentTime < 11 {
				self.exchangeRates = yesterdayRates.filter { self.preferredCurrencies.contains($0.currencyCode ?? "") }
				DispatchQueue.main.async {
					self.exchangeRateView.messageLabel.isHidden = false
					self.exchangeRateView.messageLabel.text = "비영업일 혹은 영업당일 11시 이전에는 전날 환율이 표시됩니다"
				}
			} else {
				self.exchangeRates = self.compareRates(todayRates: todayRates, yesterdayRates: yesterdayRates)
				DispatchQueue.main.async {
					self.exchangeRateView.messageLabel.isHidden = true
				}
				self.exchangeRates.sort {
					let index1 = self.preferredCurrencies.firstIndex(of: $0.currencyCode ?? "") ?? Int.max
					let index2 = self.preferredCurrencies.firstIndex(of: $1.currencyCode ?? "") ?? Int.max
					return index1 < index2
				}
			}
			DispatchQueue.main.async {
				self.updateExchangeRateView()
				self.resetCountdown()
			}
		}
	}
	
	func loadAPIKey() -> String? {
		guard let filePath = Bundle.main.path(forResource: "API_KEY", ofType: "plist") else {
			return nil
		}
		
		let plist = NSDictionary(contentsOfFile: filePath)
		guard let apiKey = plist?.object(forKey: "API_KEY") as? String else {
			return nil
		}
		
		return apiKey
	}
	
	func compareRates(todayRates: [ExchangeRate], yesterdayRates: [ExchangeRate]) -> [ExchangeRate] {
		var updatedRates: [ExchangeRate] = []
		
		for todayRate in todayRates {
			guard let cleanedCode = todayRate.currencyCode?.trimmingCharacters(in: .whitespacesAndNewlines) else {
				continue
			}
			if preferredCurrencies.contains(cleanedCode) {
				if let yesterdayRate = yesterdayRates.first(where: { $0.currencyCode == todayRate.currencyCode }) {
					if let todayRateValue = Double(todayRate.rate?.replacingOccurrences(of: ",", with: "") ?? ""),
					   let yesterdayRateValue = Double(yesterdayRate.rate?.replacingOccurrences(of: ",", with: "") ?? "") {
						let changePercentage = calculateChangePercentage(todayRate: todayRateValue, yesterdayRate: yesterdayRateValue)
						var updatedRate = todayRate
						updatedRate.changePercentage = changePercentage
						updatedRates.append(updatedRate)
					}
				}
			}
		}
		
		updatedRates.sort {
			let index1 = preferredCurrencies.firstIndex(of: $0.currencyCode ?? "") ?? Int.max
			let index2 = preferredCurrencies.firstIndex(of: $1.currencyCode ?? "") ?? Int.max
			return index1 < index2
		}
		
		return updatedRates
	}
	
	func calculateChangePercentage(todayRate: Double, yesterdayRate: Double) -> String {
		let change = ((todayRate - yesterdayRate) / yesterdayRate) * 100
		return String(format: "%.2f", change) + "%"
	}
	
	func updateExchangeRateView() {
		exchangeRateView.exchangeRateStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
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
			
			let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
			chevron.translatesAutoresizingMaskIntoConstraints = false
			button.addSubview(chevron)
			
			NSLayoutConstraint.activate([
				chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -20),
				chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor)
			])
			
			exchangeRateView.exchangeRateStackView.addArrangedSubview(button)
			
			button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		}
	}
	
	@objc func buttonTapped(_ sender: UIButton) {
		guard let buttonIndex = exchangeRateView.exchangeRateStackView.arrangedSubviews.firstIndex(of: sender) else {
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
	
	func startCountdownTimer() {
		countdownTimer?.invalidate()
		countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
	}
	
	@objc func updateCountdown() {
		if timeRemaining > 0 {
			timeRemaining -= 1
			let minutes = timeRemaining / 60
			let seconds = timeRemaining % 60
			exchangeRateView.countdownLabel.text = String(format: "갱신까지 남은 시간: %02d:%02d", minutes, seconds)
		} else {
			timeRemaining = 300
			updateData()
		}
	}
	
	func resetCountdown() {
		timeRemaining = 300
	}
}
