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
    private var searchData = [Book]()
        
    private lazy var searchBar: UISearchBar = {
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
        
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
        bind()
        // 테스트용
        viewModel.searching(search: "물 만난")
    }
    
}

// MARK: - Method
extension SearchViewController {
    
    private func bind() {
        viewModel.searchData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                self.searchData = data
                self.searchListCollectionView.reloadData()
            }, onError: { error in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    @objc private func getSearch(_ sender: UISearchBar) {
        print("검색")
        view.endEditing(true)
        guard let text = sender.text else { return }
        viewModel.searching(search: text)
    }
    
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
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [searchBar, searchListCollectionView]
            .forEach { view.addSubview($0) }
        
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
    
}

// MARK: - CustomDelegate
extension SearchViewController: CustomDelegate {
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.onNext(self.searchData[indexPath.row])
        self.present(DetailViewController(viewModel: self.viewModel, delegate: self), animated: true)
    }
}

// MARK: - CollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else { return UICollectionReusableView() }
        
        let section = Section.allCases[indexPath.section]
        header.setText(text: section.title)
        
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .history: return self.searchData.count
        case .search: return self.searchData.count
        case .none: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch Section(rawValue: indexPath.section) {
        case .history:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else { return UICollectionViewCell() }
            cell.historySetText(title: "책 이름")
            
            return cell
            
        case .search:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchListCell.identifier, for: indexPath) as? SearchListCell else { return UICollectionViewCell() }
            var author = self.searchData[indexPath.row].authors
            if author.isEmpty { author = ["unknown"] }
            
            cell.searchSetText(title: self.searchData[indexPath.row].title,
                               writer: author.count > 1 ? "\(author[0]) 등 \(author.count)인" : author[0],
                               price: self.searchData[indexPath.row].price)
            
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
