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
    
    private lazy var deleteButton: UIButton = {
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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.width - horizontalEdgesInset * 2, height: 60)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
    
}

// MARK: - Method
extension MyBookViewController {
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == self.deleteButton {
            
        } else {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [titleLabel, deleteButton, addButton, collectionView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
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
    
}

// MARK: - CollectionViewDataSource
extension MyBookViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchListCell.identifier, for: indexPath) as? SearchListCell else { return UICollectionViewCell() }
        
        cell.searchSetText(title: "제목", writer: "작가", price: "금액")
        
        return cell
    }
    
    
}
