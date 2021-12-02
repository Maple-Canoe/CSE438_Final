//
//  CalendarViewController.swift
//  LetsGoal
//
//  Created by Alex Xu on 11/15/21.
//

import UIKit
import FSCalendar
import Firebase
import FirebaseFirestore
import FirebaseAuth

//Reference: https://www.youtube.com/watch?v=5Jwlet8L84w

class CalendarViewController: UIViewController,FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var currentUserID: String?
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser!.uid
    var tasks : [String] = []
    var selectedDate: String = ""
    var descript: [String] = []
    var followings: [String: [String]] = [:]
    var tableRows: [String: [String]] = [:]
    var user: [String] = []
    var uids: [String] = []
    var rows: [Int] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return followings.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tableView.dequeueReusableCell(withIdentifier: "t")! as UITableViewCell
        task.textLabel!.text = "Task \(indexPath.row + 1): wtf"
        return task
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("section number is \(section)")
        print("user count is \(user.count)")
        return user[section]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchData()
        fetchFollowings()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "t")
        // Do any additional setup after loading the view.
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        selectedDate = dateFormatter.string(from: date)
        print("calendar date is \(String(describing: selectedDate))")
        rows = []
        for key in tableRows.keys {
            var count = 0
            for day in tableRows[key]! {
                if day == selectedDate {
                    count += 1
                }
            }
            rows.append(count)
        }
        //fetchFollowings()
        tableView.reloadData()
    }
    
    func fetchData() {
//        tasks = []
//        descript = []
//        db.collection("events").whereField("uid", isEqualTo: uid).whereField("completed", isEqualTo: false).getDocuments { snapshot, error in
//            if error != nil {
//                print(error!)
//            } else {
//                for document in (snapshot?.documents)! {
//                    let d = (document.get("event_time") as! Timestamp).dateValue()
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "MM-dd-YYYY"
//                    let taskDate = dateFormatter.string(from: d)
//                    print("task date is \(taskDate)")
//                    if self.selectedDate == taskDate {
//                        let event_name = document.data()["event_name"] as! String
//                        let event_detail = document.data()["event_description"] as! String
//                        self.tasks.append(event_name)
//                        self.descript.append(event_detail)
//                    }
//                }
//                self.tableView.reloadData()
//            }
//        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let cellFrame = cell.frame
        print(cellFrame)
        let popoverDetailController = self.storyboard?.instantiateViewController(identifier: "detail") as? PopoverDetailController
        popoverDetailController?.text = descript[indexPath.row]
        popoverDetailController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverDetailController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .down
            popoverPresentationController.sourceView = self.tableView
            popoverPresentationController.sourceRect = cellFrame
            popoverPresentationController.delegate = self
            
            if let popoverController = popoverDetailController {
                print(popoverController.view.frame)
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func fetchFollowings(){
        followings = [:]
        user = []
        uids = []
        rows = []
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    var followingsID = document.data()["followings"] as! Array<String>
                    followingsID.insert(self.uid, at: 0)
                    for id in followingsID{
                        self.db.collection("users").whereField("uid", isEqualTo: id).getDocuments { snapshot2, error2 in
                            if error2 != nil{
                                print(error2!)
                            }
                            else{
                                for document2 in (snapshot2?.documents)! {
                                    self.user.append(document2.data()["username"] as! String)
                                    self.uids.append(id)
                                }
                                self.db.collection("events").whereField("uid", isEqualTo: id).whereField("completed", isEqualTo: false).getDocuments { snapshot3, error3 in
                                    if error3 != nil{
                                        print(error3!)
                                    }
                                    else{
                                        var stuff: [String] = []
                                        var dates: [String] = []
                                        for document3 in (snapshot3?.documents)! {
                                            stuff.append(document3.data()["event_name"] as! String)
                                            let d = (document3.get("event_time") as! Timestamp).dateValue()
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "MM-dd-YYYY"
                                            let taskDate = dateFormatter.string(from: d)
                                            dates.append(taskDate)
                                        }
                                        self.followings[self.user[self.uids.firstIndex(of: id)!]] = stuff
                                        self.tableRows[self.user[self.uids.firstIndex(of: id)!]] = dates
                                        var count = 0
                                        for day in dates {
                                            if day == self.selectedDate {
                                                count += 1
                                            }
                                        }
                                        self.rows.append(count)
                                    }
                                    self.tableView.reloadData()
                                }
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
}
