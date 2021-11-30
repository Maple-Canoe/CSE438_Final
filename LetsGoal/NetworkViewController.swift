import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore


class NetworkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    
    var currentUserID: String?
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser!.uid
    
    var followings : [String] = []
    var followingsID : [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let following = tableView.dequeueReusableCell(withIdentifier: "following")! as UITableViewCell
        following.textLabel!.text = followings[indexPath.row]
        return following
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate=self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "following")
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFollowings()
    }
    
    @IBAction func buttonTabbed(_ sender: Any) {
        let buttonFrame = addButton.frame
        let popoverUsersController = self.storyboard?.instantiateViewController(identifier: "popover_user") as? PopoverUsersController
        popoverUsersController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverUsersController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = self
            
            if let popoverController = popoverUsersController {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .automatic
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        fetchFollowings()
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
    
    func fetchFollowings(){
        followings = []
        
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    self.followingsID = document.data()["followings"] as! Array<String>
                    for id in self.followingsID{
                        self.db.collection("users").whereField("uid", isEqualTo: id).getDocuments { snapshot2, error2 in
                            if error2 != nil{
                                print(error2!)
                            }
                            else{
                                for document2 in (snapshot2?.documents)! {
                                    self.followings.append(document2.data()["username"] as! String)
                                    print("doo", self.followings)
                                }
                            }
                            self.tableView.reloadData()
                            }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "delete") {
            
            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in

            
            
            self.db.collection("users").whereField("uid", isEqualTo: self.uid)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
//                            print("hh", )
                            document.reference.updateData(["followings": FieldValue.arrayRemove([self.followingsID[indexPath.row]])])
                        }
                        self.followingsID.remove(at: indexPath.row)
                        self.followings.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
            }
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "heart.slash.filled")
        
        tableView.reloadData()
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
   
}
