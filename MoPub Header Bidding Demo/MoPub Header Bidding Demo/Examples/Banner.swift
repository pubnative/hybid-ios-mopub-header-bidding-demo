import UIKit
// Step 1: Import MoPubSDK into your class
import MoPubSDK
// Step 7: Import HyBid into your class
import HyBid

class Banner: UIViewController {

    @IBOutlet weak var bannerAdContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

// Step 2: Create a MPAdView property
    var moPubBanner : MPAdView!
// Step 8: Create a HyBidAdRequest property
    var bannerAdRequest =  HyBidAdRequest()
    let adUnitID = "a4eac931d95444f0a95adc77093a22ab"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MoPub Header Bidding Banner"
// Step 3: Initialize the MPAdView property
        moPubBanner = MPAdView(adUnitId: adUnitID)
        moPubBanner.frame = CGRect(x: 0, y: 0, width: bannerAdContainer.frame.size.width, height: bannerAdContainer.frame.size.height)
// Step 4: Set MPAdViewDelegate delegate
        moPubBanner.delegate = self
// Step 5: Call stopAutomaticallyRefreshingContents method
        moPubBanner.stopAutomaticallyRefreshingContents()
        bannerAdContainer.addSubview(moPubBanner)
    }

    @IBAction func loadAdTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        bannerAdContainer.isHidden = true
// Step 9: Initialize the HyBidAdRequest property with a HyBidAdSize and request a HyBidAd
        bannerAdRequest.adSize = HyBidAdSize.size_320x50
        bannerAdRequest.requestAd(with: self, withZoneID: "2")
    }
}

// Step 6: Implement the MPAdViewDelegate methods
extension Banner : MPAdViewDelegate {
    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }

    func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
        bannerAdContainer.isHidden = false
        activityIndicator.stopAnimating()
    }

    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
        activityIndicator.stopAnimating()
    }
}

// Step 10: Implement the HyBidAdRequestDelegate methods
extension Banner : HyBidAdRequestDelegate {
    func requestDidStart(_ request: HyBidAdRequest!) {
        print("Request\(String(describing: request)) started")
    }

    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        print("Request loaded with ad: \(String(describing: ad))")
        if (request == self.bannerAdRequest) {
            // Step 11: Request a MoPub ad with some parameters as keywords
            moPubBanner.keywords = HyBidHeaderBiddingUtils.createHeaderBiddingKeywordsString(with: ad)
            moPubBanner.loadAd()
        }
    }

    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        print("Request\(String(describing: request)) failed with error: \(error.localizedDescription)")
        moPubBanner.loadAd()
    }
}
