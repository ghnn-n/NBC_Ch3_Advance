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
    
    private let horizontalEdgesInset: CGFloat = 20
    private let viewModel = MainViewModel()
    private var favoriteBookData = [FavoriteBook]()
        
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
        
        self.navigationController?.navigationBar.isHidden = true
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.favoriteBookData = FavoriteBookManager.shared.fetch()
        self.collectionView.reloadData()
    }
    
}

// MARK: - Method
extension MyBookViewController {
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == self.deleteAllButton {
            FavoriteBookManager.shared.deleteAll()
            self.favoriteBookData = FavoriteBookManager.shared.fetch()
            self.collectionView.reloadData()
        } else {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.headerMode = .supplementary
            
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, completion in
                    FavoriteBookManager.shared.deleteOne(item: self.favoriteBookData[indexPath.row].isbn)
                    self.favoriteBookData = FavoriteBookManager.shared.fetch()
                    self.collectionView.reloadData()
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

// MARK: - CustomDelegate
extension MyBookViewController: CustomDelegate {
    func didFinishedAddBook(was success: Bool) {
        let alert = UIAlertController(title: success ? "성공!" : "실패",
                                      message: success ? "담기를 완료했습니다." : "같은 책이 이미 담겨 있습니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: true)
    }
}

// MARK: - CollectionViewDelegate
extension MyBookViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.onNext(Book(from: self.favoriteBookData[indexPath.row]))
        self.present(DetailViewController(viewModel: self.viewModel, delegate: self), animated: true)
    }
}

// MARK: - CollectionViewDataSource
extension MyBookViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteBookData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchListCell.identifier, for: indexPath) as? SearchListCell else { return UICollectionViewCell() }
        
        guard let title = self.favoriteBookData[indexPath.row].title,
              let authors = self.favoriteBookData[indexPath.row].authors else { return UICollectionViewCell() }
        
        cell.searchSetText(title: title,
                           writer: authors,
                           price: Int(self.favoriteBookData[indexPath.row].price))
        
        return cell
    }
    
    
}
