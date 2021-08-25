import UIKit
// Step 1: Import MoPubSDK into your class
import MoPubSDK
// Step 2: Import HyBid into your class
import HyBid

class Rewarded: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showAdButton: UIButton!

// Step 3: Create a HyBidRewardedAdRequest property
    var rewardedAdRequest =  HyBidRewardedAdRequest()
    let adUnitID = "d705528794274d088f5d510efe32b282"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MoPub Header Bidding Rewarded"
    }

    @IBAction func loadAdTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        showAdButton.isHidden = true
// Step 4: Initialize the HyBidRewardedAdRequest property and request a HyBidAd
        rewardedAdRequest.requestAd(with: self, withZoneID: "6")
    }
    
    @IBAction func showAdTouchUpInside(_ sender: UIButton) {
// Step 9: Check available rewards and if there is one that is suitable, present the rewarded ad with the created reward
        if let reward = MPRewardedAds.availableRewards(forAdUnitID: adUnitID).first as? MPReward{
            MPRewardedAds.presentRewardedAd(forAdUnitID: adUnitID, from: self, with: reward)
        }
    }
}

// Step 7: Implement the MPRewardedAdsDelegate methods
extension Rewarded : MPRewardedAdsDelegate {
    func rewardedAdDidLoad(forAdUnitID adUnitID: String!) {
        activityIndicator.stopAnimating()
        showAdButton.isHidden = false
    }
    
    func rewardedAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        activityIndicator.stopAnimating()
    }
    
    func rewardedAdDidDismiss(forAdUnitID adUnitID: String!) {
        showAdButton.isHidden = true
    }
}

// Step 5: Implement the HyBidAdRequestDelegate methods
extension Rewarded : HyBidAdRequestDelegate {
    func requestDidStart(_ request: HyBidAdRequest!) {
        print("Request\(String(describing: request)) started")
    }

    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        print("Request loaded with ad: \(String(describing: ad))")
        if (request == rewardedAdRequest) {
            // Step 6: Set MPRewardedAdsDelegate delegate
            MPRewardedAds.setDelegate(self, forAdUnitId: adUnitID)
            // Step 8: Request a MoPub ad with some parameters as keywords
            MPRewardedAds.loadRewardedAd(withAdUnitID: adUnitID, keywords: HyBidHeaderBiddingUtils.createHeaderBiddingKeywordsString(with: ad), userDataKeywords: nil, mediationSettings: nil)
        }
    }

    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        print("Request\(String(describing: request)) failed with error: \(error.localizedDescription)")
        MPRewardedAds.loadRewardedAd(withAdUnitID: adUnitID, withMediationSettings: nil)
    }
}
