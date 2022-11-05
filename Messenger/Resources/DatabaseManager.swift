//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Olzhas Suleimenov on 01.11.2022.
//

import Foundation
import FirebaseDatabase

// Creating public API (functions) that allow us to seamlessly perform operations on database regardless which view controller we are in

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    
}

// MARK: - Account Management

extension DatabaseManager {
    
    // completions block because function to get data out of database is asynchronous
    public func doesUserExists(with email: String, completion: @escaping (Bool) -> Void) {
        // get data from database
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // if we able to assign foundEmail it means this email exists already
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    //let profilePictureURL: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
