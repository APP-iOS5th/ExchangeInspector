//
//  CurrencyConverterViewController.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/10/24.
//

import UIKit




class CurrencyConverterViewController: UIViewController {
    
    
    private let baseCurrencyTitleTextField: UITextField = {
        let testField = UITextField()
        testField.text = "글씨를 클릭하여 국가를 선택 해주세요"
        testField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        testField.textAlignment = .left
        testField.translatesAutoresizingMaskIntoConstraints = false
        testField.textColor = .systemBlue
        return testField
    }()
    
    private var baseCurrencyTextField:UITextField = {
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
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let quoteCurrencyTextLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        return label
        
    }()
    
    
    
    private var pickerview = UIPickerView()
    
    let charSet: CharacterSet = {
        var cs = CharacterSet.lowercaseLetters
        cs.insert(charactersIn: "0123456789")
        cs.insert(charactersIn: "-")
        return cs.inverted
    }()
    
    var exchangeRateList: [ExchangeRate] = []
    var dealBasR: Double = 1
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        pickerview.delegate = self
        pickerview.dataSource = self
        getExchangeRates()
        self.hideKeyboardwhenTappedAround()
        baseCurrencyTitleTextField.inputView = pickerview
        self.baseCurrencyTextField.addTarget(self, action: #selector(self.textFieldDidchange(_:)), for: .editingChanged)
    }
    
    
    
    //MARK: - func
    func getExchangeRates() {
        ApiService.shared.fetchExchangeRates { response in
            
            switch response {
            case .success(let exchangeRate) :
                if let decodeData = exchangeRate as? [ExchangeRate] {
                    self.exchangeRateList = decodeData
                    return
                }
            case .failure(let exchangeRate):
                print("fail", exchangeRate)
            }
            
        }
    }
    
    // 레이아웃 처리
    func setup() {
        baseCurrencyTitleTextField.tintColor = UIColor.clear
        view.addSubview(baseCurrencyTitleTextField)
        view.addSubview(baseCurrencyTextField)
        view.addSubview(imageView)
        view.addSubview(quoteCurrencyLabel)
        view.addSubview(quoteCurrencyTextLabel)
        
        baseCurrencyTextField.sizeToFit()
        quoteCurrencyTextLabel.sizeToFit()
        NSLayoutConstraint.activate([
            
            // baseCurrencyLabel
            baseCurrencyTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            baseCurrencyTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // baseCurrencyTextFile
            baseCurrencyTextField.topAnchor.constraint(equalTo: baseCurrencyTitleTextField.bottomAnchor, constant: 20),
            baseCurrencyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20),
            
            // imageView
            imageView.topAnchor.constraint(equalTo: baseCurrencyTextField.bottomAnchor, constant:  20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // quoteCurrencyLabel
            quoteCurrencyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            quoteCurrencyLabel.leadingAnchor.constraint(equalTo: baseCurrencyTitleTextField.leadingAnchor),
            
            // quoteCurrencyTextLabel
            quoteCurrencyTextLabel.topAnchor.constraint(equalTo: quoteCurrencyLabel.bottomAnchor, constant: 20),
            quoteCurrencyTextLabel.trailingAnchor.constraint(equalTo: baseCurrencyTextField.trailingAnchor),
            
        ])
        
        
    }
    
    //텍스트 입력했을때 처리
    @objc func textFieldDidchange(_ sender: Any?) {
    if baseCurrencyTextField.text == "" {
            baseCurrencyTextField.text = nil
            quoteCurrencyTextLabel.text = "0.00"
        }
                updateLabel()
    }
    
    // 문자열  -> Double
    func stringToDouble(_ doubleString: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: doubleString) {
            let doubleValue = number.doubleValue
            print(doubleValue)
            return doubleValue
        }
        return 0.0
    }
    
    
    // label upDate
    func updateLabel() {
        guard let tempString = baseCurrencyTextField.text else {
            return
        }
        
        guard let temp = Double(tempString) else {
            return
        }
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result:String = numberFormatter.string(from: (temp * dealBasR) as NSNumber)!
        
        self.quoteCurrencyTextLabel.text = result
    }
    
    
}

// UIPicker
extension CurrencyConverterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exchangeRateList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return exchangeRateList[row].cur_nm
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        baseCurrencyTitleTextField.text = exchangeRateList[row].cur_nm
        dealBasR = stringToDouble(exchangeRateList[row].deal_bas_r)
        baseCurrencyTitleTextField.resignFirstResponder()
        updateLabel()
    }
}

// 숫자만 입력 가능하게
extension CurrencyConverterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 0 { //입력모드에서만 실행
            guard string.rangeOfCharacter(from: charSet) == nil else {
                return false
            }
        }
        
        return true
    }
    
}


extension CurrencyConverterViewController {
    
    func hideKeyboardwhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CurrencyConverterViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
