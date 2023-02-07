// Welcome to the FaceTec Sample App
// This sample demonstrates Initialization, Liveness Check, Enrollment, Authentication, Photo ID Match, Customizing the UX, and Getting Audit Trail Images.
// Please use our technical support form to submit questions and issue reports:  https://dev.facetec.com/

import UIKit
import FaceTecSDK
import LocalAuthentication

class RNOFaceTecViewController: UIViewController, URLSessionDelegate {
    var latestSessionResult: FaceTecSessionResult!
    var latestIDScanResult: FaceTecIDScanResult!
    var utils: RNOUtilities!
    var latestProcessor: RNOProcessor!
    var latestServerResult: [String: AnyObject]!
    
    init(bundle: Bundle) {
        super.init(nibName: nil, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure initial look and feel of the Sample App
        utils = RNOUtilities(vc: self)
        
        // Initialize FaceTec SDK
        RNOConfig.initializeFaceTecSDK(completion: { initializationSuccessful in
            if(initializationSuccessful) {
                RNOUtilities.updateState(event: ["status": RNOUtilities.getStatus(status: RNOStatus.initialized)])
                
                if (RNOConfig.sessionToken != nil) {
                    self.initializeProcessor(sessionToken: RNOConfig.sessionToken!)
                } else {
                    self.getSessionToken() { token in
                        self.initializeProcessor(sessionToken: token)
                    }
                }
            }
            else {
                // Displays the FaceTec SDK Status to text field if init failed
                //self.utils.displayStatus(statusString: "\(FaceTec.sdk.description(for: FaceTec.sdk.getStatus()))")
                RNOUtilities.updateState(event: ["status": RNOUtilities.getStatus(status: RNOStatus.failed), "message": "Initialization failed, check your configuration properties"])
            }
        })
        
        // Set your FaceTec Device SDK Customizations.
        utils.setUpTheme()
        
        // Set the sound files that are to be used for Vocal Guidance.
        RNOUtilities.setVocalGuidanceSoundFiles()
        utils.setUpVocalGuidancePlayers()
        
        // Set the strings to be used for group names, field names, and placeholder texts for the FaceTec ID Scan User OCR Confirmation Screen.
        RNOUtilities.setOCRLocalization()
    }
    
    func initializeProcessor(sessionToken: String) {
        // Get a Session Token from the FaceTec SDK, then start the face capture process.
        self.latestProcessor = RNOProcessor(fromViewController: self, sessionToken: sessionToken)
    }
    
    // When the FaceTec SDK is completely done, you receive control back here.
    // Since you have already handled all results in your Processor code, how you proceed here is up to you and how your App works.
    // In general, there was either a Success, or there was some other case where you cancelled out.
    func onComplete() {
        RNOUtilities.updateState(event: self.latestProcessor.getLastState())
    }
    
    func getSessionToken(sessionTokenCallback: @escaping (String) -> ()) {
        let endpoint = RNOConfig.baseURL + "/session-token"
        let request = NSMutableURLRequest(url: NSURL(string: endpoint)! as URL)
        request.httpMethod = "GET"
        // Required parameters to interact with the FaceTec Managed Testing API.
        request.addValue(RNOConfig.deviceKeyIdentifier!, forHTTPHeaderField: "X-Device-Key")
        request.addValue(FaceTec.sdk.createFaceTecAPIUserAgentString(""), forHTTPHeaderField: "User-Agent")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            // Ensure the data object is not nil otherwise callback with empty dictionary.
            guard let data = data else {
                print("Exception raised while attempting HTTPS call.")
                self.utils.handleErrorGettingServerSessionToken()
                return
            }
            if let responseJSONObj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                if((responseJSONObj["sessionToken"] as? String) != nil)
                {
                    sessionTokenCallback(responseJSONObj["sessionToken"] as! String)
                    return
                }
                else {
                    print("Exception raised while attempting HTTPS call.")
                    self.utils.handleErrorGettingServerSessionToken()
                }
            }
        })
        task.resume()
    }
}
