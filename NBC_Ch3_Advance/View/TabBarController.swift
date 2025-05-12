//
//  TabBarController.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/12/25.
//

import UIKit
import SnapKit

// MARK: - TabBarController
class TabBarController: UITabBarController {
    
}

// MARK: - Lifecycle
extension TabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        setVC()
        setup()
    }
    
}

// MARK: - Method
extension TabBarController {
    
    private func setup() {
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
    
    private func setVC() {
        
        viewControllers = [
            createVC(VC: SearchViewController(), title: "검색", tag: 0),
            createVC(VC: MyBookViewController(), title: "담은 책 리스트", tag: 1)
        ]
        
    }
    
    private func createVC(VC: UIViewController, title: String, tag: Int) -> UIViewController {
        let nav = UINavigationController(rootViewController: VC)
        nav.tabBarItem.title = title
        nav.tabBarItem.tag = tag
        
        return nav
    }
}
