//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "HyBidNativeAd.h"
#import "PNLiteAsset.h"
#import "HyBidDataModel.h"
#import "PNLiteTrackingManager.h"
#import "PNLiteImpressionTracker.h"
#import "HyBidLogger.h"
#import "HyBidSkAdNetworkModel.h"
#import "HyBidAdImpression.h"
#import "UIApplication+PNLiteTopViewController.h"
#import <WebKit/WebKit.h>
#import "HyBidSKAdNetworkViewController.h"
#import "HyBidURLDriller.h"

NSString * const PNLiteNativeAdBeaconImpression = @"impression";
NSString * const PNLiteNativeAdBeaconClick = @"click";

@interface HyBidNativeAd () <PNLiteImpressionTrackerDelegate, HyBidContentInfoViewDelegate, HyBidURLDrillerDelegate>

@property (nonatomic, strong) PNLiteImpressionTracker *impressionTracker;
@property (nonatomic, strong) NSDictionary *trackingExtras;
@property (nonatomic, strong) NSMutableDictionary *fetchedAssets;
@property (nonatomic, strong) NSArray *clickableViews;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, weak) NSObject<HyBidNativeAdDelegate> *delegate;
@property (nonatomic, weak) NSObject<HyBidNativeAdFetchDelegate> *fetchDelegate;
@property (nonatomic, assign) BOOL isImpressionConfirmed;
@property (nonatomic, assign) NSInteger remainingFetchableAssets;
@property (nonatomic, strong) HyBidNativeAdRenderer *renderer;

@end

@implementation HyBidNativeAd

- (void)dealloc {
    self.ad = nil;
    self.renderer = nil;
    self.trackingExtras = nil;
    self.fetchedAssets = nil;
    [self.tapRecognizer removeTarget:self action:@selector(handleTap:)];
    for (UIView *view in self.clickableViews) {
        [view removeGestureRecognizer:self.tapRecognizer];
    }
    self.tapRecognizer = nil;
    self.clickableViews = nil;
    [self.impressionTracker clear];
    self.impressionTracker = nil;
    self.bannerImageView = nil;
    self.delegate = nil;
    self.fetchDelegate = nil;
}

#pragma mark HyBidNativeAd

- (instancetype)initWithAd:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        self.ad = ad;
    }
    return self;
}

- (NSString *)title {
    NSString *result = nil;
    if (self.ad.isUsingOpenRTB) {
        HyBidOpenRTBDataModel *data = [self.ad openRTBAssetDataWithType:PNLiteAsset.title];
        if (data) {
            result = data.text;
        }
    } else {
        HyBidDataModel *data = [self.ad assetDataWithType:PNLiteAsset.title];
        if (data) {
            result = data.text;
        }
    }
    return result;
}

- (NSString *)body {
    NSString *result = nil;
    if (self.ad.isUsingOpenRTB) {
        HyBidOpenRTBDataModel *data = [self.ad openRTBAssetDataWithType:PNLiteAsset.body];
        if (data) {
            result = data.text;
        }
    } else {
        HyBidDataModel *data = [self.ad assetDataWithType:PNLiteAsset.body];
        if (data) {
            result = data.text;
        }
    }
    return result;
}

- (NSString *)callToActionTitle {
    NSString *result = nil;
    if (self.ad.isUsingOpenRTB) {
        HyBidOpenRTBDataModel *data = [self.ad openRTBAssetDataWithType:PNLiteAsset.callToAction];
        if (data) {
            result = data.text;
        }
    } else {
        HyBidDataModel *data = [self.ad assetDataWithType:PNLiteAsset.callToAction];
        if (data) {
            result = data.text;
        }
    }
    return result;
}

- (NSString *)iconUrl {
    NSString *result = nil;
    if (self.ad.isUsingOpenRTB) {
        HyBidOpenRTBDataModel *data = [self.ad openRTBAssetDataWithType:PNLiteAsset.icon];
        if (data) {
            result = data.url;
        }
    } else {
        HyBidDataModel *data = [self.ad assetDataWithType:PNLiteAsset.icon];
        if (data) {
            result = data.url;
        }
    }
    return result;
}

- (NSString *)bannerUrl {
    NSString *result = nil;
    if (self.ad.isUsingOpenRTB) {
        HyBidOpenRTBDataModel *data = [self.ad openRTBAssetDataWithType:PNLiteAsset.banner];
        if (data) {
            result = data.url;
        }
    } else {
        HyBidDataModel *data = [self.ad assetDataWithType:PNLiteAsset.banner];
        if (data) {
            result = data.url;
        }
    }
    return result;
}

