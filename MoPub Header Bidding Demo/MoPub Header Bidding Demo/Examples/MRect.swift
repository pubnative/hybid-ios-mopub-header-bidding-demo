import UIKit
// Step 1: Import MoPubSDK into your class
import MoPubSDK
// Step 7: Import HyBid into your class
import HyBid

class MRect: UIViewController {

    @IBOutlet weak var mRectAdContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

// Step 2: Create a MPAdView property
    var moPubMRect : MPAdView!
// Step 8: Create a HyBidAdRequest property
    var mRectAdRequest =  HyBidAdRequest()
    let adUnitID = "f2acf01fca1b4221b41c601abd49e7b2"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MoPub Header Bidding MRect"
// Step 3: Initialize the MPAdView property
        moPubMRect = MPAdView(adUnitId: adUnitID)
        moPubMRect.frame = CGRect(x: 0, y: 0, width: mRectAdContainer.frame.size.width, height: mRectAdContainer.frame.size.height)
// Step 4: Set MPAdViewDelegate delegate
        moPubMRect.delegate = self
// Step 5: Call stopAutomaticallyRefreshingContents method
        moPubMRect.stopAutomaticallyRefreshingContents()
        mRectAdContainer.addSubview(moPubMRect)
    }

    @IBAction func loadAdTouchUpInside(_ sender: UIButton) {
        activityIndicator.startAnimating()
        mRectAdContainer.isHidden = true
// Step 9: Initialize the HyBidAdRequest property with a HyBidAdSize and request a HyBidAd
        mRectAdRequest.adSize = HyBidAdSize.size_300x250
        mRectAdRequest.requestAd(with: self, withZoneID: "3")
    }
}

// Step 6: Implement the MPAdViewDelegate methods
extension MRect : MPAdViewDelegate {
    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }

    func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
        mRectAdContainer.isHidden = false
        activityIndicator.stopAnimating()
    }

    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
        activityIndicator.stopAnimating()
    }
}

// Step 10: Implement the HyBidAdRequestDelegate methods
extension MRect : HyBidAdRequestDelegate {
    func requestDidStart(_ request: HyBidAdRequest!) {
        print("Request\(String(describing: request)) started")
    }

    func request(_ request: HyBidAdRequest!, didLoadWith ad: HyBidAd!) {
        print("Request loaded with ad: \(String(describing: ad))")
        if (request == self.mRectAdRequest) {
            // Step 11: Request a MoPub ad with some parameters as keywords
            moPubMRect.keywords = HyBidHeaderBiddingUtils.createHeaderBiddingKeywordsString(with: ad)
            moPubMRect.loadAd()
        }
    }

    func request(_ request: HyBidAdRequest!, didFailWithError error: Error!) {
        print("Request\(String(describing: request)) failed with error: \(error.localizedDescription)")
        moPubMRect.loadAd()
    }
}
