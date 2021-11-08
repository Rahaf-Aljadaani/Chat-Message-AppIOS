//
//  ConversationViewController.swift
//  chat
//
//  Created by administrator on 28/10/2021.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import JGProgressHUD

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

///-----------------------------------------------------

struct conversation  {
    let id : String
    let name : String
    let otherUserEmail : String
    let latestMessage : LatesMassege
}

struct LatesMassege{
    let date : String
    let text: String
    let isRead: Bool
}

// Mark :-
class ConversationViewController: UIViewController {
private var coversations = [conversation]()//conversation
    private let spinner = JGProgressHUD(style: .dark)
    private let tabelView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identefier)
        return table
    }()
    
    private let isThereConv: UILabel = {
        let label = UILabel()
        label.text = "There is no conversations "
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    var titleView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 40))
    // check to see if user is signed in using ... user defaults
       // they are, stay on the screen. If not, show the login screen
       override func viewDidLoad() {
           super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() //to hide keybord after finish
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9112289548, green: 0.4497116208, blue: 0.5051998496, alpha: 1)
      //  titleView.view =  //as! UITableView
        //profiel image
        fatchProfilePic()
        
        // 1. create a gesture recognizer (tap gesture)
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
               // 2. add the gesture recognizer to a view
        titleView.addGestureRecognizer(tapGesture)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logOut))
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.9112288952, green: 0.4497116208, blue: 0.5051998496, alpha: 1)
        //view.backgroundColor = .red
        view.addSubview(tabelView)
        view.addSubview(isThereConv)

        setupTabel()
        fetchConv()
      startListeningForConv()
  
        }
    
    @objc private func goToProfile(){
        let vc = ProfilePageViewController()
        print("hi profile ")
        vc.title = "My Profile"
        navigationController?.navigationBar.barTintColor =  #colorLiteral(red: 0.939812243, green: 0.7498642802, blue: 0.7697158456, alpha: 1)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func startListeningForConv (){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        DatabaseManger.shared.getAllConversations(for: safeEmail, completion: {[weak self] result in
            switch result{
            case . success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.coversations = conversations
                DispatchQueue.main.async {
                    self?.tabelView.reloadData()
                }
                
                
            case .failure(let error):
                print("Failed to get conves : \(error)")
            }
        })
    }
    
    func fatchProfilePic(){
        let is_authenticated = UserDefaults.standard.bool(forKey: "is_authenticated")
        if is_authenticated == true{
         print("loggedIn")
        }else{
         print("loggedOut")
        }

        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("=(")
            return// nil
        }
       
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        let filename = safeEmail+"_profile_picture.png"
        let path = "images/"+filename
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(url: url)
            case . failure(let error):
                print("Error : Failed to get download url : \(error)")
            }
        })
    }
   
    func downloadImage(url:URL)  {
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data , error == nil else {
              
                return
            }
            print("work")
            DispatchQueue.main.async { [self] in
                let imag = UIImage(data: data)
                
             let imageView = UIImageView(image: imag)
                imageView.frame = CGRect(x: 65, y: 0, width: 40, height: 40)
             imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = imageView.frame.height/2
                imageView.layer.masksToBounds = true
             
             // titleView.layer.cornerRadius = 100
                self.titleView.addSubview(imageView)
                self.titleView.backgroundColor = .clear
                 self.navigationItem.titleView = titleView
                
            }
        }).resume()
    }
    
    // let nivigation on
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func logOut(){
        //add to button to log out
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        catch {
            print("Error : Failed to log out")
        }
    }
    
    @objc private func didTapComposeButton(){
          // present new conversation view controller
          // present in a nav controllercopy
          
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            print("\(result) pppppp ")
            self?.creatNewConv(result: result)
            
        }
          let navVC = UINavigationController(rootViewController: vc)
          present(navVC,animated: true)
      }
    
    private func creatNewConv(result: [String: String]){
        guard let name = result["name"],
              let email = result["email"] else{
            return
        }
        let vc = ChatViewController(with: email, id: "ChatViewController")
       // vc.isNewConverstion = true
      vc.isNewConversation = true
       vc.title = name
        vc.navigationItem.largeTitleDisplayMode  = .never
        //vc.navigationItem.largeTitleDisplayMode = .never
       navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupTabel (){
        tabelView.delegate = self
        tabelView.dataSource = self
    }
    private func fetchConv(){
        tabelView.isHidden = false
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabelView.frame = view.bounds
    }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            
            validateAuth()
       }
  
    
    private func validateAuth(){
            // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
                // present login view controller
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: false)
            }
        }
}
    //MARK:-
    
    extension ConversationViewController:  UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = coversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identefier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = coversations[indexPath.row]
        
        let vc = ChatViewController(with: model.otherUserEmail, id: "ChatViewController")
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
      }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
        
    
    
}
