//
//  SearchListCell.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import SnapKit

class SearchListCell: UICollectionViewCell {
    
    // MARK: - Property
    static let identifier = "SearchListCell"
    
    private let searchView: UIView = {
        let view = UIView()
        
        return view
    }()
    
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
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.textColor = .black
        
        return label
    }()
    
    private let historyView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8)
        label.textColor = .black
        
        return label
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        writerLabel.text = ""
        priceLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func searchSetText(title: String, writer: String, price: String) {
        titleLabel.text = title
        writerLabel.text = writer
        priceLabel.text = price
        
        searchView.isHidden = false
        historyView.isHidden = true
    }
    
    func historySetText(title: String) {
        historyLabel.text = title
        
        searchView.isHidden = true
        historyView.isHidden = false
        
    }
    
    private func setupUI() {
        [searchView, historyView].forEach {
            contentView.addSubview($0)
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 0.3
        }
        
        [titleLabel, writerLabel, priceLabel]
            .forEach { searchView.addSubview($0) }
        
        historyView.addSubview(historyLabel)
        
        searchView.backgroundColor = .white
        
        historyView.layer.cornerRadius = contentView.bounds.height / 2
        historyView.layer.masksToBounds = true
        historyView.backgroundColor = UIColor(red: CGFloat.random(in: 1/255...255/255),
                                              green: CGFloat.random(in: 1/255...255/255),
                                              blue: CGFloat.random(in: 1/255...255/255),
                                              alpha: 0.5)
        
        searchView.snp.makeConstraints {
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
        }
        
        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
        
        writerLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(contentView.snp.centerX).offset(16)
        }
        
        historyView.snp.makeConstraints {
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        historyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
