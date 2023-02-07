//
//  RNOFaceTecView.swift
//  RNOFaceTec
//
//  Created by Darius Rainys on 2022-11-01.
//  Copyright © 2022 Facebook. All rights reserved.
//

import UIKit
import FaceTecSDK

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIColor {
    public convenience init(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
            else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = CGFloat(1)
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        // The default color is red, so it would be easily recognizable, when a bad hex value is passed
        self.init(red: 1, green: 0, blue: 0, alpha: 1)
        return
    }
}

class RNOFaceTecView : UIView {
    weak var vc: UIViewController?
    
    @objc var onUpdate: RCTBubblingEventBlock? = nil {
        didSet {
            RNOUtilities.onUpdate = onUpdate
        }
    }
    @objc var vocalGuidanceMode: String = "" {
        didSet {
            print("vocalGuidanceMode: " + vocalGuidanceMode)
            switch vocalGuidanceMode {
            case "minimal":
                RNOUtilities.vocalGuidanceMode = RNOVocalGuidanceMode.minimal
            case "full":
                RNOUtilities.vocalGuidanceMode = RNOVocalGuidanceMode.full
            default:
                RNOUtilities.vocalGuidanceMode = RNOVocalGuidanceMode.off
                print("No vocal guidance")
            }
            
        }
    }
    @objc var customization: String = "" {
        didSet {
            print("customization: " + customization)
            let data = Data(customization.utf8)
            let decoder = JSONDecoder()
            
            do {
                let decoded = try decoder.decode(RNOCustomization.self, from: data)
                
                RNOConfig.customization = convertCustomizationJSONIntoFaceTecCustomization(customization: decoded)
            } catch {
                print("Failed to decode JSON")
                dump(error)
            }
        }
    }
    @objc var sessionToken: String = "" {
        didSet {
            print("sessionToken: " + sessionToken)
            RNOConfig.sessionToken = sessionToken
        }
    }
    @objc var deviceKeyIdentifier: String = "" {
        didSet {
            print("deviceKeyIdentifier: " + deviceKeyIdentifier)
            RNOConfig.deviceKeyIdentifier = deviceKeyIdentifier
        }
    }
    @objc var productionKeyText: String = "" {
        didSet {
            print("productionKeyText: " + productionKeyText)
            RNOConfig.productionKeyText = productionKeyText
        }
    }
    @objc var faceScanEncryptionKey: String = "" {
        didSet {
            print("faceScanEncryptionKey: " + faceScanEncryptionKey)
            RNOConfig.publicFaceScanEncryptionKey = faceScanEncryptionKey
        }
    }
    
    private func getImage(name imageName: String) -> UIImage {
        return UIImage.init(named: imageName, in: RNOUtilities.bundle, compatibleWith: nil)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if vc == nil {
            embed()
        } else {
            vc?.view.frame = bounds
        }
    }
    
    private func embed() {
        guard
            let parentVC = parentViewController else {
            return
        }
        
        let vc = RNOFaceTecViewController(bundle: RNOUtilities.bundle)
        parentVC.addChild(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParent: parentVC)
        self.vc = vc
    }
    
