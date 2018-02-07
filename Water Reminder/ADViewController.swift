//
//  ADViewController.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 7/5/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import Foundation
import UIKit
import iAd
import GoogleMobileAds

class ADViewController: UIViewController, ADInterstitialAdDelegate, GADInterstitialDelegate, ChartboostDelegate {
    var displayingAd = false
    fileprivate var hold = false
    fileprivate var iAD: ADInterstitialAd?
    fileprivate var adMob: GADInterstitial?
    fileprivate var holder: UIView!
    fileprivate var altBanner = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Chartboost.setDelegate(self)
    }
    
    func runInterstitialAdWithDelay() {
        delay(ad_interval, closure: { self.runInterstitialAd() })
    }
    
    func runInterstitialAd() {
        if self.altBanner {
            if self.adMob == nil && !self.hold {
                self.adMob = GADInterstitial(adUnitID: google_id)
                self.adMob!.delegate = self
                self.adMob!.load(GADRequest())
            }
        } else {
            if self.iAD == nil && !hold {
                self.iAD = ADInterstitialAd()
                self.iAD?.delegate = self
            }
        }
    }
    
    func stopInterstitialAd() {
        self.iAD?.delegate = nil
        self.iAD = nil
        self.adMob?.delegate = nil
        self.adMob = nil
        if self.holder != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.holder.alpha = 0
                }, completion: { _ in
                    self.holder?.removeFromSuperview()
                    self.holder = nil
            })
        }
    }
    
    func holdInterstitialAd() {
        self.hold = true
    }
    
    func unholdInterstitialAd(_ wait: Bool) {
        self.hold = false
        if wait {
            runInterstitialAdWithDelay()
        } else {
            runInterstitialAd()
        }
    }
    
    func interstitialAdDidLoad(_ interstitialAd: ADInterstitialAd!) {
        print("iAD: Interstitial Ad Did Load")
        if (interstitialAd.isLoaded) {
            if topMostController(self) != self {
                delay(1, closure: {
                    self.interstitialAdDidLoad(interstitialAd)
                })
            } else {
                interstitialAdWillLoad()
                self.holder = UIView(frame: self.view.bounds)
                self.holder.alpha = 0
                self.view.addSubview(self.holder)
                interstitialAd.present(in: self.holder)
                UIView.animate(withDuration: 0.3, animations: {
                    self.holder.alpha = 1
                    }, completion: nil)
            }
        }
    }
    
    func interstitialAdDidUnload(_ interstitialAd: ADInterstitialAd!) {
        print("iAD: Interstitial Ad Did Unload")
    }
    
    func interstitialAdActionDidFinish(_ interstitialAd: ADInterstitialAd!) {
        print("iAD: Interstitial Ad Did Finish")
    }
    
    func interstitialAd(_ interstitialAd: ADInterstitialAd!, didFailWithError error: Error!) {
        print("iAD: Interstitial Ad Did Fail With Error: " + error.localizedDescription)
        //self.altBanner = !self.altBanner
        //stopInterstitialAd()
        //runInterstitialAd()
        Chartboost.showInterstitial(CBLocationHomeScreen)
    }
    
    func interstitialAdWillLoad(_ interstitialAd: ADInterstitialAd!) {
        //        interstitialAdWillLoad()
    }
    
    
    // MARK: - ADMOB
    func request() -> GADRequest {
        let request = GADRequest()
        return request
    }
    
    func interstitial(_ interstitial: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("adMob: Interstitial Ad Did Fail With Error: " + error.description)
        //self.adMob = nil
        //self.altBanner = !self.altBanner
        //stopInterstitialAd()
        //runInterstitialAd()
        
        Chartboost.showInterstitial(CBLocationHomeScreen)
        
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("adMob: Interstitial Did Receive Ad")
        if topMostController(self) != self {
            delay(1, closure: {
                self.interstitialDidReceiveAd(ad)
            })
        } else {
            interstitialAdWillLoad()
            ad.present(fromRootViewController: self)
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("adMob: Interstitial Did Dismiss Screen")
        //interstitialAdWillClose()
        
        Chartboost.showInterstitial(CBLocationHomeScreen)
    }
    
    //MARK: - LOOPBACK
    func interstitialAdWillLoad() {
        print("iAD \\ adMob: Interstitial Ad Will Load")
        self.displayingAd = true
    }
    
    func interstitialAdWillClose() {
        print("iAD \\ adMob: Interstitial Ad Will Close")
        self.displayingAd = false
        stopInterstitialAd()
        runInterstitialAdWithDelay()
    }
    
    func didFail(toLoadInterstitial location: String!, withError error: CBLoadError) {
        interstitialAdWillClose()
    }
    
    func didDismissInterstitial(_ location: String!) {
        interstitialAdWillClose()
    }
}
