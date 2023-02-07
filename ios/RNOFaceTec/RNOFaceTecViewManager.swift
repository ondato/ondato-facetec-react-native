import Foundation

@objc(RNOFaceTecViewManager)
class RNOFaceTecViewManager: RCTViewManager {
    
    override func view() -> (RNOFaceTecView) {
        return RNOFaceTecView()
    }
    
    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
    }
}

