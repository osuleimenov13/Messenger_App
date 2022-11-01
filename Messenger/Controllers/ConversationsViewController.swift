//
//  ViewController.swift
//  Messenger
//
//  Created by Olzhas Suleimenov on 25.10.2022.
//

import FirebaseAuth
import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen // because by default it pops up and can be swiped down
            present(nav, animated: false) // animated: false to almost not see ConversationsViewController before login screen pops up
        }
    }
}

