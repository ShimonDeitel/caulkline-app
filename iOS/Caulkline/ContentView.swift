import SwiftUI
import PhotosUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: JobEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.textMuted)
                        Text("No jobs yet")
                            .font(Theme.headlineFont)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Tap + to log your first one.")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.textMuted)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                EntryRow(entry: entry)
                            }
                            .accessibilityIdentifier("entryRow_\(entry.title)")
                            .listRowBackground(Theme.surface)
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Caulkline")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add)
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(mode: .edit(entry))
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryRow: View {
    let entry: JobEntry

    var body: some View {
        HStack(spacing: 12) {
            if let data = entry.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.accent.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "photo").foregroundStyle(Theme.accent))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.textPrimary)
                Text("\(entry.stage) · \(entry.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

enum EntryFormMode: Identifiable {
    case add
    case edit(JobEntry)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let e): return e.id.uuidString
        }
    }
}

struct EntryFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let mode: EntryFormMode

    @State private var title: String = ""
    @State private var stage: String = JobEntry.stageOptions.first ?? ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?

    init(mode: EntryFormMode) {
        self.mode = mode
        if case .edit(let entry) = mode {
            _title = State(initialValue: entry.title)
            _stage = State(initialValue: entry.stage)
            _date = State(initialValue: entry.date)
            _note = State(initialValue: entry.note)
            _photoData = State(initialValue: entry.photoData)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("titleField")
                    Picker("Stage", selection: $stage) {
                        ForEach(JobEntry.stageOptions, id: \.self) { Text($0).tag($0) }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note", text: $note, axis: .vertical)
                        .accessibilityIdentifier("noteField")
                }
                Section("Photo") {
                    PhotosPicker("Choose Photo", selection: $photoItem, matching: .images)
                    if let photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .background(
                Color.clear.contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
            )
            .navigationTitle(mode.id == "add" ? "New Job" : "Edit Job")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("formSaveButton")
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
    }

    private func save() {
        switch mode {
        case .add:
            let entry = JobEntry(title: title, stage: stage, date: date, note: note, photoData: photoData)
            store.add(entry)
        case .edit(var entry):
            entry.title = title
            entry.stage = stage
            entry.date = date
            entry.note = note
            entry.photoData = photoData
            store.update(entry)
        }
        dismiss()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
