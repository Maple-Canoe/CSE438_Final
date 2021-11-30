import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

//for custom cell, source https://www.youtube.com/watch?v=5Mm2gQjd3vU
class PopoverUsersController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var handle: AuthStateDidChangeListenerHandle?
    var currentUserID: String?
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser!.uid
    
    var users : [String] = []
    var usersID : [String] = []
    var isFollowed : [Bool] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = tableView.dequeueReusableCell(withIdentifier: "user")! as! CustomTableViewCell
        user.textLabel!.text = users[indexPath.row]
//        user.followButton.setTitle("follow", for: .normal)
        if self.isFollowed[indexPath.row]{
            user.followButton.setTitle("followed", for: .normal)
            user.followButton.setTitleColor(UIColor.gray, for: .normal)
        }
        else{
            user.followButton.setTitle("follow", for: .normal)
        }
        user.followButton.tag = indexPath.row
        user.followButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        return user
    }
    
    @objc
    func buttonTapped(sender:UIButton){
        let rowIndex:Int = sender.tag
        let user_id = usersID[rowIndex]
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    let followings = document.data()["followings"] as! Array<String>
                    if followings.contains(user_id){
                        return
                    }else{
                        document.reference.updateData(["followings": FieldValue.arrayUnion([user_id])])
                    }
                }
            }
            let alert = UIAlertController(title: "User Followed!", message: "You have followed this user.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I see", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            self.isFollowed[rowIndex] = true
            self.tableView.reloadData()
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUsers()
//        fetchFollowing()
    }
    
    func fetchUsers() {
        users = []
        usersID = []
        db.collection("users").getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    let user_name = document.data()["username"] as! String
                    let user_id = document.data()["uid"] as! String
                    if self.uid != user_id {
//                        print("each", document.documentID)
                        self.users.append(user_name)
                        self.usersID.append(user_id)
                    }
                    
                }
                print("user", self.uid)
                self.fetchFollowing()
                
                
            }
        }
    }
    

    func fetchFollowing(){
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    let followings = document.data()["followings"] as! Array<String>
                    for index in 0...(self.users.count-1){
                        if followings.contains(self.usersID[index]){
                            self.isFollowed.append(true)
                        }
                        else{
                            self.isFollowed.append(false)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
}
