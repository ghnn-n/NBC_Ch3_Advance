//
//  HeaderView.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import SnapKit

// MARK: - HeaderView
class HeaderView: UICollectionReusableView {
    
    // MARK: - Property
    static let identifier = "HeaderView"
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func setText(text: String) {
        headerLabel.text = text
    }
    
    private func setupUI() {
        addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
        }
    }
}
