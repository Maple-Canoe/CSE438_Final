import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

//Reference: https://www.youtube.com/watch?v=1HN7usMROt8

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessage.alpha = 0
        errorMessage.textColor = .red
        errorMessage.numberOfLines = -1

    }
    
    @IBAction func signIn(_ sender: Any) {
        let email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if  email == "" || password == "" {
            errorMessage.text = "All blanks should be filled."
            errorMessage.alpha = 1
        }
        else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage.text = error.localizedDescription
                    self.errorMessage.alpha = 1
                } else {
                    let tabVC = self.storyboard?.instantiateViewController(withIdentifier: "tab") as! UITabBarController
                    self.view.window?.rootViewController = tabVC
                    self.view.window?.makeKeyAndVisible()
                }
            }
            
            
        }
    }
    
    
    
    

}
