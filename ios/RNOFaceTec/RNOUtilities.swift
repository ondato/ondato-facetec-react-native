import Foundation
import UIKit
import FaceTecSDK
import AVFoundation

class RNOUtilities: NSObject, FaceTecCustomAnimationDelegate {
    // Reference to app's main view controller
    let faceTecVC: RNOFaceTecViewController!
    var themeTransitionTextTimer: Timer!
    var networkIssueDetected = false
    var vocalGuidanceOnPlayer: AVAudioPlayer!
    var vocalGuidanceOffPlayer: AVAudioPlayer!
    
    static var vocalGuidanceMode: RNOVocalGuidanceMode!
    static var onUpdate: RCTBubblingEventBlock?
    static var bundle: Bundle {
        let bundle = Bundle.main
        return Bundle(url: bundle.url(forResource: "RNOFaceTec",
                                      withExtension: "bundle")!)!
    }
    
    init(vc: RNOFaceTecViewController) {
        faceTecVC = vc
    }
    
    static func updateState(event: [AnyHashable: Any]) {
        if onUpdate != nil {
            self.onUpdate!(event)
        }
    }
    
    static func getStatus(status: RNOStatus) -> String {
        var result = "Unknown"
        switch status {
        case .dormant:
            result = "Not ready"
        case .initialized:
            result = "Ready"
        case .failed:
            result = "Failed"
        case .cancelled:
            result = "Cancelled"
        case .succeeded:
            result = "Succeeded"
            
        }
        return result
    }
    
    func handleErrorGettingServerSessionToken() {
        networkIssueDetected = true
        RNOUtilities.updateState(event: ["status": RNOUtilities.getStatus(status: RNOStatus.failed), "message": "Session could not be started due to an unexpected issue during the network request."])
    }
    
    func displayStatus(statusString: String) {
        DispatchQueue.main.async {
            print(statusString)
        }
    }
    
    func showAuditTrailImages() {
        var auditTrailAndIDScanImages: [UIImage] = []
        let latestFaceTecSessionResult = faceTecVC.latestSessionResult
        let latestFaceTecIDScanResult = faceTecVC.latestIDScanResult
        
        // Update audit trail.
        if latestFaceTecSessionResult?.auditTrailCompressedBase64 != nil {
            for compressedBase64EncodedAuditTrailImage in (latestFaceTecSessionResult?.auditTrailCompressedBase64)! {
                let dataDecoded : Data = Data(base64Encoded: compressedBase64EncodedAuditTrailImage, options: .ignoreUnknownCharacters)!
                let decodedimage = UIImage(data: dataDecoded)
                auditTrailAndIDScanImages.append(decodedimage!)
            }
        }
        
        if latestFaceTecIDScanResult != nil
            && latestFaceTecIDScanResult?.frontImagesCompressedBase64 != nil
            && (latestFaceTecIDScanResult?.frontImagesCompressedBase64?.count)! > 0
        {
            let dataDecoded : Data = Data(base64Encoded: (latestFaceTecIDScanResult?.frontImagesCompressedBase64?[0])!, options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            auditTrailAndIDScanImages.append(decodedimage!)
        }
        
        if auditTrailAndIDScanImages.count == 0 {
            displayStatus(statusString: "No audit trail images available.")
            return
        }
        for auditImage in auditTrailAndIDScanImages.reversed() {
            addDismissableImageToInterface(image: auditImage)
        }
    }
    
    @objc func dismissImageView(tap: UITapGestureRecognizer){
        let tappedImage = tap.view!
        tappedImage.removeFromSuperview()
    }
    
    // Place a UIImage onto the main interface in a stack that can be popped by tapping on the image
    func addDismissableImageToInterface(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.frame = UIScreen.main.bounds
        
        // Resize image to better fit device's display
        // Remove this option to view image full screen
        let screenSize = UIScreen.main.bounds
        let ratio = screenSize.width / image.size.width
        let size = (image.size).applying(CGAffineTransform(scaleX: 0.5 * ratio, y: 0.5 * ratio))
        let hasAlpha = false
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = scaledImage
        imageView.contentMode = .center
        
        // Tap on image to dismiss view
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissImageView(tap:)))
        imageView.addGestureRecognizer(tap)
        
