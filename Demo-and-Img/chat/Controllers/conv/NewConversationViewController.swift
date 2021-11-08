

import UIKit
import FirebaseAuth
import JGProgressHUD
class NewConversationViewController: UIViewController {
    // root view controller that gets instantiated when app launches
    // check to see if user is signed in using ... user defaults
    // they are, stay on the screen. If not, show the login screen
    
    public var completion: (([String: String]) ->(Void))?
    private var users = [[String: String]]()
    private var result = [[String: String]]()
    private var hasFatched = false
    private let spinner = JGProgressHUD()
    private let searchBar : UISearchBar =  {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users ..."
        return searchBar
    }()
    
    
    private let tabelView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResults: UILabel = {
        let label = UILabel()
        label.text = "There is no results "
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() //to hide keybord after finish
        
        view.addSubview(noResults)
        view.addSubview(tabelView)
        
        tabelView.dataSource = self
        tabelView.delegate = self
        view.backgroundColor = .blue
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done,
                                                            target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
        /*.
        do {
            try FirebaseAuth.Auth.auth().signOut()
        }
        catch {
        }*/
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabelView.frame = view.bounds
        noResults.frame = CGRect(x: 300, y: 200, width: 200, height: 200)
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
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
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = result[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // start conv
        let targetUserData = result[indexPath.row]
        dismiss(animated: true, completion: {[weak self] in
            self?.completion?(targetUserData)
        })
    }
}
extension NewConversationViewController: UISearchBarDelegate{
    func  searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: " ").isEmpty
        else {
            return
        }
        searchBar.resignFirstResponder()
        result.removeAll()
        spinner.show(in: view)
        searchUsers(query: text)
        
    }
    
    func searchUsers(query :String){
        if hasFatched{
            self.filterUsers(with: query)
        }
        else{
            DatabaseManger.shared.getAllUsers(completion: {[weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFatched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Faild to get users \(error)")
                }
                
            })
        }
    }
    
    func filterUsers(with term: String){
        guard hasFatched else{
            return
        }
        self.spinner.dismiss()
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() as? String else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.result = results
        updateUI()
    }
    func updateUI () {
        if result.isEmpty {
            self.noResults.isHidden = false
            self.tabelView.isHidden = true
        }
        else{
            self.noResults.isHidden = true
            self.tabelView.isHidden = false
            self .tabelView.reloadData()
        }
    }
}
