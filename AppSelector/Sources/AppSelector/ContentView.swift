import SwiftUI

final class AppListViewModel: ObservableObject {
    @Published var apps: [InstalledApp] = []
    @Published var selectedBundleId: String? = nil
    @Published var errorMessage: String? = nil
    @Published var manualBundleId: String = ""
    @Published var showManualEntry: Bool = false
    @Published var isLoading: Bool = true
    @Published var showPermissionAlert: Bool = false
    @Published var hasCompletedSetup: Bool = false

    init() {
        // Check if user has completed initial setup
        hasCompletedSetup = UserDefaults.standard.bool(forKey: "com.satella.setupComplete")
    }
    
    func completeSetup() {
        UserDefaults.standard.set(true, forKey: "com.satella.setupComplete")
        hasCompletedSetup = true
        load()
    }

    func load() {
        isLoading = true
        
        // Load previously saved selection
        if let saved = InstalledAppsProvider.loadSelected() {
            selectedBundleId = saved
            manualBundleId = saved
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let list = InstalledAppsProvider.fetchInstalledApps()
            DispatchQueue.main.async {
                self.apps = list
                self.isLoading = false
                // Show manual entry option if no apps detected
                if list.isEmpty {
                    self.showManualEntry = true
                }
            }
        }
    }

    func saveSelection() {
        // Use manual entry if provided, otherwise use selected from list
        let bundle = manualBundleId.isEmpty ? selectedBundleId : manualBundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let bundleToSave = bundle, !bundleToSave.isEmpty else {
            errorMessage = "Please select an app or enter a bundle ID"
            return
        }
        
        do {
            try InstalledAppsProvider.saveSelected(bundleId: bundleToSave)
            selectedBundleId = bundleToSave
            errorMessage = "✓ Saved: \(bundleToSave)"
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Welcome/Setup View
struct SetupView: View {
    @EnvironmentObject var vm: AppListViewModel
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "app.badge.checkmark.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Welcome to App Selector")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Select which app you want to use with Satella")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    Button(action: { withAnimation { currentPage = 1 } }) {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .tag(0)
                
                // Page 2: Permissions
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Ready to Go!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PermissionRow(icon: "magnifyingglass", title: "Detect Apps", description: "We'll scan for installed apps", isGranted: true)
                        PermissionRow(icon: "square.and.arrow.down", title: "Save Selection", description: "Store your app choice locally", isGranted: true)
                        PermissionRow(icon: "keyboard", title: "Manual Entry", description: "Enter any bundle ID manually", isGranted: true)
                    }
                    .padding(.horizontal, 30)
                    
                    Text("No special permissions required!")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: { vm.completeSetup() }) {
                        Text("Get Started")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: isGranted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isGranted ? .green : .gray)
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var vm: AppListViewModel

    var body: some View {
        Group {
            if !vm.hasCompletedSetup {
                SetupView()
                    .environmentObject(vm)
            } else {
                MainAppView()
                    .environmentObject(vm)
            }
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var vm: AppListViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Manual Bundle ID Entry Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "keyboard")
                            .foregroundColor(.blue)
                        Text("Bundle ID")
                            .font(.headline)
                        Spacer()
                        Button(action: { withAnimation { vm.showManualEntry.toggle() } }) {
                            Image(systemName: vm.showManualEntry ? "chevron.up" : "chevron.down")
                        }
                    }
                    
                    if vm.showManualEntry {
                        Text("Enter the bundle ID of any app:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("com.example.app", text: $vm.manualBundleId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Loading State
                if vm.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Scanning for apps...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                }
                // App List or Empty State
                else if vm.apps.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "app.badge.checkmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No apps auto-detected")
                            .font(.headline)
                        Text("Enter the bundle ID above to select your app.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Common bundle IDs helper
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Popular Bundle IDs:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            ForEach(commonBundleIds, id: \.0) { bundle in
                                Button(action: { vm.manualBundleId = bundle.0 }) {
                                    HStack {
                                        Text(bundle.1)
                                            .font(.caption)
                                        Spacer()
                                        Text(bundle.0)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    List(vm.apps, id: \.self) { app in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(app.name).font(.headline)
                                Text(app.bundleId).font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            if vm.selectedBundleId == app.bundleId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.selectedBundleId = app.bundleId
                            vm.manualBundleId = app.bundleId
                        }
                    }
                }

                // Bottom Action Bar
                VStack(spacing: 8) {
                    if let current = vm.selectedBundleId, !current.isEmpty {
                        HStack {
                            Text("Current:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(current)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Button(action: { vm.load() }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Refresh")
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button(action: { vm.saveSelection() }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Save")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if let msg = vm.errorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(msg.hasPrefix("✓") ? .green : .red)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("App Selector")
        }
        .onAppear { vm.load() }
    }
    
    // Helper bundle IDs shown when no apps detected
    private var commonBundleIds: [(String, String)] {
        [
            ("com.supercell.clashofclans", "Clash of Clans"),
            ("com.supercell.clashroyale", "Clash Royale"),
            ("com.roblox.robloxmobile", "Roblox"),
            ("com.mojang.minecraftpe", "Minecraft"),
            ("com.miHoYo.GenshinImpact", "Genshin Impact"),
        ]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppListViewModel())
    }
}
