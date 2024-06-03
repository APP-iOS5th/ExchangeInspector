//
//  ListView.swift
//  환율 리스트 뷰
//
//  Created by 한상현 on 6/3/24.
//

import UIKit

class ListView: UIViewController {
	var exchangeRates: [ExchangeRate] = []
	let exchangeRateService = ExchangeRateService()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		
		let titleLabel = UILabel()
		titleLabel.text = "오늘의 환율"
		titleLabel.font = UIFont.systemFont(ofSize: 24)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .label
		view.addSubview(titleLabel)
		
		let exchangeRateView = UIStackView()
		exchangeRateView.axis = .vertical
		exchangeRateView.spacing = 10
		exchangeRateView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(exchangeRateView)
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			exchangeRateView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
			exchangeRateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
			exchangeRateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
		])
		
		guard let authKey = loadAPIKey() else {
			print("API Key not found")
			return
		}
		
		let searchDate = "20230601" // 예시 날짜
		let data = "AP01"
		
		fetchExchangeRates(authKey: authKey, searchDate: searchDate, data: data) { [weak self] rates in
			self?.exchangeRates = rates ?? []
			DispatchQueue.main.async {
				self?.updateExchangeRateView(exchangeRateView)
			}
		}
	}
	
	func loadAPIKey() -> String? {
		guard let filePath = Bundle.main.path(forResource: "API_KEY", ofType: "plist") else {
			fatalError("Couldn't find file 'API_KEY.plist'.")
		}
		
		let plist = NSDictionary(contentsOfFile: filePath)
		guard let apiKey = plist?.object(forKey: "API_KEY") as? String else {
			fatalError("Couldn't find key 'API_KEY' in 'API_KEY.plist'.")
		}
		
		return apiKey
	}
	
	func fetchExchangeRates(authKey: String, searchDate: String, data: String, completion: @escaping ([ExchangeRate]) -> Void) {
		exchangeRateService.fetchExchangeRates(authKey: authKey, searchDate: searchDate, data: data) { rates in
			completion(rates ?? [])
		}
	}
	
	func updateExchangeRateView(_ exchangeRateView: UIStackView) {
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
			let currencyName = NSAttributedString(string: "\(rate.currencyName ?? "Unknown") \(rate.currencyCode ?? "N/A")\n", attributes: currencyNameAttributes)
			attributedTitle.append(currencyName)
			
			let rateValueAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .regular),
				.foregroundColor: UIColor.label
			]
			let rateValue = NSAttributedString(string: "\(rate.rate ?? "N/A") 원", attributes: rateValueAttributes)
			attributedTitle.append(rateValue)
			
			let changeSign = rate.change?.starts(with: "-") ?? false ? "▼" : "▲"
			let changeColor = rate.change?.starts(with: "-") ?? false ? UIColor.systemBlue : UIColor.systemRed
			let changePercentageString = "\(rate.changePercentage ?? "N/A")%"
			
			let changeValueAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 14, weight: .regular),
				.foregroundColor: changeColor
			]
			let changeValue = NSAttributedString(string: "\n\(changeSign) \(rate.change ?? "N/A") \(changePercentageString)", attributes: changeValueAttributes)
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
}
