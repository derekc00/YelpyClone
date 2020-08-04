//
//  MessagesViewController.swift
//  Yelpy
//
//  Created by Derek Chang on 8/2/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import UIKit
import MessageUI
class MessagesViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("user cancelled text msg")
            break
        case .sent:
            print("successful text msg")
            break
        case .failed:
            print("failed text msg")
            break
        default:
            return
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
