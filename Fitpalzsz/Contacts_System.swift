//  Contacts_System.swift
//  FitPalz
//
//  Created by AI on 2025‑05‑05.
//
//  High‑level overview
//  -------------------
//  • Fetches the user’s iOS contacts (with permission).
//  • Partitions them into “On FitPalz” vs “Invite Palz” using a mock
//    registry `ContactsOnFitpalz` (simulate Firebase lookup).
//  • Provides two SwiftUI views:
//      1.  `FindFriendsView`  – lists contacts, shows “INVITE” or “ADD”
//      2.  `FriendsListView`      – shows already‑added friends with XP stats
//  • Relies on `UserModel`, `AchievementNode`, `BadgeNode` from Xp_System.swift
//  • Uses MessageUI to open a pre‑filled SMS draft for invites.
//

import Contacts
import ContactsUI
import SwiftUI
import MessageUI

// MARK: - Mock Firebase registry of phone numbers already on FitPalz
// These came from the test device’s “iPhone contacts.vcf”.
let ContactsOnFitpalz: Set<String> = [
    "+15554395270", // (555)‑439‑5270
    "+15557243583", // 555‑724‑3583
    "+15555291552", // 555‑529‑1552
    "+15556171812", // 555‑617‑1812
    "+15556485472", // 555‑648‑5472
    "+15555431928", // 555‑543‑1928
    "+13015552312", // (301)‑555‑2312
    "+15555187001"  // 555‑518‑7001
]

// MARK: - Contact DTO for SwiftUI
struct ContactRow: Identifiable {
    // Use normalized phone number as a stable, unique ID
    let id      : String           // E.164 phone (unique per contact)
    let name    : String
    let phone   : String
    let picture : UIImage?         // nil if not available
    let onFitpalz: Bool
    let username : String?         // only if onFitpalz
}

// MARK: - ContactManager
/*
 Fetches device contacts, asks permission, partitions them, and exposes
 arrays ready for SwiftUI consumption.
 */
@MainActor
final class ContactManager: NSObject, ObservableObject {
    // Outputs
    @Published var onFitpalz : [ContactRow] = []
    @Published var invitePalz: [ContactRow] = []
    @Published var permissionDenied = false
    @Published var noContacts       = false
    
    private let store = CNContactStore()
    
    func requestAndLoad() {
        // Skip real Contacts fetch when running inside Xcode canvas previews
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.onFitpalz = [
                ContactRow(id: "+15554395270",
                           name: "Preview Pal",
                           phone: "+15554395270",
                           picture: nil,
                           onFitpalz: true,
                           username: "@preview")
            ]
            return
        }

