//
//  NewsListViewController.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/3/24.
//  세번째 탭(뉴스) 화면 구현

import UIKit

class NewsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var news: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.backgroundColor = .white
        setupTableView()
        fetchNews()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsCustomTableViewCell.self, forCellReuseIdentifier: "newsCell")
    }
    
    private func fetchNews() {
        NaverNewsApi.shared.requestNews(queryValue: "글로벌 경제") { [weak self] items in
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
