import SwiftUI

@available(iOS 15, *)
struct SatellaShapeView: UIViewRepresentable {
    var size: CGFloat = 100
    
    func makeUIView(context: Context) -> UIView {
        let view = SatellaShape(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.frame.size = CGSize(width: size, height: size)
        uiView.setNeedsDisplay()
    }
}

@available(iOS 15, *)
struct SatellaView: View {
    @StateObject var model: SatellaModel = .shared
    
    private let buttonSize: CGFloat = 40  // Larger for iPhone 17 Pro Max
    private let satellaColor = Color(red: 0.80, green: 0.63, blue: 0.87)
    
    var body: some View {
        Button {
            model.isShowing.toggle()
        } label: {
            satellaColor
                .mask {
                    SatellaShapeView(size: buttonSize)
                }
                .shadow(color: satellaColor.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .frame(width: buttonSize, height: buttonSize)
        .contentShape(Rectangle())  // Improve hit testing
        .sheet(isPresented: $model.isShowing) {
            PreferencesView(isShowing: $model.isShowing)
                .presentationDetents([.medium, .large])  // iOS 16+ adaptive sheet
                .presentationDragIndicator(.visible)
        }
    }
}
