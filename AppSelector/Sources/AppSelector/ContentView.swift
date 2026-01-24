import SwiftUI

final class AppListViewModel: ObservableObject {
    @Published var apps: [InstalledApp] = []
    @Published var selectedBundleId: String? = nil
    @Published var errorMessage: String? = nil

    func load() {
        DispatchQueue.global(qos: .userInitiated).async {
            let list = InstalledAppsProvider.fetchInstalledApps()
            DispatchQueue.main.async {
                self.apps = list
            }
        }
    }

    func saveSelection() {
        guard let bundle = selectedBundleId else { return }
        do {
            try InstalledAppsProvider.saveSelected(bundleId: bundle)
            errorMessage = "Saved: \(bundle)"
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var vm: AppListViewModel

    var body: some View {
        NavigationView {
            VStack {
                if vm.apps.isEmpty {
                    Text("No apps found or private API unavailable.")
                        .padding()
                }

                List(vm.apps, id: \ .self) { app in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(app.name).font(.headline)
                            Text(app.bundleId).font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        if vm.selectedBundleId == app.bundleId {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.selectedBundleId = app.bundleId
                    }
                }

                HStack {
                    Button(action: { vm.load() }) {
                        Text("Refresh")
                    }
                    Spacer()
                    Button(action: { vm.saveSelection() }) {
                        Text("Save Selection")
                    }
                }
                .padding()

                if let msg = vm.errorMessage {
                    Text(msg).font(.footnote).foregroundColor(.blue).padding([.bottom])
                }
            }
            .navigationTitle("App Selector")
        }
        .onAppear { vm.load() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppListViewModel())
    }
}
