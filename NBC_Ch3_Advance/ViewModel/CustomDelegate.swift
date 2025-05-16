//
//  Delegate.swift
//  NBC_Ch3_Advance
//
//  Created by 최규현 on 5/14/25.
//

import UIKit

// MARK: - CustomDelegate
protocol CustomDelegate: UIViewController {
    func didFinishedAddBook(was success: Bool)
}
