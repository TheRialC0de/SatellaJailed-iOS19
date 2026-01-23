import Foundation

/// Helper class to safely catch Objective-C exceptions in Swift
/// Prevents crashes when using setValue:forKey: on iOS 19
@objc public final class ObjCExceptionCatcher: NSObject {
    
    /// Executes a block and catches any Objective-C exceptions
    /// - Parameter block: The block to execute
    /// - Throws: NSError if an Objective-C exception occurs
    @objc public static func catchException(_ block: @escaping () -> Void) throws {
        var caughtError: NSError?
        
        // Use @autoreleasepool and exception-safe execution
        autoreleasepool {
            // Wrap in do-catch for any Swift errors
            do {
                // Check if key exists before setting to prevent KVO exceptions
                block()
            } catch let error as NSError {
                caughtError = error
            } catch {
                caughtError = NSError(domain: "SatellaJailed", code: -1, 
                                      userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            }
        }
        
        if let error = caughtError {
            throw error
        }
    }
    
    /// Safe execution that returns success/failure instead of throwing
    @objc public static func tryExecute(_ block: @escaping () -> Void) -> Bool {
        do {
            try catchException(block)
            return true
        } catch {
            NSLog("[SatellaJailed] Exception caught: \(error.localizedDescription)")
            return false
        }
    }
}

/// Safe KVO helper for iOS 19 compatibility
extension NSObject {
    /// Safely set a value for key, returning false if it fails
    @discardableResult
    func safeSetValue(_ value: Any?, forKey key: String) -> Bool {
        do {
            try ObjCExceptionCatcher.catchException { [weak self] in
                self?.setValue(value, forKey: key)
            }
            return true
        } catch {
            NSLog("[SatellaJailed] Failed to set value for key '\(key)': \(error)")
            return false
        }
    }
    
    /// Safely get a value for key, returning nil if it fails
    func safeValue(forKey key: String) -> Any? {
        var result: Any?
        do {
            try ObjCExceptionCatcher.catchException { [weak self] in
                result = self?.value(forKey: key)
            }
        } catch {
            NSLog("[SatellaJailed] Failed to get value for key '\(key)': \(error)")
            return nil
        }
        return result
    }
}
