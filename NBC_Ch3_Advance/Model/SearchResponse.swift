//
//  SearchResponse.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/13/25.
//

struct SearchResponse: Decodable {
    let documents: [Book]
}

struct Book: Decodable {
    let title: String
    let price: Int
    let authors: [String]
    let contents: String
    let thumbnail: String
    let isbn: String
}
