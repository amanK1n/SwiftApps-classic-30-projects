//
//  ViewController.swift
//  GuessTheFlag2
//
//  Created by Sayed on 20/07/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var button1: UIButton?
    @IBOutlet var button2: UIButton?
    @IBOutlet var button3: UIButton?
    var coutries: [String] = [String]()
    var score = 0
    var correctAnswer: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.coutries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        self.setButtonStyle()
        self.askQuestion()
        print(coutries)
    }
    func askQuestion(action: UIAlertAction? = nil) {
        self.coutries.shuffle()
        self.correctAnswer = Int.random(in: 0...2)
        self.title = coutries[correctAnswer].uppercased()
        self.button1?.setImage(UIImage(named: self.coutries[0]), for: .normal)
        self.button2?.setImage(UIImage(named: self.coutries[1]), for: .normal)
        self.button3?.setImage(UIImage(named: self.coutries[2]), for: .normal)
    }
    func setButtonStyle() {
        self.button1?.tag = 0
        self.button2?.tag = 1
        self.button3?.tag = 2
        self.button1?.layer.borderWidth = 1
        self.button2?.layer.borderWidth = 1
        self.button3?.layer.borderWidth = 1
        self.button1?.layer.borderColor = UIColor.lightGray.cgColor
        self.button2?.layer.borderColor = UIColor.lightGray.cgColor
        self.button3?.layer.borderColor = UIColor.lightGray.cgColor
        self.button1?.layer.cornerRadius = 8
        self.button2?.layer.cornerRadius = 8
        self.button3?.layer.cornerRadius = 8
        self.button1?.clipsToBounds = true
        self.button2?.clipsToBounds = true
        self.button3?.clipsToBounds = true
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        var title: String
        if (sender as AnyObject).tag == self.correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong"
            score -= 1
        }
        
        let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
}

