//
//  CurrencyConverterViewController.swift
//  ExchangeInspector
//
//  Created by 어재선 on 6/3/24.
//

import UIKit




class CurrencyConverterViewController: UIViewController {
    
    
    private let baseCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = "미국"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var baseCurrencyTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "1"
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
        label.text = "text"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    var exchangeRateList: [ExchangeRate] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getExchangeRates()
        self.baseCurrencyTextField.addTarget(self, action: #selector(self.textFieldDidchange(_:)), for: .editingChanged)
    }
    
    func getExchangeRates() {
        ApiService.shared.fetchExchangeRates { response in
            
            switch response {
            case .success(let exchangeRate) :
                if let decodeData = exchangeRate as? [ExchangeRate] {
                    self.exchangeRateList = decodeData
                    
                    DispatchQueue.main.async {
                        
                    }
                    return
                }
            case .failure(let exchangeRate):
                print("fail", exchangeRate)
            }
            
        }
        
    }
    
    func setup() {
        view.addSubview(baseCurrencyLabel)
        view.addSubview(baseCurrencyTextField)
        view.addSubview(imageView)
        view.addSubview(quoteCurrencyLabel)
        view.addSubview(quoteCurrencyTextLabel)
        NSLayoutConstraint.activate([
            
            // baseCurrencyLabel
            baseCurrencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            baseCurrencyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // baseCurrencyTextFile
            baseCurrencyTextField.topAnchor.constraint(equalTo: baseCurrencyLabel.bottomAnchor, constant: 5),
            baseCurrencyTextField.leadingAnchor.constraint(equalTo: baseCurrencyLabel.leadingAnchor),
            
            // imageView
            imageView.topAnchor.constraint(equalTo: baseCurrencyTextField.bottomAnchor, constant:  20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // quoteCurrencyLabel
            quoteCurrencyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            quoteCurrencyLabel.leadingAnchor.constraint(equalTo: baseCurrencyLabel.leadingAnchor),
            
            // quoteCurrencyTextLabel
            quoteCurrencyTextLabel.topAnchor.constraint(equalTo: quoteCurrencyLabel.bottomAnchor, constant: 20),
            quoteCurrencyTextLabel.leadingAnchor.constraint(equalTo: baseCurrencyLabel.leadingAnchor),
            
        ])
        
        
    }
    
    @objc func textFieldDidchange(_ sender: Any?) {
        self.quoteCurrencyTextLabel.text = self.baseCurrencyTextField.text
    }
    
}
