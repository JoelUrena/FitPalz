import SwiftUI
import Contacts

func fetchContacts() {
    let contactStore = CNContactStore()
    
    // Specify the keys to fetch
    let keysToFetch: [CNKeyDescriptor] = [
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor
    ]
    
    let request = CNContactFetchRequest(keysToFetch: keysToFetch)
    
    do {
        try contactStore.enumerateContacts(with: request) { (contact, stop) in
            let fullName = "\(contact.givenName) \(contact.familyName)"
            print("Name: \(fullName)")
            
            // Print each phone number for the contact
            for phoneNumber in contact.phoneNumbers {
                let number = phoneNumber.value.stringValue
                print("Phone: \(number)")
            }
        }
    } catch {
        print("Failed to fetch contacts, error: \(error)")
    }
}

struct FriendsView: View {
    var body: some View {
        Text("Friends Screen")
            .font(.title2)
            .padding()
            .onAppear {
                // Call fetchContacts() when the view appears.
                fetchContacts()
            }
    }
}