        faceTecVC.view.addSubview(imageView)
    }
    
    func setUpTheme() {
        // Set this class as the delegate to handle the FaceTecCustomAnimationDelegate methods. This delegate needs to be applied to the current FaceTecCustomization object before starting a new Session in order to use FaceTecCustomAnimationDelegate methods to provide a new instance of a custom UIView that will be displayed for the method-specified animation.
        if(RNOConfig.customization!.customAnimationDelegate == nil) {
            RNOConfig.customization!.customAnimationDelegate = self
            RNOUtilities.setVocalGuidanceSoundFiles()
            FaceTec.sdk.setCustomization(RNOConfig.customization!)
            FaceTec.sdk.setLowLightCustomization(RNOConfig.customization!)
            FaceTec.sdk.setDynamicDimmingCustomization(RNOConfig.customization!)
        }
    }
    
    
    func setUpVocalGuidancePlayers() {
        guard let vocalGuidanceOnUrl = RNOUtilities.bundle.url(forResource: "vocal_guidance_on", withExtension: "mp3") else { return }
        guard let vocalGuidanceOffUrl = RNOUtilities.bundle.url(forResource: "vocal_guidance_off", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            vocalGuidanceOnPlayer = try AVAudioPlayer(contentsOf: vocalGuidanceOnUrl)
            vocalGuidanceOffPlayer = try AVAudioPlayer(contentsOf: vocalGuidanceOffUrl)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    public static func setVocalGuidanceSoundFiles() {
        RNOConfig.customization!.vocalGuidanceCustomization.pleaseFrameYourFaceInTheOvalSoundFile = bundle.path(forResource: "please_frame_your_face_sound_file", ofType: "mp3") ?? ""
        RNOConfig.customization!.vocalGuidanceCustomization.pleaseMoveCloserSoundFile = bundle.path(forResource: "please_move_closer_sound_file", ofType: "mp3") ?? ""
        RNOConfig.customization!.vocalGuidanceCustomization.pleaseRetrySoundFile = bundle.path(forResource: "please_retry_sound_file", ofType: "mp3") ?? ""
        RNOConfig.customization!.vocalGuidanceCustomization.uploadingSoundFile = bundle.path(forResource: "uploading_sound_file", ofType: "mp3") ?? ""
        RNOConfig.customization!.vocalGuidanceCustomization.facescanSuccessfulSoundFile = bundle.path(forResource: "facescan_successful_sound_file", ofType: "mp3") ?? ""
        RNOConfig.customization!.vocalGuidanceCustomization.pleasePressTheButtonToStartSoundFile = bundle.path(forResource: "please_press_button_sound_file", ofType: "mp3") ?? ""
        
        switch(RNOUtilities.vocalGuidanceMode) {
        case .off:
            RNOConfig.customization!.vocalGuidanceCustomization.mode = FaceTecVocalGuidanceMode.noVocalGuidance
        case .minimal:
            RNOConfig.customization!.vocalGuidanceCustomization.mode = FaceTecVocalGuidanceMode.minimalVocalGuidance
        case .full:
            RNOConfig.customization!.vocalGuidanceCustomization.mode = FaceTecVocalGuidanceMode.fullVocalGuidance
        default: break
        }
    }
    
    public static func setOCRLocalization() {
        // Set the strings to be used for group names, field names, and placeholder texts for the FaceTec ID Scan User OCR Confirmation Screen.
        // DEVELOPER NOTE: For this demo, we are using the template json file, 'FaceTec_OCR_Customization.json,' as the parameter in calling this API.
        // For the configureOCRLocalization API parameter, you may use any dictionary object that follows the same structure and key naming as the template json file, 'FaceTec_OCR_Customization.json'.
        if let path = bundle.path(forResource: "FaceTec_OCR_Customization", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
                if let jsonDictionary = jsonObject as? Dictionary<String, AnyObject> {
                    FaceTec.sdk.configureOCRLocalization(dictionary: jsonDictionary)
                }
            } catch {
                print("Error loading JSON for OCR Localization")
            }
        }
    }
}
