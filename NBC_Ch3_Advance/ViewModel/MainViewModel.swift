//
//  MainViewModel.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/13/25.
//

import Foundation
import RxSwift
import UIKit
import RxRelay

class MainViewModel {
    
    // MARK: - Property
    private let myAPI = "aa7f9e6d76e6ca95a3590fef4162a8a9"
    private let disposeBag = DisposeBag()
    private var historyData = [Book]()
    private var searchData = [Book]()
    private var isEnd = false
    private var page = 1
    private var searchText = ""
    
    let searchOutput = BehaviorRelay(value: [Book]())
    let historyOutput = BehaviorRelay(value: [Book]())
    
    let input = BehaviorSubject(value: [Book]())
    var output: Observable<[Book]>
    
    // MARK: - Initialize
    init() {
        output = input
    }
    
    // MARK: - Method
    func historyInput(indexPath: IndexPath) {
        if self.historyData.count >= 10 { self.historyData.removeLast() }
        
        self.historyData.insert(self.searchOutput.value[indexPath.row], at: 0)
        
        self.historyOutput.accept(self.historyData)
    }
    
    func searching(search: String, isNewSearch: Bool) {
        if isNewSearch {
            self.page = 1
            self.isEnd = false
            self.searchText = search
            self.searchData = []
        } else {
            self.page += 1
        }
        
        guard !self.isEnd else { return }
        
        var urlComponent = URLComponents(string: "https://dapi.kakao.com/v3/search/book")
        urlComponent?.queryItems = [URLQueryItem(name: "query", value: searchText),
                                    URLQueryItem(name: "page", value: String(page))]
        
        guard let url = urlComponent?.url else {
            print(NetworkError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(myAPI)"]
        
        NetworkManager.shared.fetchData(request: request)
            .subscribe(onSuccess: { (observer: SearchResponse) in
                self.searchData.append(contentsOf: observer.documents)
                self.isEnd = observer.meta.isEnd
                
                self.searchOutput.accept(self.searchData)
                
            }, onFailure: { error in
                print("MainViewModel.searching error: \(error)")
            }).disposed(by: disposeBag)
        
    }
    
    func getImage(url: String) -> Single<UIImage> {
        guard let url = URL(string: url) else {
            return Single.error(NetworkError.invalidURL)
        }
        
        return Single.create { observer in
            let session = URLSession(configuration: .default)
            session.dataTask(with: URLRequest(url: url)) { data, _, _ in
                guard let data, let image = UIImage(data: data) else {
                    return observer(.failure(NetworkError.noData))
                }
                
                return observer(.success(image))
            }.resume()
            return Disposables.create()
        }
    }
    
}