- (NSString *)clickUrl {
    NSString *result = nil;
    NSString *URLString = self.ad.link;
    if (URLString) {
        NSURL *clickURL = [NSURL URLWithString:URLString];
        result = [self injectExtrasWithUrl:clickURL].absoluteString;
    }
    return result;
}

- (NSNumber *)rating {
    NSNumber *result = nil;
    if (self.ad.isUsingOpenRTB) {
        HyBidOpenRTBDataModel *data = [self.ad openRTBAssetDataWithType:PNLiteAsset.rating];
        if (data) {
            result = data.number;
        }
    } else {
        HyBidDataModel *data = [self.ad assetDataWithType:PNLiteAsset.rating];
        if (data) {
            result = data.number;
        }
    }
    return result;
}

- (UIView *)banner {
    if (!self.bannerImageView) {
        if(self.bannerUrl && self.bannerUrl.length > 0) {
            NSData *bannerData = self.fetchedAssets[[NSURL URLWithString:self.bannerUrl]];
            if(bannerData && bannerData.length > 0) {
                UIImage *bannerImage = [UIImage imageWithData:bannerData];
                if(bannerImage) {
                    self.bannerImageView = [[UIImageView alloc] initWithImage:bannerImage];
                    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
                }
            }
        }
    }
    return self.bannerImageView;
}

- (UIImage *)bannerImage {
    UIImage *image = nil;
    if(self.bannerUrl && self.bannerUrl.length > 0) {
        NSData *bannerData = self.fetchedAssets[[NSURL URLWithString:self.bannerUrl]];
        if(bannerData && bannerData.length > 0) {
            image = [UIImage imageWithData:bannerData];
        }
    }
    return image;
}

- (UIImage *)icon {
    UIImage *result = nil;
    if(self.iconUrl && self.iconUrl.length > 0) {
        NSData *imageData = self.fetchedAssets[[NSURL URLWithString:self.iconUrl]];
        if(imageData && imageData.length > 0) {
            result = [UIImage imageWithData:imageData];
        }
    }
    return result;
}

- (HyBidContentInfoView *)contentInfo {
    HyBidContentInfoView *result = nil;
    if (self.ad) {
        result = self.ad.contentInfo;
    }
    return result;
}

- (HyBidSkAdNetworkModel *)skAdNetworkModel {
    HyBidSkAdNetworkModel *result = nil;
    if (self.ad) {
        result = [self.ad getSkAdNetworkModel];
    }
    return result;
}

- (HyBidSkAdNetworkModel *)openRTBSkAdNetworkModel {
     HyBidSkAdNetworkModel *result = nil;
     if (self.ad) {
         result = [self.ad getOpenRTBSkAdNetworkModel];
     }
     return result;
 }

#pragma mark Tracking & Clicking

- (void)startTrackingView:(UIView *)view withDelegate:(NSObject<HyBidNativeAdDelegate> *)delegate {
    [self startTrackingView:view withClickableViews:nil withDelegate:delegate];
}

- (void)startTrackingView:(UIView *)view withClickableViews:(NSArray *)clickableViews withDelegate:(NSObject<HyBidNativeAdDelegate> *)delegate {
    [self startTrackingView:view withClickableViews:clickableViews withTrackingExtras:nil withDelegate:delegate];
}

- (void)startTrackingView:(UIView *)view withClickableViews:(NSArray *)clickableViews withTrackingExtras:(NSDictionary *)trackingExtras withDelegate:(NSObject<HyBidNativeAdDelegate> *)delegate {
    self.trackingExtras = trackingExtras;
    self.delegate = delegate;
    [self startTrackingImpressionWithView:view];
    [self startTrackingClicksWithView:view withClickableViews:clickableViews];
}

- (void)startTrackingImpressionWithView:(UIView *)view {
    if (!view) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad view is nil, cannot start tracking."];
    } else if (self.isImpressionConfirmed) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression is already confirmed, dropping impression tracking."];
    } else {
        if(!self.impressionTracker) {
            self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
            self.impressionTracker.delegate = self;
        }
        [self.impressionTracker addView:view];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
        [[HyBidAdImpression sharedInstance] startImpressionForAd:self.ad];
#endif
    }
}

