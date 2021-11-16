//
//  HomeViewController.swift
//  LetsGoal
//
//  Created by Joe Pan on 11/14/21.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
        self.view.window?.rootViewController = loginVC
        
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
//        navigationController?.pushViewController(loginVC, animated: true)
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func register(_ sender: Any) {
        let registrationVC = self.storyboard?.instantiateViewController(withIdentifier: "registration") as! RegistrationViewController
        self.view.window?.rootViewController = registrationVC
        self.view.window?.makeKeyAndVisible()

    }
    
}
