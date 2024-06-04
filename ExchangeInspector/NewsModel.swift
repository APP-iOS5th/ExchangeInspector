//
//  NewsModel.swift
//  ExchangeInspector
//
//  Created by 황승혜 on 6/3/24.
//  뉴스 관련 구조체

import Foundation

// MARK: - News
struct News: Codable {
    let lastBuildDate: String
    let total, start, display: Int
    let items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let title: String
    let originallink: String
    let link: String
    let description, pubDate: String
}
