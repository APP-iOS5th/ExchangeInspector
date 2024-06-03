//
//  ListView.swift
//  환율 리스트 뷰
//
//  Created by 한상현 on 6/3/24.
//

import UIKit

struct ExchangeRate {
	let currencyCode: String
	let currencyName: String
	let rate: Double
	let change: Double
	let changePercentage: Double
}

class ListView: UIViewController {
	
	var exchangeRates: [ExchangeRate] = [
		ExchangeRate(currencyCode: "USD", currencyName: "미국", rate: 1378.50, change: 7.50, changePercentage: 0.55),
		ExchangeRate(currencyCode: "JPY", currencyName: "일본", rate: 878.39, change: -0.92, changePercentage: -1.04),
		ExchangeRate(currencyCode: "EUR", currencyName: "유럽연합", rate: 1489.47, change: -8.72, changePercentage: -0.59),
		ExchangeRate(currencyCode: "CNY", currencyName: "중국", rate: 189.82, change: 1.34, changePercentage: 0.71),
		ExchangeRate(currencyCode: "GBP", currencyName: "영국", rate: 1750.70, change: -9.46, changePercentage: -0.54),
		ExchangeRate(currencyCode: "AUD", currencyName: "호주", rate: 910.84, change: -4.47, changePercentage: -0.49),
		ExchangeRate(currencyCode: "HKD", currencyName: "홍콩", rate: 176.11, change: -1.01, changePercentage: -0.57)
	]
	
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
		
		// 리스트구현
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
			let currencyName = NSAttributedString(string: "\(rate.currencyName) \(rate.currencyCode)\n", attributes: currencyNameAttributes)
			attributedTitle.append(currencyName)
			
			let rateValueAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .regular),
				.foregroundColor: UIColor.label
			]
			let rateValue = NSAttributedString(string: rate.rate.formatted(.currency(code: rate.currencyCode)), attributes: rateValueAttributes)
			attributedTitle.append(rateValue)
			
			// 환율 변동 설정
			let changeSign = rate.change >= 0 ? "▲" : "▼"
			let changeColor = rate.change >= 0 ? UIColor.systemRed : UIColor.systemBlue
			let changePercentageString = abs(rate.changePercentage).formatted(.percent.precision(.fractionLength(2)))
			
			let changeValueAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 14, weight: .regular),
				.foregroundColor: changeColor
			]
			let changeValue = NSAttributedString(string: "\n\(changeSign)\(abs(rate.change).formatted(.number.precision(.fractionLength(2)))) \(changePercentageString)", attributes: changeValueAttributes)
			attributedTitle.append(changeValue)
			
			button.setAttributedTitle(attributedTitle, for: .normal)
			
			exchangeRateView.addArrangedSubview(button)
			
			button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		}
	}
	
	// 환율리스트 버튼 동작
	@objc func buttonTapped(_ sender: UIButton) {
		let sheetViewController = UIViewController()
		sheetViewController.view.backgroundColor = .systemBackground
		sheetViewController.title = "시트 제목"
		
		if let sheetController = sheetViewController.sheetPresentationController {
			sheetController.detents = [.large()]
			sheetController.prefersEdgeAttachedInCompactHeight = true
		}
		
		present(sheetViewController, animated: true)
	}
}
