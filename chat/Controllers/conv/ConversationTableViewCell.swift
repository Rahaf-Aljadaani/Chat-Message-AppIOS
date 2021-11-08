//
//  ConversationTableViewCell.swift
//  chat
//
//  Created by administrator on 04/11/2021.
//

import UIKit
import SDWebImage
class ConversationTableViewCell: UITableViewCell {
static let identefier = "ConversationTableViewCell"
    private let userImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let UserNameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    private let UserMassLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return label
    }()
    
    private let timeLabel: UILabel = {
       let label = UILabel()
        label.text = "HH:MM:YYYY"
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(timeLabel)
        contentView.addSubview(userImage)
        contentView.addSubview(UserNameLabel)
        contentView.addSubview(UserMassLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.frame = CGRect(x: 15, y: 10, width: 80, height: 80)
        UserNameLabel.frame = CGRect(x: 120,
                                     y:0
                                     , width: contentView.frame.width - 20-userImage.frame.width,
                                     height: contentView.frame.height-20/2)
        UserMassLabel.frame = CGRect(x: 120,
                                      y:30
                                     , width: contentView.frame.width - 20-userImage.frame.width,
                                     height: contentView.frame.height-20/2)
        timeLabel.frame = CGRect(x: 280,
                                  y:10
                                 , width: contentView.frame.width - 20-userImage.frame.width,
                                 height: contentView.frame.height-20/2)
    }
    public func configure(with model: conversation){
        self.UserMassLabel.text = model.latestMessage.text
        self.UserNameLabel.text = model.name
        
        let x = model.latestMessage.date.split(separator: " ")
        
        self.timeLabel.text = x[4] + " " + x[5]
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
               
                DispatchQueue.main.async {
                    self?.userImage.sd_setImage(with: url, completed: nil)
                }
            case . failure(let error):
                print("Error : Failed to get image : \(error)")
            }
        })
    }
    
}
