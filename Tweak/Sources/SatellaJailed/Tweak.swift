import Jinx
import UIKit

struct Tweak {
    static func ctor() {
        // Wrap all hooks in autoreleasepool for memory safety
        autoreleasepool {
            // Core hooks - always enabled
            CanPayHook().hook()
            DelegateHook().hook()
            TransactionHook().hook()
            
            // Payment queue hooks for broader compatibility
            RestorePurchasesHook().hook()
            FinishTransactionHook().hook()
            AddPaymentHook().hook()
            TransactionDownloadsHook().hook()
            
            // Optional hooks based on preferences
            if Preferences.isPriceZero { ProductHook().hook() }
            if Preferences.isObserver { ObserverHook().hook() }
            if Preferences.isStealth { DyldHook().hook() }
            
            if Preferences.isReceipt {
                ReceiptHook().hook()
                URLHook().hook()
                URLSessionDataHook().hook()
                ReceiptRefreshHook().hook()
            }
            
            // iOS 13+ hooks
            if #available(iOS 13, *) {
                // Storefront hook for region checks
            }
            
            // iOS 15+ StoreKit 2 support
            if #available(iOS 15, *) {
                StoreKit2Hooks.setupHooks()
            }
        }
        
        if #available(iOS 15, *) {
            if Preferences.isGesture {
                WindowHook().hook()
            }
            
            guard !Preferences.isHidden else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Use modern window scene API for iOS 15+/19
                guard let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                      let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
                      let rootVC = keyWindow.rootViewController else {
                    return
                }
                rootVC.add(SatellaController.shared)
            }
        }
    }
}

@_cdecl("jinx_entry")
func jinxEntry() {
    // Catch any initialization crashes
    do {
        Tweak.ctor()
    } catch {
        NSLog("[SatellaJailed] Initialization error: \(error)")
    }
}
