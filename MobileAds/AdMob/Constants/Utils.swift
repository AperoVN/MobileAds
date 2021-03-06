//
//  Utils.swift
//  MobileAds
//
//  Created by Quang Ly Hoang on 24/05/2022.
//

import UIKit
import Toast_Swift

class Utils {
    static func showToast(_ message: String, on view: UIView? = UIApplication.getTopViewController()?.view) {
        view?.hideToast()
        view?.makeToast(message, duration: 2.0, position: .bottom)
    }
}
