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
    private var bookData: Book?
    private var thumbnailImage: UIImage?
    
    var delegate: CustomDelegate?
    
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
                self.bookData = observer
                self.getData(data: observer)
            }, onError: { error in
                print("DetailVC data load error: \(error)")
            }).disposed(by: disposeBag)
    }
    
    private func getData(data: Book?) {
        guard let data else {
            print("DetailVC.getData(): noDATA")
            return
        }
        
        var author = data.authors
        if author.isEmpty { author = ["unknown"] }
        
        // image 생성이 늦길래 이런 식으로 했는데 rxSwift에 더 좋은 방법이 있지 않을까
        DispatchQueue.global(qos: .default).sync {
            self.getImage(url: data.thumbnail)
            
            DispatchQueue.main.async {
                self.titleLabel.text = data.title
                self.writerLabel.text = data.authors.count > 1 ? author.joined(separator: ", ") : author[0]
                self.imageView.image = self.thumbnailImage
                self.priceLabel.text = "\(data.price)원"
                self.detailLabel.text = data.contents
            }
        }
        
    }
    
    private func getImage(url: String) {
        viewModel.getImage(url: url)
            .subscribe(onSuccess: { observer in
                self.thumbnailImage = observer
            }, onFailure: { error in
                print("DetailVC.getImage() failed: \(error)")
            }).disposed(by: disposeBag)
        
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == self.addButton {
            guard let bookData else { return }
            var wasAdded = true
            
            do {
                try FavoriteBookManager.shared.create(data: bookData)
            } catch CoreDataError.haveSameBook {
                print("같은 책이 있음")
                wasAdded = false
            } catch {
                print("unknownError\(error)")
                wasAdded = false
            }
            
            self.dismiss(animated: true) {
                self.delegate?.didFinishedAddBook(was: wasAdded)
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
