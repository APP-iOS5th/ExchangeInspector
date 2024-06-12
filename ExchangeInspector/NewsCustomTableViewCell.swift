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
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            pubDateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            pubDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pubDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pubDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with item: Item) {
        titleLabel.text = removeTag(from: item.title)
        descriptionLabel.text = removeTag(from: item.description)
        pubDateLabel.text = dateFormatChanger(date: item.pubDate)
    }
    
    // MARK: - 날짜 형식 변환 함수
    func dateFormatChanger(date: String) -> String {
        let rfcDateString = date // api에서 받아온 날짜 형식: RFC822
        
        // RFC822 형식의 DateFormatter
        let rfcDateFormatter = DateFormatter()
        rfcDateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        rfcDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // 입력 문자열을 Date 객체로 변환
        if let newDate = rfcDateFormatter.date(from: rfcDateString) {
            // 변환된 Date 객체를 새로운 형식의 문자열로 변환하기 위한 DateFormatter
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            newDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Date 객체를 새로운 형식의 문자열로 변환
            let newDateString = newDateFormatter.string(from: newDate)
            
            return newDateString// 수정
        } else {
            print("Failed to convert date string")
        }
        return ""
    }
    
    // MARK: - HTML 태그 제거 함수
    private func removeTag(from tag: String) -> String {
        let pattern = "<.*?>|&quot;|&lt;|&gt|&amp;|R&amp;D"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: tag.utf16.count)
        return regex.stringByReplacingMatches(in: tag, options: [], range: range, withTemplate: "")
    }
}