- (void)startTrackingClicksWithView:(UIView*)view withClickableViews:(NSArray*)clickableViews {
    if (!view && !clickableViews) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Click view is nil, clicks won't be tracked."];
    } else if (!self.clickUrl || self.clickUrl.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Click URL is empty, clicks won't be tracked."];
    } else {
        self.clickableViews = [clickableViews mutableCopy];
        if(!self.clickableViews) {
            self.clickableViews = [NSArray arrayWithObjects:view, nil];
        }
        if(!self.tapRecognizer) {
            self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        }
        for (UIView *clickableView in self.clickableViews) {
            clickableView.userInteractionEnabled=YES;
            [clickableView addGestureRecognizer:self.tapRecognizer];
        }
    }
}

- (void)stopTracking {
    [self stopTrackingImpression];
    [self stopTrackingClicks];
}

- (void)stopTrackingImpression {
    [self.impressionTracker clear];
    self.impressionTracker = nil;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
    [[HyBidAdImpression sharedInstance] endImpressionForAd:self.ad];
#endif
}

- (void)stopTrackingClicks {
    for (UIView *view in self.clickableViews) {
        [view removeGestureRecognizer:self.tapRecognizer];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self invokeDidClick];
        [self confirmBeaconsWithType:PNLiteNativeAdBeaconClick];
        
        HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
        
        if (skAdNetworkModel) {
            NSDictionary* productParams = [skAdNetworkModel getStoreKitParameters];
            if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
                [[HyBidURLDriller alloc] startDrillWithURLString:self.clickUrl delegate:self];
                dispatch_async(dispatch_get_main_queue(), ^{
                    HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters:productParams];

                    [[UIApplication sharedApplication].topViewController presentViewController:skAdnetworkViewController animated:true completion:nil];
                });
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.clickUrl]];
            }
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.clickUrl]];
        }
    }
}

#pragma Confirm Beacons

- (void)confirmBeaconsWithType:(NSString *)type {
    if (!self.ad || !self.ad.beacons || self.ad.beacons.count == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad beacons not found for type: %@", type]];
    } else {
        for (HyBidDataModel *beacon in self.ad.beacons) {
            if ([beacon.type isEqualToString:type]) {
                NSString *beaconJs = [beacon stringFieldWithKey:@"js"];
                if (beacon.url && beacon.url.length > 0) {
                    NSURL *beaconUrl = [NSURL URLWithString:beacon.url];
                    NSURL *injectedUrl = [self injectExtrasWithUrl:beaconUrl];
                    [PNLiteTrackingManager trackWithURL:injectedUrl];
                } else if (beaconJs && beaconJs.length > 0) {
                    __block NSString *beaconJsBlock = [beacon stringFieldWithKey:@"js"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
                        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
                        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
                        [wkUController addUserScript:wkUScript];
                        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
                        wkWebConfig.userContentController = wkUController;

                        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkWebConfig];
                        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//                        [webView evaluateJavaScript:beaconJsBlock completionHandler:nil];
                        [webView evaluateJavaScript:beaconJsBlock completionHandler:^(id result, NSError *error) {}];

                    });
                }
            }
        }
    }
}

- (NSURL*)injectExtrasWithUrl:(NSURL*)url {
    NSURL *result = url;
    if (self.trackingExtras != nil) {
        NSString *query = result.query;
        if(!query) {
            query = @"";
        }
        for (NSString *key in self.trackingExtras) {
            NSString *value = self.trackingExtras[key];
            query = [NSString stringWithFormat:@"%@&%@=%@", query, key, value];
        }
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        [urlComponents setQuery:query];
        result = urlComponents.URL;
    }
    return result;
}

#pragma mark Ad Rendering

- (void)renderAd:(HyBidNativeAdRenderer *)renderer {
    self.renderer = renderer;
    
    if(self.renderer.titleView) {
        self.renderer.titleView.text = self.title;
    }
    
    if(self.renderer.bodyView) {
        self.renderer.bodyView.text = self.body;
    }
    
    if(self.renderer.callToActionView) {
        if ([self.renderer.callToActionView isKindOfClass:[UIButton class]]) {
            [(UIButton *) self.renderer.callToActionView setTitle:self.callToActionTitle forState:UIControlStateNormal];
        } else if ([self.renderer.callToActionView isKindOfClass:[UILabel class]]) {
            [(UILabel *) self.renderer.callToActionView setText:self.callToActionTitle];
        }
    }
    
    if (self.renderer.starRatingView) {
        self.renderer.starRatingView.value = [self.rating floatValue];
    }
    
    if(self.renderer.iconView && self.icon) {
        self.renderer.iconView.image = self.icon;
    }
    
    UIView *banner = self.banner;
    if(self.renderer.bannerView && banner) {
        [self.renderer.bannerView addSubview:banner];
        banner.frame = self.renderer.bannerView.bounds;
    }
    
    HyBidContentInfoView *contentInfo = self.contentInfo;
    contentInfo.delegate = self;
    if (self.renderer.contentInfoView && contentInfo) {
        [self.renderer.contentInfoView addSubview:contentInfo];
        contentInfo.frame = self.renderer.contentInfoView.bounds;
    }
}

