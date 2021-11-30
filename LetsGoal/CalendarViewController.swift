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
    
    var tasks : [String] = []
    var selectedDate: String = ""
    var descript: [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tableView.dequeueReusableCell(withIdentifier: "t")! as UITableViewCell
        task.textLabel!.text = "Task \(indexPath.row + 1): \(tasks[indexPath.row])"
        return task
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
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
        fetchData()
    }
    
    func fetchData() {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        tasks = []
        descript = []
        db.collection("events").whereField("uid", isEqualTo: uid).whereField("completed", isEqualTo: false).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    let d = (document.get("event_time") as! Timestamp).dateValue()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-YYYY"
                    let taskDate = dateFormatter.string(from: d)
                    print("task date is \(taskDate)")
                    if self.selectedDate == taskDate {
                        let event_name = document.data()["event_name"] as! String
                        let event_detail = document.data()["event_description"] as! String
                        self.tasks.append(event_name)
                        self.descript.append(event_detail)
                    }
                }
                self.tableView.reloadData()
            }
        }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
