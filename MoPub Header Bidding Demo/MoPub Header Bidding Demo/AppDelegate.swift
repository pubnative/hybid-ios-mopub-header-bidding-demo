// There are 2 different approaches that you can use for initializing HyBid & MoPub SDKs;
// Approach A: Initialize HyBid and MoPub SDKs separately.
// Approach B: Use MoPub's MPMoPubConfiguration that initializes the both SDKs.

import UIKit
// Approach A - Step 1: Import HyBid into your class
import HyBid
// Approach A - Step 2 & Approach B - Step 1: Import MoPubSDK into your class
import MoPubSDK
// Approach B - Step 2: Import MoPub HyBid Adapters into your class
import MoPub_HyBid_Adapters

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let appToken = "543027b8e954474cbcd9a98481622a3b"
    let adUnitID = "a4eac931d95444f0a95adc77093a22ab"
    let appStoreID = "1530210244"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
// Approach A - Step 3: Setup & Initialize HyBid SDK
        HyBid.initWithAppToken(appToken, completion: nil)

// Approach A - Step 4: Setup & Initialize MoPub SDK
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitID)
        sdkConfig.loggingLevel = .info
        MoPub.sharedInstance().initializeSdk(with: sdkConfig, completion: nil)

// Approach A - Step 5: Set COPPA (Optional)
        HyBid.setCoppa(false)
// Approach A - Step 6: Set Test Mode (Optional)
        HyBid.setTestMode(true)
// Approach A - Step 7: Set Location Tracking (Optional)
        HyBid.setLocationTracking(true)
// Approach A - Step 8: Set Interstitial skipOffet (Optional)
        HyBid.setInterstitialSkipOffset(2)
// Approach A - Step 9: Set Targetting (Optional)
        let targeting = HyBidTargetingModel()
        targeting.age = 28
        targeting.interests = ["music"]
        targeting.gender = "f"     // "f" for female, "m" for male
        HyBid.setTargeting(targeting)
// Approach A - Step 10: Set AppStore App ID (iOS14 +)
        HyBid.setAppStoreAppID(appStoreID)
        
/*
// Approach B - Step 3: Setup & Initialize MoPub SDK and using MoPub's MPMoPubConfiguration, initialize HyBid as well
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitID)
        sdkConfig.setNetwork([HyBidAdapterConfigurationAppTokenKey : appToken], forMediationAdapter: "HyBidAdapterConfiguration")
        sdkConfig.loggingLevel = .info
        sdkConfig.additionalNetworks = [HyBidAdapterConfiguration.self]
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
            // Approach B - Step 4: Set COPPA (Optional)
            HyBid.setCoppa(false)
            // Approach B - Step 5: Set Test Mode (Optional)
            HyBid.setTestMode(true)
            // Approach B - Step 6: Set Location Tracking (Optional)
            HyBid.setLocationTracking(true)
            // Approach B - Step 7: Set Interstitial skipOffet (Optional)
            HyBid.setInterstitialSkipOffset(2)
            // Approach B - Step 8: Set Targetting (Optional)
            let targeting = HyBidTargetingModel()
            targeting.age = 28
            targeting.interests = ["music"]
            targeting.gender = "f"     // "f" for female, "m" for male
            HyBid.setTargeting(targeting)
            // Approach B - Step 9: Set AppStore App ID (iOS14 +)
            HyBid.setAppStoreAppID(self.appStoreID)
        }
*/
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

