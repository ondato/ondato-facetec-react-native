//
//  RNOCustomization.swift
//  RNOFaceTec
//
//  Created by Darius Rainys on 2022-11-24.
//  Copyright © 2022 Facebook. All rights reserved.
//

import FaceTecSDK

typealias Color = String
typealias Font = String
typealias Image = String
typealias Animation = Int

struct RNOCustomization: Codable {
    struct FaceTecSessionTimerCustomization: Codable {
        var livenessCheckNoInteractionTimeout: Int32?
        var idScanNoInteractionTimeout: Int32?
    }
    
    struct FaceTecOCRConfirmationCustomization: Codable {
        var backgroundColors: [Color]?
        var mainHeaderDividerLineColor: Color?
        var mainHeaderDividerLineWidth: Int32?
        var mainHeaderFont: Font?
        var mainHeaderTextColor: Color?
        var sectionHeaderFont: Font?
        var sectionHeaderTextColor: Color?
        var fieldLabelFont: Font?
        var fieldLabelTextColor: Color?
        var fieldValueFont: Font?
        var fieldValueTextColor: Color?
        var inputFieldBackgroundColor: Color?
        var inputFieldFont: Font?
        var inputFieldTextColor: Color?
        var inputFieldBorderColor: Color?
        var inputFieldBorderWidth: Int32?
        var inputFieldCornerRadius: Int32?
        var inputFieldPlaceholderFont: Font?
        var inputFieldPlaceholderTextColor: Color?
        var showInputFieldBottomBorderOnly: Bool?
        var buttonFont: Font?
        var buttonTextNormalColor: Color?
        var buttonBackgroundNormalColor: Color?
        var buttonTextHighlightColor: Color?
        var buttonBackgroundHighlightColor: Color?
        var buttonTextDisabledColor: Color?
        var buttonBackgroundDisabledColor: Color?
        var buttonBorderColor: Color?
        var buttonBorderWidth: Int32?
        var buttonCornerRadius: Int32?
    }
    
    struct FaceTecIDScanCustomization: Codable {
        var showSelectionScreenBrandingImage: Bool?
        var selectionScreenBrandingImage: Image?
        var showSelectionScreenDocumentImage: Bool?
        var selectionScreenDocumentImage: Image?
        var captureScreenBackgroundColor: Color?
        var captureFrameStrokeColor: Color?
        var captureFrameStrokeWidth: Int32?
        var captureFrameCornerRadius: Int32?
        var activeTorchButtonImage: Image?
        var inactiveTorchButtonImage: Image?
        var selectionScreenBackgroundColors: [Color]?
        var selectionScreenForegroundColor: Color?
        var reviewScreenBackgroundColors: [Color]?
        var reviewScreenForegroundColor: Color?
        var reviewScreenTextBackgroundColor: Color?
        var reviewScreenTextBackgroundBorderColor: Color?
        var reviewScreenTextBackgroundBorderWidth: Int32?
        var reviewScreenTextBackgroundCornerRadius: Int32?
        var captureScreenForegroundColor: Color?
        var captureScreenTextBackgroundColor: Color?
        var captureScreenTextBackgroundBorderColor: Color?
        var captureScreenTextBackgroundBorderWidth: Int32?
        var captureScreenTextBackgroundCornerRadius: Int32?
        var captureScreenFocusMessageTextColor: Color?
        var captureScreenFocusMessageFont: Font?
        var headerFont: Font?
        var subtextFont: Font?
        var buttonFont: Font?
        var buttonTextNormalColor: Color?
        var buttonBackgroundNormalColor: Color?
        var buttonTextHighlightColor: Color?
        var buttonBackgroundHighlightColor: Color?
        var buttonTextDisabledColor: Color?
        var buttonBackgroundDisabledColor: Color?
        var buttonBorderColor: Color?
        var buttonBorderWidth: Int32?
        var buttonCornerRadius: Int32?
        
        var customNFCStartingAnimation: Animation?
        var customNFCScanningAnimation: Animation?
        var customNFCCardStartingAnimation: Animation?
        var customNFCCardScanningAnimation: Animation?
        var customNFCSkipOrErrorAnimation: Animation?
        var customStaticNFCStartingAnimation: Animation?
        var customStaticNFCScanningAnimation: Animation?
        var customStaticNFCSkipOrErrorAnimation: Animation?
    }
    
    struct FaceTecOverlayCustomization: Codable {
        var backgroundColor: String?
        var brandingImage: Image?
        var showBrandingImage: Bool?
    }
    
