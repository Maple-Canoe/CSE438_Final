//
//  HomeViewController.swift
//  LetsGoal
//
//  Created by Joe Pan on 11/14/21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.backgroundColor = UIColor(named: "button")
        loginButton.layer.cornerRadius = 20
        loginButton.tintColor = UIColor.white
        
        registerButton.backgroundColor = UIColor(named: "button")
        registerButton.layer.cornerRadius = 20
        registerButton.tintColor = UIColor.white
        
        
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
