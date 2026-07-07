import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var purchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.accent)
                        .padding(.top, 32)
                    Text("Caulkline Pro")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Unlimited locations plus re-caulk due alerts")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    if let product = purchases.product {
                        Button {
                            purchasing = true
                            Task {
                                await purchases.purchase()
                                purchasing = false
                                if purchases.isPro { dismiss() }
                            }
                        } label: {
                            Text(purchasing ? "Processing…" : "Subscribe \(product.displayPrice)/month")
                                .font(Theme.headlineFont)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }
                        .accessibilityIdentifier("paywallSubscribeButton")
                        .disabled(purchasing)
                        .padding(.horizontal, 24)
                    } else {
                        ProgressView()
                    }

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restorePurchasesButton")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textMuted)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("paywallCloseButton")
                }
            }
        }
    }
}
