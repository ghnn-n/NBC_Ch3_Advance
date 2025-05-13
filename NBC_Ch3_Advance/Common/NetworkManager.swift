//
//  NetworkManager.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/13/25.
//

import Foundation
import RxSwift

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchData<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { observer in
            let session = URLSession(configuration: .default)
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                
                if let error {
                    return observer(.failure(error))
                }
                
                guard let data, let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                    return observer(.failure(NetworkError.noData))
                }
                
                do {
                    let decodingData = try JSONDecoder().decode(T.self,
                                                                from: data)
                    return observer(.success(decodingData))
                } catch {
                    return observer(.failure(NetworkError.decodingFailed))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}

enum NetworkError: Error {
    case invalidURL, decodingFailed, noData
}
