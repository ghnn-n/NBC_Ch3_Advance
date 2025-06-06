//
//  TabBarController.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit

// MARK: - TabBarController
class TabBarController: UITabBarController {
    
}

// MARK: - Lifecycle
extension TabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        setVC()
        configure()
    }
    
}

// MARK: - Method
extension TabBarController {
    
    // 기본 값 세팅
    private func configure() {
        let font = UIFont.systemFont(ofSize: 20)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        self.tabBar.standardAppearance = appearance
        self.tabBar.tintColor = .black
        self.tabBar.backgroundColor = .white
    }
    
    // 탭 바로 연동 가능한 ViewContoller
    private func setVC() {
        
        viewControllers = [
            createVC(VC: SearchViewController(), title: "검색"),
            createVC(VC: MyBookViewController(), title: "담은 책 리스트")
        ]
        
    }
    
    // UINavigationController 생성 메서드
    private func createVC(VC: UIViewController, title: String) -> UIViewController {
        let nav = UINavigationController(rootViewController: VC)
        nav.tabBarItem.title = title
        
        return nav
    }
}
