// Welcome to the minimized FaceTec Device SDK code to launch User Sessions and retrieve 3D FaceScans (for further processing)!
// This file removes comment annotations, as well as networking calls,
// in an effort to demonstrate how little code is needed to get the FaceTec Device SDKs to work.

// NOTE: This example DOES NOT perform a secure Enrollment.  To perform a secure Enrollment, you need to actually make an API call.
// Please see the EnrollmentProcessor file for a complete demonstration using the FaceTec Testing API.

import UIKit
import Foundation
import FaceTecSDK

class RNOProcessor: NSObject, FaceTecFaceScanProcessorDelegate {
    var success = false
    var fromViewController: RNOFaceTecViewController!
    var state: [AnyHashable: Any] = ["status": RNOUtilities.getStatus(status: RNOStatus.dormant), "message": "Nothing happened yet"]
    
    init(fromViewController: RNOFaceTecViewController, sessionToken: String) {
        self.fromViewController = fromViewController
        super.init()
        
        // Core FaceTec Device SDK code that starts the User Session.
        let sessionViewController = FaceTec.sdk.createSessionVC(faceScanProcessorDelegate: self, sessionToken: sessionToken)
        fromViewController.present(sessionViewController, animated: true, completion: nil)
    }
    
    func processSessionWhileFaceTecSDKWaits(sessionResult: FaceTecSessionResult, faceScanResultCallback: FaceTecFaceScanResultCallback) {
        
        // Normally a User will complete a Session.  This checks to see if there was a cancellation, timeout, or some other non-success case.
        if sessionResult.status != FaceTecSessionStatus.sessionCompletedSuccessfully {
            state["status"] = RNOUtilities.getStatus(status: RNOStatus.cancelled)
            state["message"] = "Early exit encountered"
            faceScanResultCallback.onFaceScanResultCancel()
            return
        }
        
        // IMPORTANT:  FaceTecSDK.FaceTecSessionStatus.SessionCompletedSuccessfully DOES NOT mean the Liveness Check was Successful.
        // It simply means the User completed the Session and a 3D FaceScan was created.  You still need to perform the Liveness Check on your Servers.
        
        // These are the core parameters
        var load: [String : Any] = [:]
        load["faceScanBase64"] = sessionResult.faceScanBase64
        load["auditImagesBase64"] = sessionResult.auditTrailCompressedBase64
        load["lowQualityAuditTrailImagesBase64"] = sessionResult.lowQualityAuditTrailCompressedBase64
        load["sessionId"] = sessionResult.sessionId
        load["userAgent"] = FaceTec.sdk.createFaceTecAPIUserAgentString(sessionResult.sessionId)
        
        if let json = try? JSONSerialization.data(withJSONObject: load, options: []) {
            state["status"] = RNOUtilities.getStatus(status: RNOStatus.succeeded)
            state["message"] = "Ready for the next steps"
            state["load"] = String(data: json, encoding: String.Encoding.utf8)
        } else {
            state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
            state["message"] = "Couldn't parse the data"
        }
        
        // DEVELOPER TODOS:
        // 1.  Call your own API with the above data and pass into the Server SDK
        // 2.  If the Server SDK successfully processes the data, call onFaceScanResultProceedToNextStep(scanResultBlob), passing in the generated scanResultBlob to the parameter.
        //     If onFaceScanResultProceedToNextStep(scanResultBlob) returns as true, the Session was successful and onFaceTecSDKCompletelyDone() will be called next.
        //     If onFaceScanResultProceedToNextStep(scanResultBlob) returns as false, the Session will be proceeding to a retry of the FaceScan.
        // 3.  onFaceScanResultCancel() is provided in case you detect issues with your own API, such as errors processing and returning the scanResultBlob.
        // 4.  onFaceScanUploadProgress(yourUploadProgressFloat) is provided to control the Progress Bar.
        
        // faceScanResultCallback.onFaceScanResultProceedToNextStep(scanResultBlob)
        faceScanResultCallback.onFaceScanResultCancel()
        // faceScanResultCallback.onFaceScanUploadProgress(yourUploadProgressFloat)
    }
    
    func onFaceTecSDKCompletelyDone() {
        //
        // DEVELOPER NOTE:  onFaceTecSDKCompletelyDone() is called after the Session has completed or you signal the FaceTec SDK with cancel().
        // Calling a custom function on the Sample App Controller is done for demonstration purposes to show you that here is where you get control back from the FaceTec SDK.
        //
        
        // In your code, you will handle what to do after the Enrollment is successful here.
        // In our example code here, to keep the code in this class simple, we will call a static method on another class to update the Sample App UI.
        self.fromViewController.onComplete()
    }
    
    func isSuccess() -> Bool {
        return success
    }
    
    func getLastState() -> [AnyHashable: Any] {
        return state;
    }
}
