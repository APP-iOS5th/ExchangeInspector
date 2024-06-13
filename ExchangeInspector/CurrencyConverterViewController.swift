//
//  CurrencyConverterViewController.swift
//  ExchangeInspector
//
//  Created by Yachae on 6/10/24.
//

import UIKit




class CurrencyConverterViewController: UIViewController {
     
     private let titleLebel: UILabel = {
        let label = UILabel()
          label.text = "환율 계산기"
          label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
          label.translatesAutoresizingMaskIntoConstraints = false
          label.textColor = .label
          return label
          }()
     
     private let baseCurrencyTitleTextField: UITextField = {
          let textField = UITextField()
          textField.text = "글씨를 클릭하여 국가를 선택 해주세요"
          textField.font = UIFont.systemFont(ofSize: 20)
          textField.textAlignment = .left
          textField.translatesAutoresizingMaskIntoConstraints = false
          textField.textColor = .systemBlue
          
          return textField
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
          label.font = UIFont.systemFont(ofSize: 20)
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
     
     // 카운트다운을 표시하는 레이블
     var countdownLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont.systemFont(ofSize: 14)
          label.translatesAutoresizingMaskIntoConstraints = false
          label.textColor = .secondaryLabel
          return label
     }()
     
     let apiService = ExchangeRateAPIService()
     var exchangeRateList: [ExchangeRate] = []
     var dealBasR: Double = 1
     var countdownTimer: Timer?  // 카운트다운 타이머
     var timeRemaining: Int = 300  // 남은 시간 (5분)

     
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
          self.navigationItem.title = "환율 계산기"
          
          Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
               self?.getExchangeRates()
          }
          startCountdownTimer()
     }
     
     
     var selectedExchangeRate: ExchangeRate? {
          didSet {
               guard let selectedExchangeRate = selectedExchangeRate else { return }
               baseCurrencyTitleTextField.text = selectedExchangeRate.currencyName
               dealBasR = Double(selectedExchangeRate.rate?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0
               updateLabel()
          }
     }
     
     //MARK: - func
     
     
     func getExchangeRates() {
          guard let apiKey = loadAPIKey() else {
               print("API key not found")
               return
          }
          print("API Key not found")
          let today = getDate(daysAgo: 0)
          apiService.getExchangeRates(for: today, apiKey:apiKey) { response in
               
               switch response {
               case .success(let exchangeRate):
                    self.exchangeRateList = exchangeRate
                     
               case .failure(let exchangeRate):
                    print("fail", exchangeRate)
               }
               
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
     
     // 레이아웃 처리
     func setup() {
          baseCurrencyTitleTextField.tintColor = UIColor.clear
          view.addSubview(titleLebel)
          view.addSubview(baseCurrencyTitleTextField)
          view.addSubview(baseCurrencyTextField)
          view.addSubview(imageView)
          view.addSubview(quoteCurrencyLabel)
          view.addSubview(quoteCurrencyTextLabel)
          view.addSubview(countdownLabel)
          
          baseCurrencyTextField.sizeToFit()
          quoteCurrencyTextLabel.sizeToFit()
          NSLayoutConstraint.activate([
               
               titleLebel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
               titleLebel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               
               // baseCurrencyLabel
               baseCurrencyTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
               baseCurrencyTitleTextField.topAnchor.constraint(equalTo: titleLebel.bottomAnchor, constant: 40),
               
               // baseCurrencyTextFile
               baseCurrencyTextField.topAnchor.constraint(equalTo: baseCurrencyTitleTextField.bottomAnchor, constant: 30),
               baseCurrencyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20),
               baseCurrencyTextField.leadingAnchor.constraint(equalTo: baseCurrencyTitleTextField.leadingAnchor),
               
               
               // imageView
               imageView.topAnchor.constraint(equalTo: baseCurrencyTextField.bottomAnchor, constant:  20),
               imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               
               // quoteCurrencyLabel
               quoteCurrencyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
               quoteCurrencyLabel.leadingAnchor.constraint(equalTo: baseCurrencyTitleTextField.leadingAnchor),
               
               // quoteCurrencyTextLabel
               quoteCurrencyTextLabel.topAnchor.constraint(equalTo: quoteCurrencyLabel.bottomAnchor, constant: 20),
               quoteCurrencyTextLabel.trailingAnchor.constraint(equalTo: baseCurrencyTextField.trailingAnchor),
               
               
               countdownLabel.topAnchor.constraint(equalTo: quoteCurrencyTextLabel.bottomAnchor, constant:  50),
               countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               
               
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
               getExchangeRates()
          }
     }

     // 카운트다운 초기화
     func resetCountdown() {
          timeRemaining = 300
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
          
          return exchangeRateList[row].currencyName
     }
     
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
          baseCurrencyTitleTextField.text = exchangeRateList[row].currencyName
          dealBasR = stringToDouble(exchangeRateList[row].rate!)
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
