//
//  ChooseGenreViewController.swift
//  Quiz
//
//  Created by Kazuma Hatada on 2019/07/19.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//


import UIKit

class ChooseGenreViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let qvc: QuizViewController = (segue.destination as? QuizViewController)!
        if (segue.identifier == "segueGeinou") {
            qvc.choosedGenre = "geinou.txt"
        } else if (segue.identifier == "segueSports") {
            qvc.choosedGenre = "sports.txt"
        } else {
            qvc.choosedGenre = "zatsugaku.txt"
        }
    }
}

