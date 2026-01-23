import SwiftUI

@available(iOS 15, *)
struct PreferencesView: View {
    @AppStorage("tella_isEnabled") private var isEnabled: Bool = true
    @AppStorage("tella_isGesture") private var isGesture: Bool = true
    @AppStorage("tella_isHidden") private var isHidden: Bool = false
    @AppStorage("tella_isObserver") private var isObserver: Bool = false
    @AppStorage("tella_isPriceZero") private var isPriceZero: Bool = false
    @AppStorage("tella_isReceipt") private var isReceipt: Bool = false
    @AppStorage("tella_isStealth") private var isStealth: Bool = false
    
    @Binding var isShowing: Bool
    @State private var isShowingOptions: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private let satellaColor = Color(red: 0.80, green: 0.63, blue: 0.87)
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 16) {
                    // Logo
                    satellaColor
                        .mask { SatellaShapeView() }
                        .frame(width: 60, height: 60)
                        .padding(.top, 20)
                    
                    Text("Satella Jailed")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("iOS 12-19 • v2.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    // Settings toggles
                    VStack(spacing: 12) {
                        SettingsToggle(title: "Enabled", subtitle: "Core IAP bypass", isOn: $isEnabled)
                        SettingsToggle(title: "3-Finger Gesture", subtitle: "Show/hide Satella button", isOn: $isGesture)
                        SettingsToggle(title: "Hide Permanently", subtitle: "Remove floating button", isOn: $isHidden)
                        
                        Divider().padding(.vertical, 4)
                        
                        Text("Advanced Options")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        SettingsToggle(title: "Observer", subtitle: "Hook payment observer", isOn: $isObserver)
                        SettingsToggle(title: "Zero Price", subtitle: "Show 0.00 for prices", isOn: $isPriceZero)
                        SettingsToggle(title: "Receipt", subtitle: "Generate fake receipts", isOn: $isReceipt)
                        SettingsToggle(title: "Stealth", subtitle: "Hide from detection", isOn: $isStealth)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
                    .padding(.horizontal)
                    
                    // Apply button
                    Button(action: { isShowingOptions.toggle() }) {
                        Text("Apply")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .fill(satellaColor)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowing = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .confirmationDialog("Select an action", isPresented: $isShowingOptions, titleVisibility: .visible) {
                Button("Apply Changes (Restart App)", role: .destructive) {
                    // Graceful exit instead of abort() for iOS 19
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        exit(0)
                    }
                }
                
                Button("Hide Satella") {
                    isShowing = false
                    SatellaController.shared.host.removeFromSuperview()
                }
                
                Button("View Source / FAQ") {
                    if let url = URL(string: "https://github.com/Paisseon/SatellaJailed") {
                        UIApplication.shared.open(url)
                    }
                }
                
                Button("Cancel", role: .cancel) { }
            }
        }
        .tint(satellaColor)
    }
}

@available(iOS 15, *)
private struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
