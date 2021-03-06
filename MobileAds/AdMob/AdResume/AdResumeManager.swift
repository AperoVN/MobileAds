//
//  AdResumeManager.swift
//  MobileAds
//
//  Created by ANH VU on 21/01/2022.
//

import GoogleMobileAds
import UIKit

protocol AdResumeManagerDelegate: AnyObject {
    func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AdResumeManager)
    
}
 
open class AdResumeManager: NSObject {
    public static let shared = AdResumeManager()
    
    public let timeoutInterval: TimeInterval = 4 * 3600
    public var isLoadingAd = false
    public var isShowingAd = false
    public var resumeAdId: AdUnitID?
    var appOpenAd: GADAppOpenAd?
    weak var appOpenAdManagerDelegate: AdResumeManagerDelegate?
    var loadTime: Date?
    
    public var blockadDidDismissFullScreenContent: VoidBlockAds?
    public var blockAdResumeClick                : VoidBlockAds?
    
    private func wasLoadTimeLessThanNHoursAgo(timeoutInterval: TimeInterval) -> Bool {
        // Check if ad was loaded more than n hours ago.
        if let loadTime = loadTime {
            return Date().timeIntervalSince(loadTime) < timeoutInterval
        }
        return false
    }
    
    private func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(timeoutInterval: timeoutInterval)
    }
    
    private func appOpenAdManagerAdDidComplete() {
        appOpenAdManagerDelegate?.appOpenAdManagerAdDidComplete(self)
    }
    
    public func loadAd() {
        if isLoadingAd || isAdAvailable() {
            return
        }
        isLoadingAd = true
        GADAppOpenAd.load(withAdUnitID: resumeAdId?.rawValue ?? "", request: GADRequest(), orientation: .portrait) { ad, error in
            self.isLoadingAd = false
            if let error = error {
                self.appOpenAd = nil
                self.loadTime = nil
                print("App open ad failed to load with error: \(error.localizedDescription).")
                return
            }
            
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            print("App open ad loaded successfully.")
        }
    }
    
    public func showAdIfAvailable(viewController: UIViewController) {
        if isShowingAd {
            print("App open ad is already showing.")
            return
        }
        if !isAdAvailable() {
            print("App open ad is not ready yet.")
            appOpenAdManagerAdDidComplete()
            loadAd()
            return
        }
        if let ad = appOpenAd {
            print("App open ad will be displayed.")
            isShowingAd = true
            var showVC: UIViewController? = viewController
            if showVC?.navigationController != nil {
                showVC = showVC?.navigationController
                if showVC?.tabBarController != nil {
                    showVC = showVC?.tabBarController
                }
            }
            guard let showVC = showVC else { return }
            
            let loadingVC = AdFullScreenLoadingVC()
            loadingVC.needLoadAd = false
            loadingVC.modalPresentationStyle = .fullScreen
            UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(loadingVC.view)
            showVC.view.endEditing(true)
            loadingVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadingVC.view.removeFromSuperview()
                loadingVC.removeFromParent()
                loadingVC.willMove(toParent: nil)
                ad.present(fromRootViewController: showVC)
            }
        }
    }
}

extension AdResumeManager: GADFullScreenContentDelegate {
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        appOpenAd = nil
        isShowingAd = false
        print("App open ad was dismissed.")
        appOpenAdManagerAdDidComplete()
        loadAd()
        blockadDidDismissFullScreenContent?()
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isShowingAd = true
        print("App open ad is presented.")
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        appOpenAd = nil
        isShowingAd = false
        print("App open ad failed to present with error: \(error.localizedDescription).")
        appOpenAdManagerAdDidComplete()
        loadAd()
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        blockAdResumeClick?()
    }
}

