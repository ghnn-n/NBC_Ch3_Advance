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

// MARK: - MainViewModel
class MainViewModel {
    
    // MARK: - Property
    private let myAPI = "aa7f9e6d76e6ca95a3590fef4162a8a9"
    private let disposeBag = DisposeBag()
    
    // ViewModel에서 비즈니스 로직을 실행할 때 필요한 데이터를 담아둠
    // 담은 책
    private var favoriteBookData = [FavoriteBook]()
    // 최근 본 책
    private var historyData = [Book]()
    // 검색 결과
    private var searchData = [Book]()
    // 무한 스크롤에 필요한 페이지 데이터
    private var isEnd = false
    private var page = 1
    private var searchText = ""
    
    // 실제 뷰에서 사용할 프로퍼티
    let searchOutput = BehaviorRelay(value: [Book]())
    let historyOutput = BehaviorRelay(value: [Book]())
    let favoriteOutput = BehaviorRelay(value: [FavoriteBook]())
    let authorOutput = BehaviorRelay(value: ["unknown"])
    let imageOutput = BehaviorRelay(value: UIImage())
    
    // 뷰 간 전송을 위한 input, output
    let input = BehaviorSubject(value: [Book]())
    let output = BehaviorRelay(value: [Book]())
    
    // MARK: - Initialize
    init() {
        // input에 데이터가 들어오면 output에 전송
        input.subscribe(onNext: { data in
            self.output.accept(data)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Method
    // 담은 책을 패치하는 메서드
    func fetchFavorite() {
        self.favoriteBookData = FavoriteBookManager.shared.fetch()
        self.favoriteOutput.accept(self.favoriteBookData)
    }
    
    // 담은 책에서 하나의 컨텐츠만 삭제하는 메서드
    func deleteOneFavorite(indexPath: IndexPath) {
        FavoriteBookManager.shared.deleteOne(item: self.favoriteBookData[indexPath.row].isbn)
        self.favoriteBookData = FavoriteBookManager.shared.fetch()
        self.favoriteOutput.accept(self.favoriteBookData)
    }
    
    // 담은 책을 전체 삭제하는 메서드
    func deleteAllFavorite() {
        FavoriteBookManager.shared.deleteAll()
        self.favoriteBookData = FavoriteBookManager.shared.fetch()
        self.favoriteOutput.accept(self.favoriteBookData)
    }
    
    // 담기 버튼 클릭 시 사용될 비즈니스 로직
    func addCartButtonTapped() -> Bool {
        // 현재 디테일 뷰에 출력된 데이터를 옵셔널 바인딩
        guard let bookData = self.output.value.first else { return false }
        var didAdded: Bool
        
        do {
            // 저장 메서드 실행, 중복 컨텐츠면 throw
            try FavoriteBookManager.shared.create(data: bookData)
            // 정상 처리
            didAdded = true
            
            // 중복 컨텐츠
        } catch CoreDataError.haveSameBook {
            print("같은 책이 있음")
            didAdded = false
            
            // unknownError
        } catch {
            print("unknownError\(error)")
            didAdded = false
        }
        
        // 결과 return
        return didAdded
    }
    
    // 디테일 뷰에서 받아온 정보 변환이 필요한 데이터
    func detailInput() {
        guard let data = self.output.value.first else {
            print("DetailVC.getData(): noDATA")
            return
        }
        
        self.authorOutput.accept(self.authorFetch(data: data))
        self.getImage(url: data.thumbnail)
    }
    
    // 저자 예외처리
    func authorFetch(data: Book) -> [String] {
        
        var authors = data.authors
        if authors.isEmpty { authors = ["unknown"] }
        
        return authors
        
    }
    
    // 이미지 생성
    func getImage(url: String) {
        guard let url = URL(string: url) else {
            print("ViewModel.getImage Error: \(NetworkError.invalidURL)")
            return
        }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else {
                print("ViewModel.getImage Error: \(NetworkError.noData)")
                return
            }
            
            self.imageOutput.accept(image)
        }.resume()
    }
    
    // 검색 결과 셀에서 선택한 데이터를 최근 본 책에 저장하기 위한 메서드
    func historyInput(indexPath: IndexPath) {
        // 최근 본 책이 10개 이상이면 마지막을 삭제
        if self.historyData.count >= 10 {
            self.historyData.removeLast()
        }
        
        // 첫 번째 자리에 인서트
        self.historyData.insert(self.searchOutput.value[indexPath.row], at: 0)
        
        // output에 정보 배출
        self.historyOutput.accept(self.historyData)
    }
    
    /// 검색 로직을 수행하는 메서드:
    /// 검색어, 첫 검색 여부를 인자로 받음.
    /// 첫 검색이 아니라면 검색어는 필요 없음.
    func searching(search: String, isNewSearch: Bool) {
        // 첫 검색일 시 내부 프로퍼티 초기화
        if isNewSearch {
            self.page = 1
            self.isEnd = false
            self.searchText = search
            self.searchData = []
            
            // 첫 검색이 아니라면 다음 페이지를 검색
        } else {
            self.page += 1
        }
        
        // 마지막 페이지라면 메서드를 빠져나옴
        guard !self.isEnd else { return }
        
        // url 설정
        var urlComponent = URLComponents(string: "https://dapi.kakao.com/v3/search/book")
        urlComponent?.queryItems = [URLQueryItem(name: "query", value: self.searchText),
                                    URLQueryItem(name: "page", value: String(page))]
        
        guard let url = urlComponent?.url else {
            print(NetworkError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(myAPI)"]
        
        // 네트워크 매니저 실행
        NetworkManager.shared.fetchData(request: request)
            .subscribe(onSuccess: { (observer: SearchResponse) in
                // 검색 내용을 내부 로직에 append
                self.searchData.append(contentsOf: observer.documents)
                // 마지막 페이지인지 여부 저장
                self.isEnd = observer.meta.isEnd
                
                // output에 배출
                self.searchOutput.accept(self.searchData)
                
            }, onFailure: { error in
                print("MainViewModel.searching error: \(error)")
            }).disposed(by: disposeBag)
        
    }
    
}
