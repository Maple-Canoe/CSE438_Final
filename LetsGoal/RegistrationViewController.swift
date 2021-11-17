import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

//Reference: https://www.youtube.com/watch?v=1HN7usMROt8

class RegistrationViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessage.alpha = 0
        errorMessage.textColor = .red
        errorMessage.numberOfLines = -1

    }
    @IBAction func back(_ sender: Any) {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
        self.view.window?.rootViewController = homeVC
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func signUp(_ sender: Any) {
        let username = username.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if  username == "" || email == "" || password == "" {
            errorMessage.text = "All blanks should be filled."
            errorMessage.alpha = 1
        }
        else {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage.text = error.localizedDescription
                    self.errorMessage.alpha = 1
                } else {
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["username": username, "uid": result!.user.uid]) { (error) in
                        if let error = error {
                            self.errorMessage.text = error.localizedDescription
                            self.errorMessage.alpha = 1
                        }
                    }
                    
                    let tabVC = self.storyboard?.instantiateViewController(withIdentifier: "tab") as! UITabBarController
                    self.view.window?.rootViewController = tabVC
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }

}
