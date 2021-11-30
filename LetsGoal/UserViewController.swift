//
//  UserViewController.swift
//  LetsGoal
//
//  Created by Alex Xu on 11/30/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var completedGoals: UITableView!
    @IBOutlet weak var expiredGoals: UITableView!
    
    var currentUserID: String?
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser!.uid
    var tasks: [String] = []
    var expired: [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == completedGoals {
            return tasks.count
        }
        else {
            return expired.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let task = tableView.dequeueReusableCell(withIdentifier: "stuff") else {
            return UITableViewCell()
        }
        if tableView == completedGoals {
            task.textLabel!.text = tasks[indexPath.row]
        }
        else {
            task.textLabel!.text = expired[indexPath.row]
        }
        return task
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTasks()
    }
    
    func fetchTasks() {
        tasks = []
        expired = []
        
        db.collection("events").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    let event_name = document.data()["event_name"] as! String
                    let completed = document.data()["completed"] as! Bool
                    if completed {
                        self.tasks.append(event_name)
                    }
                    else {
                        let date = (document.data()["event_time"] as! Timestamp).dateValue()
                        let today = date.timeIntervalSinceNow
                        if today < 0 {
                            self.expired.append(event_name)
                        }
                    }
                }
                self.completedGoals.reloadData()
                self.expiredGoals.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        completedGoals.delegate = self
        completedGoals.dataSource = self
        completedGoals.register(UITableViewCell.self, forCellReuseIdentifier: "stuff")
        
        expiredGoals.delegate = self
        expiredGoals.dataSource = self
        expiredGoals.register(UITableViewCell.self, forCellReuseIdentifier: "stuff")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
