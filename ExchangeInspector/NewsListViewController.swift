//
//  NewsListViewController.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/3/24.
//  세번째 탭(뉴스) 나라 목록 구현

import UIKit

class NewsListViewController: UIViewController {
    private let titleLabel = UILabel()
    private let newsCountryListView = UIStackView()
    var listCountries: [String] = ["대한민국", "미국", "중국", "일본", "영국", "유럽연합", "홍콩"] // 환율 리스트에 출력되는 국가들

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        titleLabel.text = "국가"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        view.addSubview(titleLabel)
        
        newsCountryListView.axis = .vertical
        newsCountryListView.alignment = .fill
        newsCountryListView.distribution = .equalSpacing
        newsCountryListView.spacing = 10
        newsCountryListView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newsCountryListView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -18),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            newsCountryListView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            newsCountryListView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            newsCountryListView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30)
        ])
        
        // 국가 리스트 버튼
        for country in listCountries {
            let button = createCustomButton(with: country)
            newsCountryListView.addArrangedSubview(button)
            
            button.addAction(UIAction { _ in
                let newsVC = CountryNewsViewController()
                newsVC.queryValue = country
                self.navigationController?.pushViewController(newsVC, animated: true)
                print("\(newsVC.queryValue) 선택")
            }, for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
                button.widthAnchor.constraint(equalTo: newsCountryListView.widthAnchor)
            ])
        }
    }
    
    private func createCustomButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .leading
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(imageView)
        
        // 버튼에 스택 뷰 추가
        button.addSubview(stackView)
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -16)
        ])
        
        return button
    }
}
