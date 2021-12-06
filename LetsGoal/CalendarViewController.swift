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
    var tasks : [String: [String]] = [:]
    var detail: [String: [String]] = [:]
    var selectedDate: String = ""
    var descript: [String] = []
    var followings: [String: [String]] = [:]
    var tableRows: [String: [String]] = [:]
    var user: [String] = []
    var uids: [String] = []
    var rows: [Int] = []
    var index: Int = 0
    var reverseBool: Bool = true
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if calendar.selectedDate == nil {
            return 0
        }
        print("current section is \(section)")
        print("number of rows is \(rows[section])")
        return rows[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return followings.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tableView.dequeueReusableCell(withIdentifier: "t")! as UITableViewCell
        if calendar.selectedDate != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-YYYY"
            let day = dateFormatter.string(from: calendar.selectedDate!)
            if tasks[day] != nil {
                //print("whatever \(String(describing: tasks[day]))")
                //print("index is \(index)")
                task.textLabel!.text = "Task \(indexPath.row + 1): \(tasks[day]![index])"
                if tasks[day]!.count != index + 1 {
                    index += 1
                }
                task.textLabel!.textColor = UIColor.white
                if(indexPath.row % 2 == 0){
                    task.backgroundColor = UIColor(named: "table")
                } else{
                    task.backgroundColor = UIColor(named: "button")
                }
                return task
            }
        }
        return UITableViewCell()
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        //print("rows is \(rows)")
//        //print("there are \(rows[section]) for \(user[section])")
//        return user[section]
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(named: "light_background_color")
        let label = UILabel()
        label.text = user[section]
        label.textColor = UIColor.white
        label.frame = CGRect(x: 15, y: 5, width: 100, height: 20)
        view.addSubview(label)
        return view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchData()
        fetchFollowings()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if calendar.selectedDate != nil {
            calendar.deselect(calendar.selectedDate!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "t")
        tableView.backgroundColor = UIColor(named: "background_color")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        index = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        selectedDate = dateFormatter.string(from: date)
        //print("calendar date is \(String(describing: selectedDate))")
        rows = []
        for u in user {
            var count = 0
            for day in tableRows[u]! {
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
        var index = 0
        for i in 0...indexPath.section {
            index += rows[i]
        }
        index = index - rows[indexPath.section]
        popoverDetailController?.text = detail[selectedDate]![index + indexPath.row]
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
        tableRows = [:]
        user = []
        uids = []
        rows = Array(repeating: 0, count: user.count)
        tasks = [:]
        detail = [:]
        index = 0
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    var followingsID = document.data()["followings"] as! Array<String>
                    followingsID.insert(self.uid, at: 0)
                    print("followingID is \(followingsID)")
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
                                        var event_detail: [String] = []
                                        for document3 in (snapshot3?.documents)! {
                                            let fetchedEvent = document3.data()["event_name"] as! String
                                            let fetchedDescription = document3.data()["event_description"] as! String
                                            stuff.append(fetchedEvent)
                                            event_detail.append(fetchedDescription)
                                            let d = (document3.get("event_time") as! Timestamp).dateValue()
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "MM-dd-YYYY"
                                            let taskDate = dateFormatter.string(from: d)
                                            dates.append(taskDate)
                                            var currentTasks = self.tasks[taskDate]
                                            var currentDetail = self.detail[taskDate]
                                            if currentTasks != nil {
                                                currentTasks!.append(fetchedEvent)
                                                self.tasks.updateValue(currentTasks!, forKey: taskDate)
                                            }
                                            else if currentTasks == nil {
                                                self.tasks[taskDate] = [fetchedEvent]
                                            }
                                            if currentDetail != nil {
                                                currentDetail!.append(fetchedDescription)
                                                self.detail.updateValue(currentDetail!, forKey: taskDate)
                                            }
                                            else if currentDetail == nil {
                                                self.detail[taskDate] = [fetchedDescription]
                                            }
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
