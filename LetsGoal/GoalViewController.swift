import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class GoalViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var currentUserID: String?
    let db = Firestore.firestore()
    @IBOutlet weak var welcomeUser: UILabel!
    
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