    private func convertCustomizationJSONIntoFaceTecCustomization(customization: RNOCustomization) -> FaceTecCustomization {
        let faceTecCustomization = FaceTecCustomization()
        
        // faceTecSessionTimerCustomization -----------------------------------------------
        
        if let unwrapped = customization.faceTecSessionTimerCustomization?.livenessCheckNoInteractionTimeout {
            faceTecCustomization.sessionTimerCustomization.livenessCheckNoInteractionTimeout = unwrapped;
        }
        if let unwrapped = customization.faceTecSessionTimerCustomization?.idScanNoInteractionTimeout {
            faceTecCustomization.sessionTimerCustomization.idScanNoInteractionTimeout = unwrapped;
        }
        
        // faceTecOCRConfirmationCustomization --------------------------------------------
        
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.backgroundColors {
            faceTecCustomization.ocrConfirmationCustomization.backgroundColors = unwrapped.map { UIColor(hex: $0) };
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.mainHeaderDividerLineColor {
            faceTecCustomization.ocrConfirmationCustomization.mainHeaderDividerLineColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.mainHeaderDividerLineWidth {
            faceTecCustomization.ocrConfirmationCustomization.mainHeaderDividerLineWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.mainHeaderFont {
            //faceTecCustomization.ocrConfirmationCustomization.mainHeaderFont = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.mainHeaderTextColor {
            faceTecCustomization.ocrConfirmationCustomization.mainHeaderTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.sectionHeaderFont {
            //faceTecCustomization.ocrConfirmationCustomization.sectionHeaderFont = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.sectionHeaderTextColor {
            faceTecCustomization.ocrConfirmationCustomization.sectionHeaderTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.fieldLabelFont {
            //faceTecCustomization.ocrConfirmationCustomization.fieldLabelFont = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.fieldLabelTextColor {
            faceTecCustomization.ocrConfirmationCustomization.fieldLabelTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.fieldValueFont {
            //faceTecCustomization.ocrConfirmationCustomization.fieldValueFont = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.fieldValueTextColor {
            faceTecCustomization.ocrConfirmationCustomization.fieldValueTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldBackgroundColor {
            faceTecCustomization.ocrConfirmationCustomization.inputFieldBackgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldFont {
            //faceTecCustomization.ocrConfirmationCustomization.inputFieldFont = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldTextColor {
            faceTecCustomization.ocrConfirmationCustomization.inputFieldTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldBorderColor {
            faceTecCustomization.ocrConfirmationCustomization.inputFieldBorderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldBorderWidth {
            faceTecCustomization.ocrConfirmationCustomization.inputFieldBorderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldCornerRadius {
            faceTecCustomization.ocrConfirmationCustomization.inputFieldCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldPlaceholderFont {
            //faceTecCustomization.ocrConfirmationCustomization.inputFieldPlaceholderFont = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.inputFieldPlaceholderTextColor {
            faceTecCustomization.ocrConfirmationCustomization.inputFieldPlaceholderTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.showInputFieldBottomBorderOnly {
            faceTecCustomization.ocrConfirmationCustomization.showInputFieldBottomBorderOnly = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonFont {
            //faceTecCustomization.ocrConfirmationCustomization.buttonFont = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonTextNormalColor {
            faceTecCustomization.ocrConfirmationCustomization.buttonTextNormalColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonBackgroundNormalColor {
            faceTecCustomization.ocrConfirmationCustomization.buttonBackgroundNormalColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonTextHighlightColor {
            faceTecCustomization.ocrConfirmationCustomization.buttonTextHighlightColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonBackgroundHighlightColor {
            faceTecCustomization.ocrConfirmationCustomization.buttonBackgroundHighlightColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonTextDisabledColor {
            faceTecCustomization.ocrConfirmationCustomization.buttonTextDisabledColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonBackgroundDisabledColor {
            faceTecCustomization.ocrConfirmationCustomization.buttonBackgroundDisabledColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonBorderColor {
            faceTecCustomization.ocrConfirmationCustomization.buttonBorderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonBorderWidth {
            faceTecCustomization.ocrConfirmationCustomization.buttonBorderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecOCRConfirmationCustomization?.buttonCornerRadius {
            faceTecCustomization.ocrConfirmationCustomization.buttonCornerRadius = unwrapped;
        }
        
        // faceTecIDScanCustomization -----------------------------------------------------
        
        if let unwrapped = customization.faceTecIDScanCustomization?.showSelectionScreenBrandingImage {
            faceTecCustomization.idScanCustomization.showSelectionScreenBrandingImage = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.selectionScreenBrandingImage {
            faceTecCustomization.idScanCustomization.selectionScreenBrandingImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.showSelectionScreenDocumentImage {
            faceTecCustomization.idScanCustomization.showSelectionScreenDocumentImage = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.selectionScreenDocumentImage {
            faceTecCustomization.idScanCustomization.selectionScreenDocumentImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenBackgroundColor {
            faceTecCustomization.idScanCustomization.captureScreenBackgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureFrameStrokeColor {
            faceTecCustomization.idScanCustomization.captureFrameStrokeColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureFrameStrokeWidth {
            faceTecCustomization.idScanCustomization.captureFrameStrokeWith = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureFrameCornerRadius {
            faceTecCustomization.idScanCustomization.captureFrameCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.activeTorchButtonImage {
            faceTecCustomization.idScanCustomization.activeTorchButtonImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.inactiveTorchButtonImage {
            faceTecCustomization.idScanCustomization.inactiveTorchButtonImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.selectionScreenBackgroundColors {
            faceTecCustomization.idScanCustomization.selectionScreenBackgroundColors = unwrapped.map { UIColor(hex: $0) };
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.selectionScreenForegroundColor {
            faceTecCustomization.idScanCustomization.selectionScreenForegroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.reviewScreenBackgroundColors {
            faceTecCustomization.idScanCustomization.reviewScreenBackgroundColors = unwrapped.map { UIColor(hex: $0) };
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.reviewScreenForegroundColor {
            faceTecCustomization.idScanCustomization.reviewScreenForegroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.reviewScreenTextBackgroundColor {
            faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.reviewScreenTextBackgroundBorderColor {
            faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundBorderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.reviewScreenTextBackgroundBorderWidth {
            faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundBorderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.reviewScreenTextBackgroundCornerRadius {
            faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenForegroundColor {
            faceTecCustomization.idScanCustomization.captureScreenForegroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenTextBackgroundColor {
            faceTecCustomization.idScanCustomization.captureScreenTextBackgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenTextBackgroundBorderColor {
            faceTecCustomization.idScanCustomization.captureScreenTextBackgroundBorderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenTextBackgroundBorderWidth {
            faceTecCustomization.idScanCustomization.captureScreenTextBackgroundBorderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenTextBackgroundCornerRadius {
            faceTecCustomization.idScanCustomization.captureScreenTextBackgroundCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenFocusMessageTextColor {
            faceTecCustomization.idScanCustomization.captureScreenFocusMessageTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.captureScreenFocusMessageFont {
            //faceTecCustomization.idScanCustomization.captureScreenFocusMessageFont = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.headerFont {
            //faceTecCustomization.idScanCustomization.headerFont = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.subtextFont {
            //faceTecCustomization.idScanCustomization.subtextFont = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonFont {
            //faceTecCustomization.idScanCustomization.buttonFont = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonTextNormalColor {
            faceTecCustomization.idScanCustomization.buttonTextNormalColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonBackgroundNormalColor {
            faceTecCustomization.idScanCustomization.buttonBackgroundNormalColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonTextHighlightColor {
            faceTecCustomization.idScanCustomization.buttonTextHighlightColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonBackgroundHighlightColor {
            faceTecCustomization.idScanCustomization.buttonBackgroundHighlightColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonTextDisabledColor {
            faceTecCustomization.idScanCustomization.buttonTextDisabledColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonBackgroundDisabledColor {
            faceTecCustomization.idScanCustomization.buttonBackgroundDisabledColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonBorderColor {
            faceTecCustomization.idScanCustomization.buttonBorderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonBorderWidth {
            faceTecCustomization.idScanCustomization.buttonBorderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.buttonCornerRadius {
            faceTecCustomization.idScanCustomization.buttonCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customNFCStartingAnimation {
            //faceTecCustomization.idScanCustomization.customNFCStartingAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customNFCScanningAnimation {
            //faceTecCustomization.idScanCustomization.customNFCScanningAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customNFCCardStartingAnimation {
            //faceTecCustomization.idScanCustomization.customNFCCardStartingAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customNFCCardScanningAnimation {
            //faceTecCustomization.idScanCustomization.customNFCCardScanningAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customNFCSkipOrErrorAnimation {
            //faceTecCustomization.idScanCustomization.customNFCSkipOrErrorAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customStaticNFCStartingAnimation {
            //faceTecCustomization.idScanCustomization.customStaticNFCStartingAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customStaticNFCScanningAnimation {
            //faceTecCustomization.idScanCustomization.customStaticNFCScanningAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecIDScanCustomization?.customStaticNFCSkipOrErrorAnimation {
            //faceTecCustomization.idScanCustomization.customStaticNFCSkipOrErrorAnimation = unwrapped;
        }
        
        // faceTecOverlayCustomization ----------------------------------------------------
        
        if let unwrapped = customization.faceTecOverlayCustomization?.backgroundColor {
            faceTecCustomization.overlayCustomization.backgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOverlayCustomization?.brandingImage {
            faceTecCustomization.overlayCustomization.brandingImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecOverlayCustomization?.showBrandingImage {
            faceTecCustomization.overlayCustomization.showBrandingImage = unwrapped;
        }
        
        // faceTecResultScreenCustomization -----------------------------------------------
        
        if let unwrapped = customization.faceTecResultScreenCustomization?.animationRelativeScale {
            //faceTecCustomization.resultScreenCustomization.animationRelativeScale = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.foregroundColor {
            faceTecCustomization.resultScreenCustomization.foregroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.backgroundColors {
            faceTecCustomization.resultScreenCustomization.backgroundColors = unwrapped.map { UIColor(hex: $0) };
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.activityIndicatorColor {
            faceTecCustomization.resultScreenCustomization.activityIndicatorColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.customActivityIndicatorImage {
            faceTecCustomization.resultScreenCustomization.customActivityIndicatorImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.customActivityIndicatorRotationInterval {
            faceTecCustomization.resultScreenCustomization.customActivityIndicatorRotationInterval = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.customActivityIndicatorAnimation {
            //faceTecCustomization.resultScreenCustomization.customActivityIndicatorAnimation = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.showUploadProgressBar {
            faceTecCustomization.resultScreenCustomization.showUploadProgressBar = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.uploadProgressFillColor {
            faceTecCustomization.resultScreenCustomization.uploadProgressFillColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.uploadProgressTrackColor {
            faceTecCustomization.resultScreenCustomization.uploadProgressTrackColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.resultAnimationBackgroundColor {
            faceTecCustomization.resultScreenCustomization.resultAnimationBackgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.resultAnimationForegroundColor {
            faceTecCustomization.resultScreenCustomization.resultAnimationForegroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.resultAnimationSuccessBackgroundImage {
            faceTecCustomization.resultScreenCustomization.resultAnimationSuccessBackgroundImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.resultAnimationUnsuccessBackgroundImage {
            faceTecCustomization.resultScreenCustomization.resultAnimationUnsuccessBackgroundImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.customResultAnimationSuccess {
            //faceTecCustomization.resultScreenCustomization.customResultAnimationSuccess = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.customResultAnimationUnsuccess {
            //faceTecCustomization.resultScreenCustomization.customResultAnimationUnsuccess = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.customStaticResultAnimationSuccess {
            //faceTecCustomization.resultScreenCustomization.customStaticResultAnimationSuccess = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.customStaticResultAnimationUnsuccess {
            //faceTecCustomization.resultScreenCustomization.customStaticResultAnimationUnsuccess = unwrapped;
        }
        if let unwrapped = customization.faceTecResultScreenCustomization?.messageFont {
            //faceTecCustomization.resultScreenCustomization.messageFont = unwrapped;
        }
        
        // faceTecGuidanceCustomization ---------------------------------------------------
        
        if let unwrapped = customization.faceTecGuidanceCustomization?.backgroundColors {
            faceTecCustomization.guidanceCustomization.backgroundColors = unwrapped.map { UIColor(hex: $0) };
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.foregroundColor {
            faceTecCustomization.guidanceCustomization.foregroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.headerFont {
            //faceTecCustomization.guidanceCustomization.headerFont = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.subtextFont {
            //faceTecCustomization.guidanceCustomization.subtextFont = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenHeaderFont {
            //faceTecCustomization.guidanceCustomization.readyScreenHeaderFont = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenHeaderTextColor {
            faceTecCustomization.guidanceCustomization.readyScreenHeaderTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenHeaderAttributedString {
            //faceTecCustomization.guidanceCustomization.readyScreenHeaderAttributedString = NSAttributedString(string: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenSubtextFont {
            //faceTecCustomization.guidanceCustomization.readyScreenSubtextFont = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenSubtextTextColor {
            faceTecCustomization.guidanceCustomization.readyScreenSubtextTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenSubtextAttributedString {
            //faceTecCustomization.guidanceCustomization.readyScreenSubtextAttributedString = NSAttributedString(string: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenHeaderFont {
            //faceTecCustomization.guidanceCustomization.retryScreenHeaderFont = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenHeaderTextColor {
            faceTecCustomization.guidanceCustomization.retryScreenHeaderTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenHeaderAttributedString {
            //faceTecCustomization.guidanceCustomization.retryScreenHeaderAttributedString = NSAttributedString(string: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenSubtextFont {
            //faceTecCustomization.guidanceCustomization.retryScreenSubtextFont = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenSubtextTextColor {
            faceTecCustomization.guidanceCustomization.retryScreenSubtextTextColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenSubtextAttributedString {
            //faceTecCustomization.guidanceCustomization.retryScreenSubtextAttributedString = NSAttributedString(string: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonFont {
            //faceTecCustomization.guidanceCustomization.buttonFont = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonTextNormalColor {
            faceTecCustomization.guidanceCustomization.buttonTextNormalColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonBackgroundNormalColor {
            faceTecCustomization.guidanceCustomization.buttonBackgroundNormalColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonTextHighlightColor {
            faceTecCustomization.guidanceCustomization.buttonTextHighlightColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonBackgroundHighlightColor {
            faceTecCustomization.guidanceCustomization.buttonBackgroundHighlightColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonTextDisabledColor {
            faceTecCustomization.guidanceCustomization.buttonTextDisabledColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonBackgroundDisabledColor {
            faceTecCustomization.guidanceCustomization.buttonBackgroundDisabledColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonBorderColor {
            faceTecCustomization.guidanceCustomization.buttonBorderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonBorderWidth {
            faceTecCustomization.guidanceCustomization.buttonBorderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.buttonCornerRadius {
            faceTecCustomization.guidanceCustomization.buttonCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenOvalFillColor {
            faceTecCustomization.guidanceCustomization.readyScreenOvalFillColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenTextBackgroundColor {
            faceTecCustomization.guidanceCustomization.readyScreenTextBackgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.readyScreenTextBackgroundCornerRadius {
            faceTecCustomization.guidanceCustomization.readyScreenTextBackgroundCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenImageBorderColor {
            faceTecCustomization.guidanceCustomization.retryScreenImageBorderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenImageBorderWidth {
            faceTecCustomization.guidanceCustomization.retryScreenImageBorderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenImageCornerRadius {
            faceTecCustomization.guidanceCustomization.retryScreenImageCornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenOvalStrokeColor {
            faceTecCustomization.guidanceCustomization.retryScreenOvalStrokeColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenIdealImage {
            faceTecCustomization.guidanceCustomization.retryScreenIdealImage = UIImage(named: unwrapped)
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenSlideshowImages {
            //faceTecCustomization.guidanceCustomization.retryScreenSlideshowImages = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.retryScreenSlideshowInterval {
            faceTecCustomization.guidanceCustomization.retryScreenSlideshowInterval = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.enableRetryScreenSlideshowShuffle {
            faceTecCustomization.guidanceCustomization.enableRetryScreenSlideshowShuffle = unwrapped;
        }
        if let unwrapped = customization.faceTecGuidanceCustomization?.cameraPermissionsScreenImage {
            faceTecCustomization.guidanceCustomization.cameraPermissionsScreenImage = UIImage(named: unwrapped)
        }
        
        // faceTecFrameCustomization ------------------------------------------------------
        
        if let unwrapped = customization.faceTecFrameCustomization?.borderWidth {
            faceTecCustomization.frameCustomization.borderWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecFrameCustomization?.cornerRadius {
            faceTecCustomization.frameCustomization.cornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecFrameCustomization?.borderColor {
            faceTecCustomization.frameCustomization.borderColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecFrameCustomization?.backgroundColor {
            faceTecCustomization.frameCustomization.backgroundColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecFrameCustomization?.elevation {
            //faceTecCustomization.frameCustomization.shadow = unwrapped;
        }
        
        // faceTecFeedbackCustomization ---------------------------------------------------
        
        if let unwrapped = customization.faceTecFeedbackCustomization?.cornerRadius {
            faceTecCustomization.feedbackCustomization.cornerRadius = unwrapped;
        }
        if let unwrapped = customization.faceTecFeedbackCustomization?.backgroundColors {
            let feedbackBackgroundColorLayer = CAGradientLayer()
            let colors = unwrapped.map { UIColor(hex: $0).cgColor };
            feedbackBackgroundColorLayer.colors = colors
            feedbackBackgroundColorLayer.locations = [0,1]
            feedbackBackgroundColorLayer.startPoint = CGPoint.init(x: 0, y: 0)
            feedbackBackgroundColorLayer.endPoint = CGPoint.init(x: 1, y: 0)
            faceTecCustomization.feedbackCustomization.backgroundColor = feedbackBackgroundColorLayer;
        }
        if let unwrapped = customization.faceTecFeedbackCustomization?.textColor {
            faceTecCustomization.feedbackCustomization.textColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecFeedbackCustomization?.textFont {
            //faceTecCustomization.feedbackCustomization.textFont = unwrapped;
        }
        if let unwrapped = customization.faceTecFeedbackCustomization?.enablePulsatingText {
            faceTecCustomization.feedbackCustomization.enablePulsatingText = unwrapped;
        }
        if let unwrapped = customization.faceTecFeedbackCustomization?.elevation {
            //faceTecCustomization.feedbackCustomization.shadow = unwrapped;
        }
        
        // faceTecOvalCustomization -------------------------------------------------------
        
        if let unwrapped = customization.faceTecOvalCustomization?.strokeWidth {
            faceTecCustomization.ovalCustomization.strokeWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecOvalCustomization?.strokeColor {
            faceTecCustomization.ovalCustomization.strokeColor = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOvalCustomization?.progressStrokeWidth {
            faceTecCustomization.ovalCustomization.progressStrokeWidth = unwrapped;
        }
        if let unwrapped = customization.faceTecOvalCustomization?.progressColor1 {
            faceTecCustomization.ovalCustomization.progressColor1 = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOvalCustomization?.progressColor2 {
            faceTecCustomization.ovalCustomization.progressColor2 = UIColor(hex: unwrapped);
        }
        if let unwrapped = customization.faceTecOvalCustomization?.progressRadialOffset {
            faceTecCustomization.ovalCustomization.progressRadialOffset = unwrapped;
        }
        
        // faceTecCancelButtonCustomization -----------------------------------------------
        
        if let unwrapped = customization.faceTecCancelButtonCustomization?.location {
            //faceTecCustomization.cancelButtonCustomization.location = unwrapped;
        }
        if let unwrapped = customization.faceTecCancelButtonCustomization?.customImage {
            faceTecCustomization.cancelButtonCustomization.customImage = UIImage(named: unwrapped)
        }
        
        // faceTecExitAnimationStyle ------------------------------------------------------
        
        if let unwrapped = customization.faceTecExitAnimationStyle?.animation {
            //faceTecCustomization.exitAnimationStyle.animation = unwrapped;
        }
        return faceTecCustomization
    }
}

