import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("notifyReminders") private var notifyReminders = true
    @AppStorage("showCompleted") private var showCompleted = true

    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    Toggle("Reminders", isOn: $notifyReminders)
                        .accessibilityIdentifier("remindersToggle")
                    Toggle("Show completed", isOn: $showCompleted)
                        .accessibilityIdentifier("showCompletedToggle")
                }
                Section("Subscription") {
                    if purchases.isPro {
                        Label("Caulkline Pro active", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Text("Use the Upgrade button on the main screen to subscribe.")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.textMuted)
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("settingsRestoreButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/caulkline-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/caulkline-app/terms.html")!)
                    Text("Version 1.0")
                        .foregroundStyle(Theme.textMuted)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
