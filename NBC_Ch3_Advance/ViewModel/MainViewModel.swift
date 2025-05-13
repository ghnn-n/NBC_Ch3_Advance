//
//  MainViewModel.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/13/25.
//

import Foundation
import KakaoSDKCommon
import RxSwift

class MainViewModel {
    
    private let myAPI = "aa7f9e6d76e6ca95a3590fef4162a8a9"
    private let disposeBag = DisposeBag()
    
    let searchData = BehaviorSubject(value: [Book]())
    
    func searching(search: String) {
        
        guard let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=" + search) else {
            searchData.onError(NetworkError.invalidURL)
            return
        }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK aa7f9e6d76e6ca95a3590fef4162a8a9"]
        
        self.fetch(request: request) { (result: SearchResponse?) in
            guard let result else {
                print(NetworkError.noData)
                return
            }
            
            self.searchData.onNext(result.documents)
        }
        
    }
    
    private func fetch<T: Decodable>(request: URLRequest, completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(nil)
                print(error)
                return
            }
            
            guard let data, let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                completion(nil)
                print(NetworkError.noData)
                return
            }
            
            do {
                let decodingData = try JSONDecoder().decode(T.self, from: data)
                completion(decodingData)
            } catch {
                completion(nil)
                print(NetworkError.decodingFailed)
            }
            
        }.resume()
    }
    
}
