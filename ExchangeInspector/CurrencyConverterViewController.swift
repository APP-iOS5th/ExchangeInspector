//
//  CurrencyConverterViewController.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/10/24.
//

import UIKit

class CurrencyConverterViewController: UIViewController, UITextFieldDelegate {
	
	private let baseCurrencyTitleTextField: UITextField = {
		let textField = UITextField()
		textField.text = "클릭하여 국가를 선택 해주세요"
		textField.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		textField.textAlignment = .left
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private var baseCurrencyTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "숫자를 입력해주세요"
		textField.keyboardType = .numberPad
		textField.textAlignment = .right
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "arrowshape.down.fill")
		imageView.tintColor = .black
		imageView.isUserInteractionEnabled = false
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let quoteCurrencyLabel: UILabel = {
		let label = UILabel()
		label.text = "대한민국"
		label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		label.textAlignment = .left
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let quoteCurrencyTextLabel: UILabel = {
		let label = UILabel()
		label.text = "0.0"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	var selectedExchangeRate: ExchangeRate? {
		didSet {
			guard let selectedExchangeRate = selectedExchangeRate else { return }
			baseCurrencyTitleTextField.text = selectedExchangeRate.currencyName
			dealBasR = Double(selectedExchangeRate.rate?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0
			updateLabel()
		}
	}
	
	var dealBasR: Double = 0.0
	
	// MARK: - viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		self.baseCurrencyTextField.delegate = self
		self.baseCurrencyTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
		self.navigationItem.title = "환율 계산기"
	}
	
	// MARK: - Setup Layout
	func setup() {
		baseCurrencyTitleTextField.tintColor = UIColor.clear
		view.addSubview(baseCurrencyTitleTextField)
		view.addSubview(baseCurrencyTextField)
		view.addSubview(imageView)
		view.addSubview(quoteCurrencyLabel)
		view.addSubview(quoteCurrencyTextLabel)
		NSLayoutConstraint.activate([
			baseCurrencyTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
			baseCurrencyTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
			baseCurrencyTextField.topAnchor.constraint(equalTo: baseCurrencyTitleTextField.bottomAnchor, constant: 5),
			baseCurrencyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			imageView.topAnchor.constraint(equalTo: baseCurrencyTextField.bottomAnchor, constant: 20),
			imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			quoteCurrencyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
			quoteCurrencyLabel.leadingAnchor.constraint(equalTo: baseCurrencyTitleTextField.leadingAnchor),
			quoteCurrencyTextLabel.topAnchor.constraint(equalTo: quoteCurrencyLabel.bottomAnchor, constant: 20),
			quoteCurrencyTextLabel.trailingAnchor.constraint(equalTo: baseCurrencyTextField.trailingAnchor)
		])
		
		// 완료 버튼을 추가합니다.
		let toolbar = UIToolbar()
		toolbar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped))
		let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		toolbar.items = [flexibleSpace, doneButton]
		
		baseCurrencyTextField.inputAccessoryView = toolbar
	}
	
	// 완료 버튼이 눌렸을 때 호출되는 메서드
	@objc func doneButtonTapped() {
		view.endEditing(true)
	}
	
	// 텍스트 입력했을 때 처리
	@objc func textFieldDidChange(_ sender: Any?) {
		if baseCurrencyTextField.text == "" {
			baseCurrencyTextField.text = nil
			quoteCurrencyTextLabel.text = "0.0"
		}
		updateLabel()
	}
	
	// Label 업데이트
	func updateLabel() {
		guard let tempString = baseCurrencyTextField.text, let temp = Double(tempString) else {
			return
		}
		self.quoteCurrencyTextLabel.text = String(temp * dealBasR)
	}
}
