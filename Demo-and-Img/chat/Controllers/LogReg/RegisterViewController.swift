

import UIKit
import Firebase
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    var imageView : UIImageView!
    var User_name : UITextField!
    var User_email: UITextField!
    var User_pass : UITextField!
    //var new_User : User!
    override func viewDidLoad() {
        super.viewDidLoad()
       self.hideKeyboardWhenTappedAround() //to hide keybord after finish
        creatUI()
       
    }
    
    func creatUI(){
        let frame_label1 = CGRect.init(x: 190, y: 100, width: 300, height: 50 )
        let label1 = CustomLabel(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),"Create Account,",30,frame_label1 )
        label1.font = UIFont.boldSystemFont(ofSize: 35)
        helper.createLabelWithAnchor(label: label1, view: view, frame: frame_label1)
        
        let frame_label2 = CGRect.init(x: 200, y: 135, width: 300, height: 50 )
        let label2 = CustomLabel(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)," Sing up to get started!",23,frame_label2 )
        helper.createLabelWithAnchor(label: label2, view: view, frame: frame_label2)
        
        let frame_image = CGRect.init(x: 135, y: 190, width: 110, height: 110 )
         imageView = CustomImage(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),frame_image )
        helper.createImageWithAnchor(tf:  imageView, view: view, frame: frame_image)
       
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(changImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
        
        // #selector(changImage)
        let frame_name = CGRect.init(x: 50, y: 310, width: 300, height: 50 )
        User_name = CustomTextFiled(#colorLiteral(red: 0.9961410165, green: 0.06406798959, blue: 0.4738404155, alpha: 1)," Full name...",12,frame_name )
        helper.createTextFieldWithAnchor(tf: User_name, view: view, frame: frame_name)
        
        let frame_email = CGRect.init(x: 50, y: 380, width: 300, height: 50 )
         User_email = CustomTextFiled(#colorLiteral(red: 0.9844128489, green: 0.06301582605, blue: 0.4698197842, alpha: 1)," Email Address...",12,frame_email )
        helper.createTextFieldWithAnchor(tf: User_email, view: view, frame: frame_email)
        
        let frame_pass = CGRect.init(x: 50, y: 450, width: 300, height: 50 )
         User_pass = CustomTextFiled(#colorLiteral(red: 0.9844128489, green: 0.06301582605, blue: 0.4698197842, alpha: 1)," Password...",12,frame_pass )
        helper.createTextFieldWithAnchor(tf: User_pass, view: view, frame: frame_pass)
        User_pass.isSecureTextEntry = true
        let frame_log = CGRect.init(x: 195, y: 520, width: 300, height: 50 )
        let but_log = CustomButton(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),"Sing Up",12,frame_log, .login )
        helper.createButtonWithAnchor(btn: but_log, view: view, frame: frame_log)
        
        let frame_reg = CGRect.init(x: 235, y: 610, width: 300, height: 50 )
        let label_reg = CustomLabel(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)," I'm already a member, ",15,frame_reg )
        helper.createLabelWithAnchor(label: label_reg, view: view, frame: frame_reg)
        
        let fream_but_reg = CGRect.init(x: 265, y: 610, width: 300, height: 50 )
        let but_reg = UIButton(frame: fream_but_reg)
        but_reg.setTitle(" LogIn ", for: UIControl.State.normal)
        but_reg.setTitleColor(#colorLiteral(red: 0.9768484235, green: 0.05093111098, blue: 0.386423111, alpha: 1), for: .normal)
        but_reg.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        helper.createButtonWithAnchor(btn: but_reg, view: view, frame: fream_but_reg)
        
        //Action
        but_reg.addTarget(self, action: #selector(GoTologin), for: .touchUpInside)
        but_log.addTarget(self, action: #selector(SingUp), for: .touchUpInside)
        
    }
    
    @objc func GoTologin(_ sender: UIButton) {
          let log = LoginViewController.init(nibName: "LoginViewController", bundle: nil)
          self.navigationController?.pushViewController(log, animated: true)
      }
    @objc func changImage (_ sender: UIImageView) {
        presentPhotoActionSheet()
    }
    
  

    var ref: DatabaseReference = Database.database().reference()
  
    @objc func SingUp (_ sender: UIButton) {
        
        spinner.show(in: view)
        guard let fullName = User_name.text,
              let email = User_email.text,
              let password = User_pass.text,
             // !email.isEm
              password.count >= 6 else{
            alertUserLoginError(mass:"plese enter  6 and up letters in your password")
            return
        }
        
        // Firwbace Log In
        spinner.show(in: view)
        DatabaseManger.shared.userExists(with: email, completion: { [weak self]exists in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
            
            guard !exists else {
                strongSelf.alertUserLoginError(mass: "The email is already in the system")
                return
            }
          
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
 
                guard authResult != nil, error == nil else {
                    print("Error creating User")
                    return
                }
                let chatUser = ChatAppUser(FullName: fullName, emailAddress: email)
                DatabaseManger.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        //Uplode Image
                        
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData()
                        else {
                            return
                        }
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: {result in
                            switch result {
                            case .success(let downlodUrl):
                                UserDefaults.standard.set(downlodUrl,forKey: "profile_picture_url")
                                print(downlodUrl)
                            case .failure(let error):
                                print("Strong manger error : \(error)")
                            }
                        })
                    }
                    
                })
                strongSelf.saveLoggedState()
                //UserDefaults.standard.set(true, forKey: "islogin")
                let conv = ConversationViewController()
                strongSelf.navigationController?.pushViewController(conv, animated: true)
            })
        })
     
   
    }
    func saveLoggedState() {

        let def = UserDefaults.standard
        def.set(true, forKey: "is_authenticated") // save true flag to UserDefaults
        def.synchronize()

    }
    
    func alertUserLoginError (mass : String = "plese enter all information" ){
        let alert = UIAlertController(title: "Error", message: mass , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
