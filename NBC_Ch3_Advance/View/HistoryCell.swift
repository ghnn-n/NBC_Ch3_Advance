//
//  HistoryCell.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import SnapKit

// MARK: - HistoryCell
class HistoryCell: UICollectionViewCell {
    
    // MARK: - Property
    static let identifier = "HistoryCell"
    
    private let historyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func prepareForReuse() {
        historyLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func historySetText(title: String) {
        historyLabel.text = title
    }
    
    private func setupUI() {
        contentView.addSubview(historyLabel)
        
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 0.3
        contentView.layer.cornerRadius = contentView.bounds.height / 2
        contentView.backgroundColor = UIColor(red: CGFloat.random(in: 1/255...255/255),
                                              green: CGFloat.random(in: 1/255...255/255),
                                              blue: CGFloat.random(in: 1/255...255/255),
                                              alpha: 0.5)
        
        historyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().inset(4)
        }
    }
}
