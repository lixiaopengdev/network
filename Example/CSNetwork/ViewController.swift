//
//  ViewController.swift
//  CSNetwork
//
//  Created by dongdong on 01/06/2023.
//  Copyright (c) 2023 dongdong. All rights reserved.
//

import UIKit
import CSNetwork

class ViewController: UIViewController {

    
    @IBAction func login() {
        
        let loginService = TestService.login(name: "dd_test123")
//        Network.request(loginService) { (account: Account)  in
//            print(account.name)
//        }
                
        Network.request(loginService, type: Account.self) { account in
            print(account.name)

        }
//        Network.request(loginService) { response in
//
//        } failure: { error in
//
//        }

        
//        Network.oriRequest(TestService.login(name: "dd_test123")) { result in
//
//        }
        
    }
    
    @IBAction func card() {
        Network.oriRequest(TestService.card(name: "card_123")) { result in
            
        }
    }
    
    @IBAction func cards() {
        Network.oriRequest(TestService.cards) { result in
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

