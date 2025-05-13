//
//  MainViewModel.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/13/25.
//

import Foundation
import RxSwift
import UIKit

class MainViewModel {
    
    // MARK: - Property
    private let myAPI = "aa7f9e6d76e6ca95a3590fef4162a8a9"
    private let disposeBag = DisposeBag()
    
    let searchData = BehaviorSubject(value: [Book]())
    let input = BehaviorSubject<Book?>(value: nil)
    let output: Observable<Book?>
    
    // MARK: - Initialize
    init() {
        output = input
    }
    
    // MARK: - Method
    func searching(search: String) {
        
        guard let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=\(search)") else {
            searchData.onError(NetworkError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(myAPI)"]
        
        NetworkManager.shared.fetchData(request: request)
            .subscribe(onSuccess: { (observer: SearchResponse) in
                self.searchData.onNext(observer.documents)
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
