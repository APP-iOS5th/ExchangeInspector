//
//  ExchangeRateView.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/14/24.
//

import UIKit

class ExchangeRateView: UIView {
	let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "오늘의 환율"
		label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .label
		return label
	}()
	
	let countdownLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 14)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .secondaryLabel
		return label
	}()
	
	let exchangeRateStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 10
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	let messageLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12)
		label.textColor = .systemRed
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupViews()
	}
	
	private func setupViews() {
		backgroundColor = .systemBackground
		
		let headerStackView = UIStackView(arrangedSubviews: [titleLabel, countdownLabel])
		headerStackView.axis = .horizontal
		headerStackView.spacing = 10
		headerStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(headerStackView)
		
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(scrollView)
		
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		
		contentView.addSubview(exchangeRateStackView)
		contentView.addSubview(messageLabel)
		
		NSLayoutConstraint.activate([
			headerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
			headerStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 40),
			headerStackView.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
			
			scrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 20),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
			
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			exchangeRateStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			exchangeRateStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
			exchangeRateStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
			messageLabel.topAnchor.constraint(equalTo: exchangeRateStackView.bottomAnchor, constant: 10),
			messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
		])
	}
}
