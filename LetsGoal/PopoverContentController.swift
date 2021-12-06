import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class PopoverContentController: UIViewController {
    
    @IBOutlet weak var eventName: UITextView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventTime: UIDatePicker!
    @IBOutlet weak var submitButton: UIButton!
    
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser!.uid
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.backgroundColor = UIColor(named: "button")
        submitButton.layer.cornerRadius = 15
        submitButton.tintColor = UIColor.white
    }

    
    @IBAction func submit(_ sender: Any) {
        if !eventName.hasText || !eventDescription.hasText {
            let alert = UIAlertController(title: "Incorrect Input!", message: "Please fill in an event name and an event description.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I see", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            db.collection("events").addDocument(data: ["uid" : uid, "event_name" : eventName.text!, "event_description" : eventDescription.text!, "event_time" : eventTime.date, "completed": false])
            eventName.text = ""
            eventDescription.text = ""
            
            let alert = UIAlertController(title: "Event Created!", message: "A new event has been added to your task list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I see", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
          
    }
    
    
    

    

}
