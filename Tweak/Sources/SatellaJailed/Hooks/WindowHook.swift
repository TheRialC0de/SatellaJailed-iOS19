import Jinx
import UIKit

@available(iOS 15, *)
struct WindowHook: Hook {
    typealias T = @convention(c) (UIWindow, Selector) -> Void
    
    let cls: AnyClass? = UIWindow.self
    let sel: Selector = #selector(UIWindow.becomeKey)
    let replace: T = { obj, sel in
        orig(obj, sel)
        
        // Thread-safe check for window registration
        DispatchQueue.main.async {
            guard !SatellaController.shared.windows.contains(where: { $0 === obj }) else {
                return
            }
            
            let gesture = BindableGesture {
                guard !Preferences.isHidden else {
                    return
                }
                
                // Use modern window scene API compatible with iOS 15-19
                guard let windowScene = obj.windowScene,
                      let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
                      let rootVC = keyWindow.rootViewController else {
                    return
                }
                rootVC.add(SatellaController.shared)
            }
            
            gesture.numberOfTouchesRequired = 3
            obj.addGestureRecognizer(gesture)
            
            // Use weak reference to avoid retain cycles
            SatellaController.shared.windows.append(obj)
        }
    }
}
