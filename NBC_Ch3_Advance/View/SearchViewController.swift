//
//  ViewController.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import SnapKit
import RxSwift

// MARK: - SearchViewController
class SearchViewController: UIViewController {
    
    // MARK: - Property
    private let disposeBag = DisposeBag()
    private let viewModel = MainViewModel()
    
    // MARK: - UI Property
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색할 책 제목"
        searchBar.searchTextField.addTarget(self, action: #selector(getSearch), for: .primaryActionTriggered)
        
        return searchBar
    }()
    
    private lazy var searchListCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: setCollectionViewLayoutForSection())
        collectionView.register(SearchListCell.self, forCellWithReuseIdentifier: SearchListCell.identifier)
        collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: HistoryCell.identifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
}

// MARK: - Lifecycle
extension SearchViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
}

// MARK: - Method
extension SearchViewController {
    
    // ViewModel 바인딩
    private func bind() {
        viewModel.searchOutput
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                self.searchListCollectionView.reloadData()
            }, onError: { error in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    // 서치바에서 리턴 입력 시
    @objc private func getSearch(_ sender: UISearchBar) {
        DispatchQueue.global(qos: .default).sync {
            self.searchListCollectionView.scrollsToTop = true
            view.endEditing(true)
            
            guard let text = sender.text else { return }
            viewModel.searching(search: text, isNewSearch: true)
        }
    }
    
    // 섹션 별 레이아웃 적용
    private func setCollectionViewLayoutForSection() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .history: return self.historySectionLayout()
            case .search: return self.searchSectionLayout(environment: environment)
            }
        }
        
        return layout
    }
    
    // 최근 본 책 섹션 레이아웃
    private func historySectionLayout() -> NSCollectionLayoutSection {
        let itemwidth = self.searchListCollectionView.bounds.width / 5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemwidth),
                                              heightDimension: .absolute(itemwidth))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // 동그란 모양 = (top + bottom) == (leading + trailing)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
        
        // (item의 height) + (inset의 top + bottom)
        let height = itemSize.heightDimension.dimension + (item.contentInsets.top + item.contentInsets.bottom)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(height))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        // 최근 본 책이 있을 때만 헤더를 생성
        if !self.viewModel.historyOutput.value.isEmpty {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [header]
        }
        
        return section
    }
    
    // 검색 결과 섹션 레이아웃
    private func searchSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        config.headerMode = .supplementary
        
        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
        section.interGroupSpacing = 5
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // UI 세팅 메서드
    private func setupUI() {
        view.backgroundColor = .white
        
        [searchBar, searchListCollectionView]
            .forEach { view.addSubview($0) }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        searchBar.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        searchListCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    // 화면 클릭 시 키보드가 내려가도록 설정
    @objc private func closeKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - CustomDelegate
extension SearchViewController: CustomDelegate {
    
    // 디테일 뷰에서 담기 버튼 클릭 시
    func didFinishedAddBook(was success: Bool) {
            let alert = UIAlertController(title: success ? "성공!" : "실패",
                                          message: success ? "담기를 완료했습니다." : "같은 책이 이미 담겨 있습니다.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: true)
    }
}

// MARK: - CollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    
    // 셀의 아이템 클릭 시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 최근 본 책
        let historyData = self.viewModel.historyOutput.value
        // 검색 결과
        let searchData = self.viewModel.searchOutput.value
        
        // 디테일 뷰로 이동 - ViewModel 넘겨줌, Delegate 설정
        let detailVC = DetailViewController(viewModel: self.viewModel)
        detailVC.delegate = self
        self.present(detailVC, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .history:
            // 디테일 뷰에서 클릭한 셀의 정보를 볼 수 있도록 input을 보냄
            self.viewModel.input.onNext([historyData[indexPath.row]])
        case .search:
            // 최근 본 책에 표시될 수 있도록 historyInput에 기록 추가
            self.viewModel.historyInput(indexPath: indexPath)
            self.searchListCollectionView.reloadData()
            // 디테일 뷰에서 클릭한 셀의 정보를 볼 수 있도록 input을 보냄
            self.viewModel.input.onNext([searchData[indexPath.row]])
        case .none:
            return
        }
    }
    
    // 스크롤이 멈췄을 때
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 현재 위치
        let nowY = scrollView.contentOffset.y
        // 모든 컨텐츠의 길이
        let fullHeight = scrollView.contentSize.height
        // 컬렉션 뷰? 스크롤 뷰?의 UI상 높이
        let frameHeight = scrollView.frame.height
        
        // 현재 위치 > 총 스크롤 가능한 길이에서 컬렉션 뷰 UI의 길이를 뺀 값
        if nowY > fullHeight - frameHeight - 10 { // 오차 10
            // ViewModel에 새로운 검색이 아니라는 정보와 함께 검색 요청
            viewModel.searching(search: "", isNewSearch: false)
        }
    }
}

// MARK: - CollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    
    // SupplementaryElement
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else { return UICollectionReusableView() }
        
        let section = Section.allCases[indexPath.section]
        header.setText(text: section.title)
        
        return header
    }
    
    // 섹션 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    // 섹션 당 셀의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .history: return self.viewModel.historyOutput.value.count
        case .search: return self.viewModel.searchOutput.value.count
        case .none: return 0
        }
    }
    
    // 셀 표시 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch Section(rawValue: indexPath.section) {
        case .history:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else { return UICollectionViewCell() }
            
            // 최근 본 책
            let historyData = self.viewModel.historyOutput.value
            
            cell.historySetText(title: historyData[indexPath.row].title)
            
            return cell
            
        case .search:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchListCell.identifier, for: indexPath) as? SearchListCell else { return UICollectionViewCell() }
            
            // 검색 결과
            let searchData = self.viewModel.searchOutput.value
            
            // 저자 예외처리
            let author = self.viewModel.authorFetch(data: searchData[indexPath.row])
            
            cell.searchSetText(title: searchData[indexPath.row].title,
                               // 저자 예외처리
                               writer: author.count > 1 ? "\(author[0]) 등 \(author.count)인" : author[0],
                               price: searchData[indexPath.row].price)
            
            return cell
            
        case .none:
            return UICollectionViewCell()
        }
        
    }
}

// MARK: - CaseIterable
enum Section: Int, CaseIterable {
    case history
    case search
    
    var title: String {
        switch self {
        case .history: return "최근 본 책"
        case .search: return "검색 결과"
        }
    }
}
