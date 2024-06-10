//
//  CountryNewsViewController.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/10/24.
//  나라 별 뉴스 리스트 출력

import UIKit

class CountryNewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var news: [Item] = []
    var queryValue: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "\(queryValue) 뉴스"
        
        setupTableView()
        fetchNews(queryValue: queryValue)
        print("\(queryValue) 뉴스 리스트 출력")
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
    // TODO: - 뉴스 디테일 뷰 -> 웹 뷰
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = UIViewController()
        detailVC.view.backgroundColor = .white
        detailVC.title = "뉴스 상세"
        
        let label = UILabel()
        label.text = news[indexPath.row].description
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        detailVC.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: detailVC.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: detailVC.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: detailVC.view.trailingAnchor, constant: -20)
        ])
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
