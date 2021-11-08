
import Foundation
import UIKit


enum Textbut {
    case login
    case facebock
    case googel
}

class CustomButton: UIButton {
    init(_ bgColor:UIColor, _ title:String, _ cornerRadius: Double, _ frame: CGRect , _ type : Textbut) {
        super.init(frame: frame)
        switch type {
        case .login:
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = bgColor
            self.setTitle(title, for: .normal)
            self.layer.cornerRadius = CGFloat(cornerRadius)
            self.layer.masksToBounds = true
        case .facebock:
            let img = UIImage.init(named: "faceb")
            self.setImage(img, for: .normal)
            self.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.layer.shadowOpacity = 0.5
            self.layer.shadowRadius = 3.0
            self.layer.masksToBounds = false
        case .googel:
            let img = UIImage.init(named: "gogel")
            self.setImage(img, for: .normal)
            self.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.layer.shadowOpacity = 0.5
            self.layer.shadowRadius = 3.0
            self.layer.masksToBounds = false
        default:
            print("error")
        }
       
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

//MARK:-

class CustomTextFiled: UITextField {
    
    
    init(_ bgColor:CGColor, _ title:String, _ cornerRadius: Double, _ frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.masksToBounds = true
       self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.returnKeyType = .continue
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = bgColor
        self.placeholder = title
        self.leftViewMode = .always
        //self.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


//MARK:-

class CustomImage: UIImageView {
    init(_ bgColor:UIColor , _ frame: CGRect) {
       
        super.init(frame: frame)
        self.image = UIImage(systemName: "person")
        self.contentMode = .scaleAspectFill
        self.tintColor = bgColor
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.9844128489, green: 0.06301582605, blue: 0.4698197842, alpha: 1)
        


    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


//MARK:- Label part

class CustomLabel: UILabel {
    init(_ bgColor:UIColor, _ title:String, _ size: Double , _ frame: CGRect) {
        super.init(frame: frame)
        self.textColor = bgColor
        self.text = title
        self.font = UIFont.systemFont(ofSize: CGFloat(size))
       // self.font = UIFont.boldSystemFont(ofSize: 35)
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

//Mark:- helper

enum Types {
    case Button_log
    case Button_face
    case Button_googel
}

class helper {
    
    static func createTextFieldWithAnchor(tf:UITextField, view:UIView, frame: CGRect) {
        print(tf)
                view.addSubview(tf)
                tf.text = ""
                NSLayoutConstraint.activate([
                tf.widthAnchor.constraint(equalToConstant:  frame.size.width),
                tf.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tf.topAnchor.constraint(equalTo: view.topAnchor, constant: frame.origin.y),
                tf.heightAnchor.constraint(equalToConstant: frame.size.height)
            ])
        }
        
    static func createButtonWithAnchor(btn:UIButton, view:UIView, frame: CGRect ) {
                view.addSubview(btn)
                btn.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: frame.size.width),
                btn.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: frame.origin.x),
                btn.topAnchor.constraint(equalTo: view.topAnchor, constant: frame.origin.y),
                btn.heightAnchor.constraint(equalToConstant: frame.size.height)
            ])
        }
    
    static func createLabelWithAnchor(label:UILabel, view:UIView, frame: CGRect ) {
                view.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: frame.size.width),
                    label.centerXAnchor.constraint(equalTo:view.leftAnchor, constant: frame.origin.x),
                label.topAnchor.constraint(equalTo: view.topAnchor, constant: frame.origin.y),
                label.heightAnchor.constraint(equalToConstant: frame.size.height)
            ])
        }
    
    static func createImageWithAnchor(tf:UIImageView, view:UIView, frame: CGRect) {
                view.addSubview(tf)
                
                NSLayoutConstraint.activate([
                tf.widthAnchor.constraint(equalToConstant:  frame.size.width),
                tf.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tf.topAnchor.constraint(equalTo: view.topAnchor, constant: frame.origin.y),
                tf.heightAnchor.constraint(equalToConstant: frame.size.height)
            ])
        }
}
