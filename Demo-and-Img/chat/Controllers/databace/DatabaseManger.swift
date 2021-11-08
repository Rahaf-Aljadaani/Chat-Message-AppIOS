//
//  DatabaseManger.swift
//  chat
//
//  Created by administrator on 01/11/2021.
//


import Foundation
import Firebase
import MessageKit
import RealmSwift
import JGProgressHUD
import SDWebImage


final class DatabaseManger {
    
    static let shared = DatabaseManger()

    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress : String) -> String {
        
            var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
    }
    
  
    
    
 
}

struct ChatAppUser {
    let FullName: String
   
    let emailAddress: String
    //let profilePictureUrl: String
    
    // create a computed property safe email
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}


// MARK: - account management
extension DatabaseManger {
    
 
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
       
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
        
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
           
            completion(true)
        }
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser , completion: @escaping (Bool) -> Void){
        
        database.child(user.safeEmail).setValue(["FullName":user.FullName]) { error, _ in
            guard error  == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                // snapshot is not the value itself
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // if var so we can make it mutable so we can append more contents into the array, and update it
                    // append to user dictionary
                    let newElement = [
                        "name": user.FullName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                       completion(true)
                    }
                    
                }else{
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.FullName ,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                        completion(false)
                            return
                        }
                       completion(true)
                    }
                }
            }
        }
    }
    
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
            
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }

   
}

    //////
    
   

// above
// when user tries to start a convo, we can pull all these users with one request
/*
 users => [
 [
 "name":
 "safe_email":
 ],
 [
 "name":
 "safe_email":
 ],
 ]
 */
// try to get a reference to an existing user's array
// if doesn't exist, create it, if it does, append to it









// MARK: - Sending Messages / conversations
extension DatabaseManger {
    
    /*  "conversation_id" {
     "messages": [
     {
     "id": String,
     "type": text, photo, video
     "content": String,
     "date": Date(),
     "sender_email": String,
     "isRead": true/false,
     }
     ]
     }
     
     
     conversation => [
     [
     "conversation_id":
     "other_user_email":
     "latest_message": => {
     "date": Date()
     "latest_message": "message"
     "is_read": true/false
     }
     
     ],
     
     ]
     
     */
    
    
    
    /// creates a new conversation with target user email and first message sent

    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {print("work 3")        // put conversation in the user's conversation collection, and then 2. once we create that new entry, create the root convo with all the messages in it
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
           //   let currentName = UserDefaults.standard.value(forKey: "FullName") as? String
              else {
            print(UserDefaults.standard.dictionaryRepresentation())
            if let x = UserDefaults.standard.value(forKey: "email") as? String{
                print("\(x) work 4 \(UserDefaults.standard.value(forKey: "name") as? String)")}
            return
        }
        
        print("work 2")
       let safeEmail = DatabaseManger.safeEmail(emailAddress: currentEmail)
    let ref = database.child("\(safeEmail)")
       
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            // what we care about is the conversation for this user
            guard var userNode = snapshot.value as? [String: Any] else {
                // we should have a user
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
       
           // self?.database.child("\(otherUserEmail)/conversations").setValue([newConversationData2])
            
            print("work 1")
            //
           let recipient_newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email": currentEmail, // us, the sender email
                "name": "rahhhhhhaf",  // self for now, will cache later
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
            // update recipient conversation entry
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").childByAutoId().setValue(conversationId)
                  //  self?.database.child("\(otherUserEmail)/conversations").setValue(conversationId)
                }else {
                    // reciepient user doesn't have any conversations, we create them
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").childByAutoId().setValue([recipient_newConversationData])
                }
            }
            
            
            // update current user conversation entry
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exits for current user, you should append
                
                // points to an array of a dictionary with quite a few keys and values
                // if we have this conversations pointer, we would like to append to it
                
                conversations.append(newConversationData)
                
                userNode["conversations"] = conversations // we appended a new one
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }else {
                // create this conversation
                // conversation array doesn't exist
                print ("fff 55555 ffF")
                userNode["conversations"] = [
                    recipient_newConversationData
                ]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
                
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
            
        }
        
    }
   
    private func finishCreatingConversation(name: String, conversationID:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        //        {
        //            "id": String,
        //            "type": text, photo, video
        //            "content": String,
        //            "date": Date(),
        //            "sender_email": String,
        //            "isRead": true/false,
        //        }
        
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name,
        ]
        
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    /// Fetches and returns all conversations for the user with
    
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapshot in
            // new conversation created? we get a completion handler called
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                // create model
                
                let latestMessageObject = LatesMassege(date: date, text: message, isRead: isRead)
                
                return conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            
            completion(.success(conversations))
            
        }
    }
    
    
    /// gets all messages from a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapshot in
            // new conversation created? we get a completion handler called
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                                   let isRead = dictionary["is_read"] as? Bool,
                                   let messageID = dictionary["id"] as? String,
                                   let content = dictionary["content"] as? String,
                                   let senderEmail = dictionary["sender_email"] as? String,
                                   let type = dictionary["type"] as? String,
                                   let dateString = dictionary["date"] as? String,
                                   let date = ChatViewController.dateFormatter.date(from: dateString)else {
                                       return nil
                               }
                
                // create model
                
                let sender = Sender(photoURL: "",
                                                    senderId: senderEmail,
                                                    displayName: name)

                                return Message(sender: sender,
                                               messageId: messageID,
                                               sentDate: date,
                                               kind: .text(content))
            }
            
            completion(.success(conversations))
            
        }
    }
    
    /////
    

    
    ///// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // return bool if successful
        
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name,
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
                
            }
        
        }
    
    }
    
    
}
extension DatabaseManger {
    public func  getDataFor(path:String , completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value){ snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}