    struct FaceTecResultScreenCustomization: Codable{
        var  animationRelativeScale: Int32?
        var  foregroundColor: Color?
        var  backgroundColors: [Color]?
        var  activityIndicatorColor: Color?
        var  customActivityIndicatorImage: Image?
        var  customActivityIndicatorRotationInterval: Int32?
        var  customActivityIndicatorAnimation: Animation?
        var  showUploadProgressBar: Bool?
        var  uploadProgressFillColor: Color?
        var  uploadProgressTrackColor: Color?
        var  resultAnimationBackgroundColor: Color?
        var  resultAnimationForegroundColor: Color?
        var  resultAnimationSuccessBackgroundImage: Image?
        var  resultAnimationUnsuccessBackgroundImage: Image?
        var  customResultAnimationSuccess: Animation?
        var  customResultAnimationUnsuccess: Animation?
        var  customStaticResultAnimationSuccess: Animation?
        var  customStaticResultAnimationUnsuccess: Animation?
        var  messageFont: Font?
    }
    
    struct FaceTecGuidanceCustomization: Codable{
        var  backgroundColors: [Color]?
        var  foregroundColor: Color?
        var  headerFont: Font?
        var  subtextFont: Font?
        var  readyScreenHeaderFont: Font?
        var  readyScreenHeaderTextColor: Color?
        var  readyScreenHeaderAttributedString: String?
        var  readyScreenSubtextFont: Font?
        var  readyScreenSubtextTextColor: Color?
        var  readyScreenSubtextAttributedString: String?
        var  retryScreenHeaderFont: Font?
        var  retryScreenHeaderTextColor: Color?
        var  retryScreenHeaderAttributedString: String?
        var  retryScreenSubtextFont: Font?
        var  retryScreenSubtextTextColor: Color?
        var  retryScreenSubtextAttributedString: String?
        var  buttonFont: Font?
        var  buttonTextNormalColor: Color?
        var  buttonBackgroundNormalColor: Color?
        var  buttonTextHighlightColor: Color?
        var  buttonBackgroundHighlightColor: Color?
        var  buttonTextDisabledColor: Color?
        var  buttonBackgroundDisabledColor: Color?
        var  buttonBorderColor: Color?
        var  buttonBorderWidth: Int32?
        var  buttonCornerRadius: Int32?
        var  readyScreenOvalFillColor: Color?
        var  readyScreenTextBackgroundColor: Color?
        var  readyScreenTextBackgroundCornerRadius: Int32?
        var  retryScreenImageBorderColor: Color?
        var  retryScreenImageBorderWidth: Int32?
        var  retryScreenImageCornerRadius: Int32?
        var  retryScreenOvalStrokeColor: Color?
        var  retryScreenIdealImage: Image?
        var  retryScreenSlideshowImages: [Image]?
        var  retryScreenSlideshowInterval: Int32?
        var  enableRetryScreenSlideshowShuffle: Bool?
        var  cameraPermissionsScreenImage: Image?
    }
    
    struct FaceTecFrameCustomization: Codable{
        var borderWidth: Int32?
        var cornerRadius: Int32?
        var borderColor: String?
        var backgroundColor: String?
        var elevation: Int32?
    }
    
    struct FaceTecFeedbackCustomization: Codable {
        var cornerRadius: Int32?
        var backgroundColors: [Color]?
        var textColor: Color?
        var textFont: Font?
        var enablePulsatingText: Bool?
        var elevation: Int32?
    }
    
    struct FaceTecOvalCustomization: Codable {
        var strokeWidth: Int32?
        var strokeColor: Color?
        var progressStrokeWidth: Int32?
        var progressColor1: Color?
        var progressColor2: Color?
        var progressRadialOffset: Int32?
    }
    
    
    struct FaceTecCancelButtonCustomization: Codable {
        var location: String?
        var customImage: String?
    }
    
    struct FaceTecExitAnimationStyle: Codable {
        var animation: String?
    }
    
    var faceTecSessionTimerCustomization:       FaceTecSessionTimerCustomization?
    var faceTecOCRConfirmationCustomization:    FaceTecOCRConfirmationCustomization?
    var faceTecIDScanCustomization:             FaceTecIDScanCustomization?
    var faceTecOverlayCustomization:            FaceTecOverlayCustomization?
    var faceTecResultScreenCustomization:       FaceTecResultScreenCustomization?
    var faceTecGuidanceCustomization:           FaceTecGuidanceCustomization?
    var faceTecFrameCustomization:              FaceTecFrameCustomization?
    var faceTecFeedbackCustomization:           FaceTecFeedbackCustomization?
    var faceTecOvalCustomization:               FaceTecOvalCustomization?
    var faceTecCancelButtonCustomization:       FaceTecCancelButtonCustomization?
    var faceTecExitAnimationStyle:              FaceTecExitAnimationStyle?
}
