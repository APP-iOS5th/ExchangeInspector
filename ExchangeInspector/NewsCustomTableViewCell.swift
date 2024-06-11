//
//  NewsCustomTableViewCell.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/4/24.
//  뉴스 테이블 셀

import UIKit

class NewsCustomTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let pubDateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 2
        pubDateLabel.font = UIFont.systemFont(ofSize: 12)
        pubDateLabel.textColor = .lightGray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(pubDateLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        pubDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            pubDateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            pubDateLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            pubDateLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            pubDateLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with item: Item) {
        titleLabel.text = removeTag(tag: item.title)
        descriptionLabel.text = removeTag(tag: item.description)
        pubDateLabel.text = item.pubDate
    }
    
    // MARK: - HTML 태그 제거 함수
    func removeTag(tag: String) -> String {
        var removeB = tag.replacingOccurrences(of: "<b>", with: "")
        var removeB2 = removeB.replacingOccurrences(of: "</b>", with: "")
        var removeQuot = removeB2.replacingOccurrences(of: "&quot;", with: "")
        var removeLT = removeQuot.replacingOccurrences(of: "&lt;", with: "")
        var removeGT = removeLT.replacingOccurrences(of: "&gt;", with: "")
        var removeA = removeGT.replacingOccurrences(of: "&amp;", with: "")
        var removeAll = removeA.replacingOccurrences(of: "R&amp;D", with: "")
        
        return removeAll
    }
}
