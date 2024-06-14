//
//  NewsListViewController.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/3/24.
//  세번째 탭(뉴스) 나라 목록 구현

import UIKit

class NewsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private var tableViewHeightConstraint: NSLayoutConstraint?
    var listCountries: [String] = ["대한민국", "미국", "중국", "일본", "영국", "유럽연합", "홍콩"] // 환율 리스트에 출력되는 국가들

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        titleLabel.text = "국가 목록"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        view.addSubview(titleLabel)
        
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemGray4.cgColor
        tableView.layer.cornerRadius = 8
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "countryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -18),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            //tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // 높이 제약 조건 저장
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        // 높이 조절
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "contentSize" {
                if let newSize = change?[.newKey] as? CGSize {
                    tableViewHeightConstraint?.constant = newSize.height
                }
            }
        }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        let country = listCountries[indexPath.row]
        cell.textLabel?.text = country
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCountries.count
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = listCountries[indexPath.row]
        let newsVC = CountryNewsViewController()
        newsVC.queryValue = country
        self.navigationController?.pushViewController(newsVC, animated: true)
        print("\(newsVC.queryValue) 선택")
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
}
