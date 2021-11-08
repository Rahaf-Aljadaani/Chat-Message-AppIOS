

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
class User {
    var name : String!
    var email : String!
    var password : String!
    var imageProfail : UIImageView!
    
    init(_ name: String ,_ email: String , _ pass: String , _ image: UIImageView){
        self.name = name
        self.email = email
        self.password = pass
        self.imageProfail = image
    }
    
    init(_ email: String , _ pass: String ){
        self.email = email
        self.password = pass
        
    }
    
    func LogInFirebase()  {
        // Firebase Login
       
    }
    
    func SingUpFirebase()  {
        
       
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult , error  in
            guard let result = authResult, error == nil else {
             
                
                print("Error creating user")
                return
            }
            let user = result.user
            print("Created User: \(user)")
        })
    }
}
