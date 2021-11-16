//
//  PopoverDetailController.swift
//  LetsGoal
//
//  Created by Alex Xu on 11/16/21.
//

import UIKit

class PopoverDetailController: UIViewController {

    @IBOutlet weak var desc: UILabel!
    var text: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        desc.text = text
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
