//
//  MyBookViewController.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import RxSwift
import SnapKit

// MARK: - MyBookViewController
class MyBookViewController: UIViewController {
    
    // MARK: - Property
    private let horizontalEdgesInset: CGFloat = 20
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Property
    private lazy var deleteAllButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setTitle("전체 삭제", for: .normal)
        button.setTitleColor(.gray, for: .normal)
    
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.green, for: .normal)
        
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "담은 책"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.register(SearchListCell.self, forCellWithReuseIdentifier: SearchListCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
}

// MARK: - Lifecycle
extension MyBookViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        self.viewModel.fetchFavorite()
    }
    
}

// MARK: - Method
extension MyBookViewController {
    
    // ViewModel 바인딩
    private func bind() {
        self.viewModel.favoriteOutput
            .subscribe(onNext: { data in
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    // 버튼 클릭
    @objc private func buttonTapped(_ sender: UIButton) {
        
        // 전체 삭제 버튼
        if sender == self.deleteAllButton {
            self.viewModel.deleteAllFavorite()
            
            // 추가 버튼
        } else {
            self.tabBarController?.selectedIndex = 0
            
            if let nav = self.tabBarController?.viewControllers?.first as? UINavigationController,
               let searchVC = nav.viewControllers[0] as? SearchViewController {
                searchVC.searchBar.becomeFirstResponder()
            }
            
        }
    }
    
    // 컬렉션 뷰 레이아웃
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.headerMode = .supplementary
            
            // 스와이프 액션
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, completion in
                    self.viewModel.deleteOneFavorite(indexPath: indexPath)
                    completion(true)
                }
                
                deleteAction.backgroundColor = .red
                
                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
            section.interGroupSpacing = 5
            
            return section
        }
        
        return layout
    }
    
    // UI 세팅 메서드
    private func setupUI() {
        view.backgroundColor = .white
        
        [titleLabel, deleteAllButton, addButton, collectionView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
        }
        
        deleteAllButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalToSuperview().inset(40)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(40)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(40)
            $0.leading.trailing.equalToSuperview().inset(horizontalEdgesInset)
        }
    }
}

// MARK: - CollectionViewDelegate
extension MyBookViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = Book(from: self.viewModel.favoriteOutput.value[indexPath.row])
        
        viewModel.input.onNext([book])
        self.present(DetailViewController(viewModel: self.viewModel), animated: true)
    }
}

// MARK: - CollectionViewDataSource
extension MyBookViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.favoriteOutput.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchListCell.identifier, for: indexPath) as? SearchListCell else { return UICollectionViewCell() }
        
        let favoriteData = self.viewModel.favoriteOutput.value[indexPath.row]
        
        cell.searchSetText(title: favoriteData.title ?? "unknown",
                           writer: favoriteData.authors ?? "unknown",
                           price: Int(favoriteData.price))
        
        return cell
    }
    
    
}
