import UIKit
// Step 1: Import MoPubSDK into your class
import MoPubSDK
// Step 6: Import HyBid into your class
import HyBid

class Interstitial: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showAdButton: UIButton!

// Step 2: Create a MPInterstitialAdController property
    var moPubInterstitial = MPInterstitialAdController()
// Step 7: Create a HyBidInterstitialAdRequest property
    var interstitialAdRequest =  HyBidInterstitialAdRequest()
    let adUnitID = "e00185ccb4344c2792b991f7d33e2fd9"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MoPub Header Bidding Interstitial"
// Step 3: Initialize the MPInterstitialAdController property
        moPubInterstitial = MPInterstitialAdController.init(forAdUnitId: adUnitID)
// Step 4: Set MPInterstitialAdControllerDelegate delegate
        moPubInterstitial.delegate = self
    }

    @IBAction func loadAdTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        showAdButton.isHidden = true
// Step 8: Initialize the HyBidInterstitialAdRequest property and request a HyBidAd
        interstitialAdRequest.requestAd(with: self, withZoneID: "4")
    }
    
    @IBAction func showAdTouchUpInside(_ sender: UIButton) {
// Step 11: Check Ready property whether the ad has been loaded and is ready to be displayed
        if moPubInterstitial.ready {
            moPubInterstitial.show(from: self)
        } else {
            print("Ad wasn't ready")
        }
    }
}

// Step 5: Implement the MPInterstitialAdControllerDelegate methods
extension Interstitial : MPInterstitialAdControllerDelegate {
    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        activityIndicator.stopAnimating()
        showAdButton.isHidden = false
    }

    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!, withError error: Error!) {
        activityIndicator.stopAnimating()
    }
    
    func interstitialDidDismiss(_ interstitial: MPInterstitialAdController!) {
        showAdButton.isHidden = true
    }
}

// Step 9: Implement the HyBidAdRequestDelegate methods
extension Interstitial : HyBidAdRequestDelegate {
    func requestDidStart(_ request: HyBidAdRequest!) {
        print("Request\(String(describing: request)) started")
    }

    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        print("Request loaded with ad: \(String(describing: ad))")
        if (request == interstitialAdRequest) {
            // Step 10: Request a MoPub ad with some parameters as keywords
            moPubInterstitial.keywords = HyBidHeaderBiddingUtils.createHeaderBiddingKeywordsString(with: ad)
            moPubInterstitial.loadAd()
        }
    }

    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        print("Request\(String(describing: request)) failed with error: \(error.localizedDescription)")
        moPubInterstitial.loadAd()
    }
}
