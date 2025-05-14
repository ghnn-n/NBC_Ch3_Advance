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

extension Book {
    init(from favorite: FavoriteBook) {
        guard let title = favorite.title,
              let authors = favorite.authors,
        let contents = favorite.contents,
        let thumnail = favorite.thumnail,
        let isbn = favorite.isbn else {
            fatalError("FavoriteBook -> Book 타입 캐스팅 실패")
        }
        self.title = title
        self.price = Int(favorite.price)
        self.authors = authors.components(separatedBy: ", ")
        self.contents = contents
        self.thumbnail = thumnail
        self.isbn = isbn
    }
}