        let auth = CNContactStore.authorizationStatus(for: .contacts)
        switch auth {
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, _ in
                Task { @MainActor in
                    if granted { await self.loadContacts() }
                    else { self.permissionDenied = true }
                }
            }
        case .authorized:
            Task { await loadContacts() }
        default:
            permissionDenied = true
        }
    }
    
    private func loadContacts() async {
        // heavy contact fetch off the main thread
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey,
                            CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                var rows: [ContactRow] = []
                var idCounter: [String:Int] = [:]   // phone → collision counter
                
                do {
                    try self.store.enumerateContacts(with: request) { contact, _ in
                        guard let phoneValue = contact.phoneNumbers.first?.value.stringValue else { return }
                        let normalized = ContactManager.normalize(phoneValue)
                        // ensure unique ID even if multiple contacts share the same phone
                        let collisions = (idCounter[normalized] ?? 0) + 1
                        idCounter[normalized] = collisions
                        let uniqueID = collisions == 1 ? normalized : "\(normalized)#\(collisions)"
                        
                        let isOn = ContactsOnFitpalz.contains(normalized)
                        let username = isOn ? "@user\(normalized.suffix(4))" : nil
                        rows.append(ContactRow(id: uniqueID,
                                               name: "\(contact.givenName) \(contact.familyName)",
                                               phone: normalized,
                                               picture: contact.thumbnailImageData.flatMap(UIImage.init(data:)),
                                               onFitpalz: isOn,
                                               username: username))
                    }
                } catch {
                    print("Contact fetch error: \(error)")
                }
                
                DispatchQueue.main.async {
                    if rows.isEmpty {
                        self.noContacts = true
                    } else {
                        self.onFitpalz  = rows.filter(\.onFitpalz).sorted { $0.name < $1.name }
                        self.invitePalz = rows.filter { !$0.onFitpalz }.sorted { $0.name < $1.name }
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    /*
     Normalises any phone string into an E.164‑like format used by
     `ContactsOnFitpalz`.
     
     • Keeps only “+” and digits.
     • If the result starts with “+” we assume it already includes a country code.
     • If it has exactly 10 digits (US local) we prefix “+1”.
     • If it has 11 digits and starts with “1” we prefix “+”.
     • Otherwise we return the raw digits (best‑effort fallback).
     */
    private static func normalize(_ raw: String) -> String {
        let digits = raw.filter { "0123456789".contains($0) }
        if raw.trimmingCharacters(in: .whitespaces).first == "+" {
            return "+" + digits
        } else if digits.count == 10 {
            return "+1" + digits
        } else if digits.count == 11 && digits.first == "1" {
            return "+" + digits
        } else {
            return "+" + digits    // fallback
        }
    }
}

// MARK: - MessageCompose helper
struct MessageComposer: UIViewControllerRepresentable {
    let recipient: String
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.recipients = [recipient]
        vc.body       = "Join FitPalz now!"
        vc.messageComposeDelegate = context.coordinator
        return vc
    }
    func updateUIViewController(_: MFMessageComposeViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Find Friends View
struct FindFriendsView: View {
    @StateObject private var manager = ContactManager()
    @State private var showSMS: ContactRow? = nil
    
    var body: some View {
        Group {
            if manager.permissionDenied {
                Text("It appears you haven’t given FitPalz permission to access your contacts.\nGo to Settings ➜ FitPalz ➜ Contacts.")
                    .multilineTextAlignment(.center).padding()
            } else if manager.noContacts {
                Text("It appears you don't have any contacts.")
            } else {
                List {
                    if !manager.onFitpalz.isEmpty {
                        Section("On FitPalz") {
                            ForEach(manager.onFitpalz) { c in
                                ContactCell(contact: c, actionTitle: "ADD") {
                                    // TODO: send friend request
                                }
                            }
                        }
                    }
                    if !manager.invitePalz.isEmpty {
                        Section("Invite Palz") {
                            ForEach(manager.invitePalz) { c in
                                ContactCell(contact: c, actionTitle: "INVITE") {
                                    showSMS = c
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear { manager.requestAndLoad() }
        .sheet(item: $showSMS) { contact in
            if MFMessageComposeViewController.canSendText() {
                MessageComposer(recipient: contact.phone)
            } else {
                // Graceful fallback for devices/simulators that cannot send SMS
                ShareLink(item: "Join FitPalz now!") {
                    VStack {
                        Image(systemName: "message.badge.circle")
                            .font(.largeTitle)
                            .padding(.bottom, 8)
                        Text("Unable to open Messages on this device.")
                            .font(.headline)
                        Text("You can still share the invite text.")
                            .font(.caption)
                    }
                    .padding()
                }
                .presentationDetents([.medium])
            }
        }
    }
}

private struct ContactCell: View {
    let contact: ContactRow
    let actionTitle: String
    let action: () -> Void
    var body: some View {
        HStack {
            if let img = contact.picture {
                Image(uiImage: img).resizable().frame(width: 40, height: 40).clipShape(Circle())
            } else {
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 40)
            }
            VStack(alignment: .leading) {
                Text(contact.name)
                Text(contact.phone).font(.caption).foregroundStyle(.secondary)
                if let username = contact.username {
                    Text(username).font(.caption2).foregroundStyle(.yellow)
                }
            }
            Spacer()
            Button(actionTitle, action: action)
                .buttonBorderShape(.capsule)
        }
    }
}

// MARK: - Friends List View
struct FriendsListView: View {
    let friends: [UserModel]   // prerequisite: already added
    var body: some View {
        List(friends, id: \.unlockIDs) { friend in
            HStack {
                // Placeholder avatar
                Circle().fill(.blue).frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Friend")   // replace with real profile name
                    let badges = friend.unlockIDs.filter { id in
                        XPSystem().gallery.badges.contains(where: { $0.id == id })
                    }
                    let achievements = friend.unlockIDs.filter { id in
                        XPSystem().gallery.achievements.contains(where: { $0.id == id })
                    }
                    Text("B \(badges.count) | A \(achievements.count)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(friend.totalXP) XP").bold()
            }
        }
    }
}



// MARK: - Previews (debug only)
#if DEBUG
struct ContactsSystem_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy user outside the ViewBuilder to avoid 'buildExpression' errors
        let dummy: UserModel = {
            var u = UserModel()
            u.totalXP = 42_000
            u.unlockIDs = ["moonwalk-103k-steps", "rings-closed-today"]
            return u
        }()
        return VStack {
            FindFriendsView()
                .previewDisplayName("Find Friends")

            FriendsListView(friends: [dummy])
                .previewDisplayName("Friends List")
        }
    }
}
#endif
