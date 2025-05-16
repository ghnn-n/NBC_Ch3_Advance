//
//  SearchListCell.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import SnapKit

// MARK: - SearchListCell
class SearchListCell: UICollectionViewListCell {
    
    // MARK: - Property
    static let identifier = "SearchListCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .black
        
        return label
    }()
    
    private let writerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 3
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .black
        label.textAlignment = .right
        
        return label
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        writerLabel.text = nil
        priceLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func searchSetText(title: String, writer: String, price: Int) {
            titleLabel.text = title
            writerLabel.text = writer
            priceLabel.text = "\(price)원"
    }
    
    private func setupUI() {
        [titleLabel, writerLabel, priceLabel].forEach {
            contentView.addSubview($0)
        }
        
        contentView.backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 0.3
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalTo(contentView.snp.centerX)
        }
        
        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
            $0.width.equalTo(100)
        }
        
        writerLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(contentView.snp.centerX)
            $0.trailing.equalTo(priceLabel.snp.leading).offset(-4)
        }
    }
}
