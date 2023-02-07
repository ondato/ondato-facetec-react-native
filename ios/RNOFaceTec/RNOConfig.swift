//
// FaceTec Device SDK config file.
// Auto-generated via the FaceTec SDK Configuration Wizard
//
import UIKit
import Foundation
import FaceTecSDK

class RNOConfig {
    // -------------------------------------
    // REQUIRED
    // Available at https://dev.facetec.com/account
    static var deviceKeyIdentifier: String? = nil
    
    // -------------------------------------
    // REQUIRED
    // The URL to call to process FaceTec SDK Sessions.
    // In Production, you likely will handle network requests elsewhere and without the use of this variable.
    // See https://dev.facetec.com/security-best-practices?link=facetec-server-rest-endpoint-security for more information.
    static var baseURL = "https://api.facetec.com/api/v3.1/biometrics"
    
    // -------------------------------------
    // REQUIRED
    // The FaceScan Encryption Key you define for your application.
    // Please see https://dev.facetec.com/facemap-encryption-keys for more information.
    static var publicFaceScanEncryptionKey =
    "-----BEGIN PUBLIC KEY-----\n" +
    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5PxZ3DLj+zP6T6HFgzzk\n" +
    "M77LdzP3fojBoLasw7EfzvLMnJNUlyRb5m8e5QyyJxI+wRjsALHvFgLzGwxM8ehz\n" +
    "DqqBZed+f4w33GgQXFZOS4AOvyPbALgCYoLehigLAbbCNTkeY5RDcmmSI/sbp+s6\n" +
    "mAiAKKvCdIqe17bltZ/rfEoL3gPKEfLXeN549LTj3XBp0hvG4loQ6eC1E1tRzSkf\n" +
    "GJD4GIVvR+j12gXAaftj3ahfYxioBH7F7HQxzmWkwDyn3bqU54eaiB7f0ftsPpWM\n" +
    "ceUaqkL2DZUvgN0efEJjnWy5y1/Gkq5GGWCROI9XG/SwXJ30BbVUehTbVcD70+ZF\n" +
    "8QIDAQAB\n" +
    "-----END PUBLIC KEY-----"
    
    static var customization: FaceTecCustomization? = nil;
    static var productionKeyText: String? = nil;
    static var sessionToken: String? = nil;
    
    static func initializeFaceTecSDK(completion: @escaping (Bool)->()) {
        NSLog("Using FaceTec version: \(FaceTec.sdk.version)")
        if (deviceKeyIdentifier != nil) {
            if (RNOConfig.productionKeyText != nil) {
                print("Initializing FaceTec in the production mode, with these values: \n" +
                      " - productionKeyText: \(RNOConfig.productionKeyText ?? "nil");\n" +
                      " - deviceKeyIdentifier: \(RNOConfig.deviceKeyIdentifier ?? "nil");\n" +
                      " - faceScanEncryptionKey: \(RNOConfig.publicFaceScanEncryptionKey);\n"
                )
                FaceTec.sdk.initializeInProductionMode(productionKeyText: RNOConfig.productionKeyText!, deviceKeyIdentifier: RNOConfig.deviceKeyIdentifier!, faceScanEncryptionKey: RNOConfig.publicFaceScanEncryptionKey,  completion: { initializationSuccessful in
                    completion(initializationSuccessful)
                })
            } else {
                print("Initializing FaceTec in the development mode, with these values: \n" +
                      " - productionKeyText: \(RNOConfig.productionKeyText ?? "nil");\n" +
                      " - deviceKeyIdentifier: \(RNOConfig.deviceKeyIdentifier ?? "nil");\n" +
                      " - faceScanEncryptionKey: \(RNOConfig.publicFaceScanEncryptionKey);\n"
                )
                FaceTec.sdk.initializeInDevelopmentMode(deviceKeyIdentifier: RNOConfig.deviceKeyIdentifier!, faceScanEncryptionKey: RNOConfig.publicFaceScanEncryptionKey, completion: { initializationSuccessful in
                    completion(initializationSuccessful)
                })
            }
        } else {
            print("Device Key Identifier is REQUIRED!")
            completion(false)
        }
    }
}
