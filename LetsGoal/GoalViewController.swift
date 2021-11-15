import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

//Reference: https://stackoverflow.com/questions/61657140/how-to-create-a-popover-viewcontroller-like-apples-one

class GoalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    var currentUserID: String?
    let db = Firestore.firestore()
    @IBOutlet weak var welcomeUser: UILabel!
    @IBOutlet weak var goals: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        self.db.collection("users").whereField("uid", isEqualTo: user!.uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                let document = (snapshot?.documents)![0]
                if let username = document.data()["username"] as? String {
                    self.welcomeUser.text = "Welcome, \(username)!"
                }
            }
        }
        
    }
    
    @IBAction func addGoal(_ sender: Any) {
        let buttonFrame = addButton.frame
        print(buttonFrame)
        let popoverContentController = self.storyboard?.instantiateViewController(identifier: "popover") as? PopoverContentController
        popoverContentController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = self
            
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //
//    override func viewWillAppear(_ animated: Bool) {
//        handle = Auth.auth().addStateDidChangeListener { auth, user in
//            self.currentUserID = user?.uid
//
//            self.db.collection("users").whereField("uid", isEqualTo: self.currentUserID!).getDocuments { snapshot, error in
//                if error != nil {
//                    print(error!)
//                } else {
//                    let document = (snapshot?.documents)![0]
//                    if let username = document.data()["username"] as? String {
//                        self.welcomeUser.text = "Welcome, \(username)!"
//                    }
//                }
//            }
//
//        }
//
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
//
//    }
//
  
    @IBAction func logOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
                self.view.window?.rootViewController = homeVC
                self.view.window?.makeKeyAndVisible()
            }
            catch let error {
                print(error)
            }
        }
    }
    
        
       

    
    
    
    
   
    

}
