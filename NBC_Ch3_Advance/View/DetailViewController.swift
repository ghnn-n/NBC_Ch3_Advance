//
//  DetailViewController.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import RxSwift
import SnapKit

// MARK: - DetailViewController
class DetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: MainViewModel
    
    weak var delegate: CustomDelegate?
    
    private let scrollView = UIScrollView()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    private let writerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("담기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Initialize
    init(viewModel: MainViewModel, delegate: CustomDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension DetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
}

// MARK: - Method
extension DetailViewController {
    
    private func bind() {
        self.viewModel.output
            .subscribe(onNext: { observer in
                self.viewModel.detailInput(data: observer.first)
                self.titleLabel.text = observer.first?.title
                self.priceLabel.text = "\(observer.first?.price ?? 0)원"
                self.detailLabel.text = observer.first?.contents
            }, onError: { error in
                print("DetailVC data load error: \(error)")
            }).disposed(by: disposeBag)
        
        self.viewModel.authorOutput
            .subscribe(onNext: { authors in
                self.writerLabel.text = authors.first
            }).disposed(by: disposeBag)
        
        self.viewModel.imageOutput
            .observe(on: MainScheduler())
            .subscribe(onNext: { image in
                self.imageView.image = image
            }).disposed(by: disposeBag)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == self.addButton {
            let didAdded = self.viewModel.addCartButtonTapped()
            
            self.dismiss(animated: true) {
                self.delegate?.didFinishedAddBook(was: didAdded)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        let buttonHeight: CGFloat = 60
        
        [titleLabel, writerLabel, imageView, priceLabel, detailLabel]
            .forEach { contentView.addSubview($0) }
        
        scrollView.addSubview(contentView)
        
        [scrollView, addButton, cancelButton]
            .forEach { view.addSubview($0) }
        
        [addButton, cancelButton].forEach{
            $0.layer.cornerRadius = buttonHeight / 3
        }
        
        cancelButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.width.equalTo(view.bounds.width / 5)
            $0.height.equalTo(buttonHeight)
        }
        
        addButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(cancelButton)
        }
        
        scrollView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.frame.width - 20)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(cancelButton.snp.top).offset(-20)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(20)
        }
        
        writerLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(100)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(writerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(view.bounds.height / 2 - 30)
        }
        
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}
