

import UIKit

class ProfilePageViewController: UIViewController {
    private var userImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let UserStatLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 7
        label.text = " ------ About Me ------- \nTrainee in Mobile Application Development Camp \nI hope to get an excellent mark =) \n\n ------ MY Email -------- "
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return label
    }()

    private let UserEmailLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.939812243, green: 0.7498642802, blue: 0.7697158456, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        view.addSubview(UserStatLabel)
        view.addSubview(userImage)
        view.addSubview(UserEmailLabel)
    
        
        UserStatLabel.frame = CGRect(x: 80,
                                      y:40
                                     , width: view.frame.width - 20-userImage.frame.width,
                                     height: view.frame.height-20/2)
        
        UserEmailLabel.frame = CGRect(x: 110,
                                      y:120
                                     , width: view.frame.width - 20-userImage.frame.width,
                                     height: view.frame.height-20/2)
        
        self.UserEmailLabel.text = UserDefaults.standard.value(forKey: "email") as! String
      
        
        fatchProfilePic()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(goback))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem?.style = .done
    }
    
    @objc private func goback(){
        let vc = ConversationViewController()
        navigationController?.navigationBar.barTintColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.pushViewController(vc, animated: true)
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
                
                userImage  =  UIImageView(image: imag)
                
                view.addSubview(userImage)
                userImage.frame = CGRect(x: 110, y: 140, width: 150, height: 150)
                userImage.contentMode = .scaleAspectFill
                userImage.layer.cornerRadius = userImage.frame.height/2
                userImage.layer.masksToBounds = true
                
            }
        }).resume()
    }
    
    

}
