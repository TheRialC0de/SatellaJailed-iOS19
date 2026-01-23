import SwiftUI
import UIKit

@available(iOS 15, *)
final class SatellaController: UIViewController {
    static let shared: SatellaController = .init()
    
    var model: SatellaModel = .shared
    var host: UIView = .init()
    var windows: [UIWindow] = []
    private weak var hostingController: UIHostingController<SatellaView>?
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update frame on rotation/layout changes for all devices including iPhone 17 Pro Max
        view.frame = UIScreen.main.bounds
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Handle safe area changes for Dynamic Island on iPhone 17 Pro Max
        updateHostPosition()
    }
    
    private func setupUI() {
        let size: CGSize = UIScreen.main.bounds.size
        
        // Account for safe area insets (Dynamic Island, notch, home indicator)
        let safeArea = view.safeAreaInsets
        let geoX: Double = size.width * 0.85
        let geoY: Double = max(size.height * 0.5, safeArea.top + 60) // Avoid Dynamic Island
        
        view.frame = CGRect(origin: .zero, size: size)
        
        let tellaVC: UIHostingController = .init(rootView: SatellaView())
        hostingController = tellaVC
        let tapGest: UITapGestureRecognizer = .init(target: self, action: #selector(handleTap))
        let panGest: UIPanGestureRecognizer = .init(target: self, action: #selector(handlePan))
        
        // Use larger hit target for better touch handling on larger screens
        let buttonSize: CGFloat = 40
        host = UIView(frame: CGRect(x: geoX, y: geoY, width: buttonSize, height: buttonSize))
        
        tellaVC.view.frame = CGRect(origin: .zero, size: CGSize(width: buttonSize, height: buttonSize))
        tellaVC.view.backgroundColor = .clear
        host.backgroundColor = .clear
        
        // Ensure proper gesture handling
        tapGest.cancelsTouchesInView = false
        panGest.cancelsTouchesInView = false
        
        host.addGestureRecognizer(tapGest)
        host.addGestureRecognizer(panGest)
        
        host.addSubview(tellaVC.view)
        view.addSubview(host)
    }
    
    private func updateHostPosition() {
        guard host.superview != nil else { return }
        let size = UIScreen.main.bounds.size
        let safeArea = view.safeAreaInsets
        
        // Keep button within safe area bounds
        let minY = safeArea.top + 20
        let maxY = size.height - safeArea.bottom - host.bounds.height - 20
        let minX: CGFloat = 20
        let maxX = size.width - host.bounds.width - 20
        
        host.center.x = min(max(host.center.x, minX + host.bounds.width/2), maxX + host.bounds.width/2)
        host.center.y = min(max(host.center.y, minY + host.bounds.height/2), maxY + host.bounds.height/2)
    }
    
    @objc func handleTap() {
        model.isShowing.toggle()
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        let safeArea = view.safeAreaInsets
        let size = view.bounds.size
        
        // Constrain to safe area for Dynamic Island and home indicator
        let minY = safeArea.top + host.bounds.height/2
        let maxY = size.height - safeArea.bottom - host.bounds.height/2
        let minX = host.bounds.width/2
        let maxX = size.width - host.bounds.width/2
        
        host.center = CGPoint(
            x: min(max(location.x, minX), maxX),
            y: min(max(location.y, minY), maxY)
        )
    }
    
    deinit {
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
    }
}

