//
//  DescriptionController.swift
//  AirbnbClone
//
//  Created by Oniel Rosario on 2/27/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit


protocol DescriptionDelegate: AnyObject {
    func updateDescription(desctiption: String)
}



class DescriptionController: UIViewController {
    @IBOutlet weak var descriptionInfo: UITextView!
    @IBOutlet weak var button: UIButton!
    weak var delegate: DescriptionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
descriptionInfo.layer.cornerRadius = 10
    button.layer.cornerRadius = 10
descriptionInfo.allowsEditingTextAttributes = true
        descriptionInfo.delegate = self
    }
    

    @IBAction func doneDescriptionPressed(_ sender: UIButton) {
        print("description button pressed")
       self.dismiss(animated: true, completion: nil)
    }
    
}

extension DescriptionController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text  else {
            return
        }
        delegate?.updateDescription(desctiption: text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}