#pragma mark Asset Fetching

- (void)fetchNativeAdAssetsWithDelegate:(NSObject<HyBidNativeAdFetchDelegate> *)delegate {
    NSMutableArray *assets = [NSMutableArray array];
    if (self.bannerUrl) {
        [assets addObject:self.bannerUrl];
    }
    if (self.iconUrl) {
        [assets addObject:self.iconUrl];
    }
    if (delegate) {
        self.fetchDelegate = delegate;
        [self fetchAssets:assets];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Fetch asssets with delegate nil, dropping this call."];
    }
}

- (void)fetchAssets:(NSArray<NSString *> *)assets {
    if(assets && assets.count > 0) {
        self.remainingFetchableAssets = assets.count;
        for (NSString *assetURLString in assets) {
            [self fetchAsset:assetURLString];
        }
    } else {
        [self invokeFetchDidFailWithError:[NSError errorWithDomain:@"No assets to fetch." code:0 userInfo:nil]];
    }
}

- (void)fetchAsset:(NSString *)assetURLString {
    if (assetURLString && assetURLString.length > 0) {
        __block NSURL *url = [NSURL URLWithString:assetURLString];
        __block HyBidNativeAd *strongSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data) {
                [strongSelf cacheFetchedAssetData:data withURL:url];
                [strongSelf checkFetchProgress];
            } else {
                [strongSelf invokeFetchDidFailWithError:[NSError errorWithDomain:@"Asset can not be downloaded."
                                                                            code:0
                                                                        userInfo:nil]];
            }
            url = nil;
            strongSelf = nil;
        });
    } else {
        [self invokeFetchDidFailWithError:[NSError errorWithDomain:@"Asset URL is nil or empty."
                                                              code:0
                                                          userInfo:nil]];
    }
}

- (void)cacheFetchedAssetData:(NSData *)data withURL:(NSURL*)url {
    if (!self.fetchedAssets) {
        self.fetchedAssets = [NSMutableDictionary dictionary];
    }
    
    if (url && data) {
        self.fetchedAssets[url] = data;
    }
}

- (void)checkFetchProgress {
    self.remainingFetchableAssets --;
    if (self.remainingFetchableAssets == 0) {
        [self invokeFetchDidFinish];
    }
}

#pragma mark HyBidContentInfoViewDelegate

- (void)contentInfoViewWidthNeedsUpdate:(NSNumber *)width {
    self.renderer.contentInfoView.layer.frame = CGRectMake(self.renderer.contentInfoView.frame.origin.x, self.renderer.contentInfoView.frame.origin.y, [width floatValue], self.renderer.contentInfoView.frame.size.height);
}

#pragma mark PNLiteImpressionTrackerDelegate

- (void)impressionDetectedWithView:(UIView *)view {
    [self confirmBeaconsWithType:PNLiteNativeAdBeaconImpression];
    [self invokeImpressionConfirmedWithView:view];
}

#pragma mark Callback Helpers

- (void)invokeFetchDidFinish {
    __block NSObject<HyBidNativeAdFetchDelegate> *delegate = self.fetchDelegate;
    __block HyBidNativeAd *strongSelf = self;
    self.fetchDelegate = nil;
    if (delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(nativeAdDidFinishFetching:)]) {
                [delegate nativeAdDidFinishFetching:strongSelf];
            }
            delegate = nil;
            strongSelf = nil;
        });
    }
}

- (void)invokeFetchDidFailWithError:(NSError *)error {
    __block NSError *blockError = error;
    __block HyBidNativeAd *strongSelf = self;
    __block NSObject<HyBidNativeAdFetchDelegate> *delegate = self.fetchDelegate;
    self.fetchDelegate = nil;
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if (delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(nativeAd:didFailFetchingWithError:)]) {
                [delegate nativeAd:strongSelf didFailFetchingWithError:blockError];
            }
            delegate = nil;
            blockError = nil;
            strongSelf = nil;
        });
    }
}

- (void)invokeImpressionConfirmedWithView:(UIView *)view {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAd:impressionConfirmedWithView:)]) {
        [self.delegate nativeAd:self impressionConfirmedWithView:view];
    }
}

- (void)invokeDidClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    }
}

@end
