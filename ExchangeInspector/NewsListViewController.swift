//
//  NewsListViewController.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/3/24.
//  세번째 탭(뉴스) 화면 구현

import UIKit

class NewsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private let newsCountryListView = UIStackView()
    private var queryValue: String = "" // 검색 쿼리에 넣을 문자열
    private var news: [Item] = []
    var listCountries: [String] = ["미국", "일본", "유럽연합", "중국", "영국", "호주", "홍콩"] // 환율 리스트에 출력되는 국가들(추후 수정)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        titleLabel.text = "뉴스"
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        view.addSubview(titleLabel)
        
        newsCountryListView.axis = .vertical
        newsCountryListView.alignment = .fill
        newsCountryListView.distribution = .fillEqually
        newsCountryListView.spacing = 10
        newsCountryListView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newsCountryListView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
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
                self.queryValue = country
            }, for: .touchUpInside)
            button.addAction(UIAction(handler: buttonTapped), for: .touchUpInside)
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -16)
        ])
        
        return button
    }
    
    private func buttonTapped(_ action: UIAction) {
        // TODO: - 뒤로가기 버튼, 출력 뉴스 개수 조정, 새로고침 기능
        setupTableView()
        fetchNews(queryValue: queryValue)
    }
    
    // 뉴스 출력 테이블 뷰
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsCustomTableViewCell.self, forCellReuseIdentifier: "newsCell")
    }
    
    private func fetchNews(queryValue: String) {
        NaverNewsApi.shared.requestNews(queryValue: "\(queryValue) 경제, 금융") { [weak self] items in
            DispatchQueue.main.async {
                self?.news = items ?? []
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView Data Sources
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCustomTableViewCell else {
            return UITableViewCell()
        }
        let newsItem = news[indexPath.row]
        cell.configure(with: newsItem)
        return cell
    }
    // TODO: - 뉴스 디테일 뷰
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let detailVC = NewsDetailViewController()
//    }
}
