

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    var User_email: UITextField!
    var User_pass : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.hideKeyboardWhenTappedAround() //to hide keybord after finish
        creatUI()
      
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func creatUI(){
        
        let frame_label1 = CGRect.init(x: 190, y: 150, width: 300, height: 50 )
        let label1 = CustomLabel(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),"Welcome,",30,frame_label1 )
        label1.font = UIFont.boldSystemFont(ofSize: 35)
        helper.createLabelWithAnchor(label: label1, view: view, frame: frame_label1)
        
        let frame_label2 = CGRect.init(x: 200, y: 185, width: 300, height: 50 )
        let label2 = CustomLabel(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)," Log in to continue ! ",23,frame_label2 )
        helper.createLabelWithAnchor(label: label2, view: view, frame: frame_label2)
        
        let frame_email = CGRect.init(x: 50, y: 280, width: 300, height: 50 )
        User_email = CustomTextFiled(#colorLiteral(red: 0.9686979651, green: 0.06476699561, blue: 0.4856577516, alpha: 1)," Email Address...",12,frame_email )
        helper.createTextFieldWithAnchor(tf: User_email, view: view, frame: frame_email)
        
        let frame_pass = CGRect.init(x: 50, y: 360, width: 300, height: 50 )
        User_pass = CustomTextFiled(#colorLiteral(red: 0.9686979651, green: 0.06476699561, blue: 0.4856577516, alpha: 1)," Pasword...",12,frame_pass )
        helper.createTextFieldWithAnchor(tf: User_pass, view: view, frame: frame_pass)
        User_pass.isSecureTextEntry = true
        //chang color to let it has 2 coloers
        let x = CAGradientLayer()
        x.colors = [UIColor.blue.cgColor , UIColor.white.cgColor]
        x.frame = view.frame
      
        let frame_log = CGRect.init(x: 195, y: 440, width: 300, height: 50 )
        let but_log = CustomButton(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),"Log In",12,frame_log, .login )
        helper.createButtonWithAnchor(btn: but_log, view: view, frame: frame_log)
        but_log.layer.addSublayer(x)//
        
        
        let frame_G = CGRect.init(x: 160, y: 520, width: 50, height: 50  )
        let but_G = CustomButton(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),"",12,frame_G,.googel)
        helper.createButtonWithAnchor(btn: but_G, view: view, frame: frame_G)
                
        let frame_F = CGRect.init(x: 230, y: 520, width: 50, height: 50 )
        let but_F = CustomButton(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),"",12,frame_F,.facebock)
        helper.createButtonWithAnchor(btn: but_F, view: view, frame: frame_F)
       
        let frame_reg = CGRect.init(x: 260, y: 610, width: 300, height: 50 )
        let label_reg = CustomLabel(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)," I'm a new user. ",15,frame_reg )
        helper.createLabelWithAnchor(label: label_reg, view: view, frame: frame_reg)
        
        let fream_but_reg = CGRect.init(x: 250, y: 610, width: 300, height: 50 )
        let but_reg = UIButton(frame: fream_but_reg)
        but_reg.setTitle(" Register ", for: UIControl.State.normal)
        but_reg.setTitleColor(#colorLiteral(red: 0.9768484235, green: 0.05093111098, blue: 0.386423111, alpha: 1), for: .normal)
        but_reg.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        helper.createButtonWithAnchor(btn: but_reg, view: view, frame: fream_but_reg)
       
        //actions
        but_reg.addTarget(self, action: #selector(GoToHome), for: .touchUpInside)

        but_log.addTarget(self, action: #selector(LogIn), for: .touchUpInside)
    }
    
   
    @objc func GoToHome(_ sender: UIButton) {
          let reg = RegisterViewController.init(nibName: "RegisterViewController", bundle: nil)
          self.navigationController?.pushViewController(reg, animated: true)
      }
      
    @objc func LogIn (_ sender: UIButton) {
        
        spinner.show(in: view)
        
        guard let email = User_email.text,
              let password = User_pass.text,
             // !email.isEm
              password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        // Firwbace Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {authResult, error in
            guard let result = authResult, error == nil else {
                print("Error LogIn")
                return
            }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            self.saveLoggedState()
            let user = result.user
            let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
           /* DatabaseManager.shared.getDataFor(path: safeEmail, completion: {result in
                switch result{
                case . success(let data):
                    guard let userData = data as? [String: Any],
                    let name = userData["fullName"] as? String
                    else {
                        return
                    }
                    UserDefaults.standard.set(name,forKey: "name")
                case .failure(let error):
                    print("Failed to read data : \(error)")
                }
            })*/
            UserDefaults.standard.set(email,forKey: "email")
           
            print("Loged user: \(user)")
           // UserDefaults.standard.set(true, forKey: "islogin")
            let conv = ConversationViewController()
            self.navigationController?.pushViewController(conv, animated: true)
        })
     
 
  
    }
    func saveLoggedState() {

        let def = UserDefaults.standard
        def.set(true, forKey: "is_authenticated") // save true flag to UserDefaults
        def.synchronize()

    }
    
    func alertUserLoginError (){
        let alert = UIAlertController(title: "Error", message: "plese enter  6 and up letters in your password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }}
