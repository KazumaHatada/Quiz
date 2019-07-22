//
//  ViewController.swift
//  Quiz
//
//  Created by Kazuma Hatada on 2019/07/17.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    let GENRE_ZATSUGAKU = "【雑学】"
    let GENRE_SPORTS = "【スポーツ】"
    let GENRE_GEINOU = "【芸能】"
    
    var qf:QuizFile? = nil
    var rightAns = ""
    
    var choosedGenre = ""
    
    var ansOK = 0
    var ansNG = 0
    
    @IBOutlet weak var lQuestion: UILabel!
    @IBOutlet weak var lResult: UILabel!
    @IBOutlet weak var lBAnswer1: UIButton!
    @IBOutlet weak var lBAnswer2: UIButton!
    @IBOutlet weak var lBAnswer3: UIButton!
    @IBOutlet weak var lBAnswer4: UIButton!
    @IBOutlet weak var lRestCount: UILabel!
    
    @IBAction func bAnswer1(_ sender: UIButton) {
        commonButtonAction(lBAnswer1.title(for: .normal))
    }

    @IBAction func bAnswer2(_ sender: UIButton) {
        commonButtonAction(lBAnswer2.title(for: .normal))
    }

    @IBAction func bAnswer3(_ sender: UIButton) {
        commonButtonAction(lBAnswer3.title(for: .normal))
    }

    @IBAction func bAnswer4(_ sender: UIButton) {
        commonButtonAction(lBAnswer4.title(for: .normal))
    }
    
    func commonButtonAction(_ answer:String?) {
        if rightAns == "99" {
            // もう問題がない時。。ジャンル選択画面を作ってそこに遷移したい
        } else if lResult.text == "" {
            // ユーザが回答した時
            if answer != nil {
                changeResultLabel(answer!)
                changeButtonColor(answer!)
            }
        } else {
            // 回答後→別の問題を出す
            do {
                try drawQuestion(qf)
            } catch {
                print("Error info: \(error)")
            }
        }
    }

    func changeResultLabel(_ answer:String) {
        if rightAns == answer {
            lResult.text = "正解！！"
            ansOK += 1
        } else {
            lResult.text = "はずれ"
            ansNG += 1
        }
    }
    
    func changeButtonColor(_ answer:String) {
        switch rightAns {
        case lBAnswer1.title(for: .normal):
            lBAnswer1.backgroundColor = UIColor.cyan
        case lBAnswer2.title(for: .normal):
            lBAnswer2.backgroundColor = UIColor.cyan
        case lBAnswer3.title(for: .normal):
            lBAnswer3.backgroundColor = UIColor.cyan
        case lBAnswer4.title(for: .normal):
            lBAnswer4.backgroundColor = UIColor.cyan
        default:
            lBAnswer1.backgroundColor = UIColor.white
            lBAnswer2.backgroundColor = UIColor.white
            lBAnswer3.backgroundColor = UIColor.white
            lBAnswer4.backgroundColor = UIColor.white
        }
    }



    ///
    ///
    /// ☆☆☆☆☆最初に呼び出される〜〜〜〜☆☆☆☆☆
    ///
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        do {
            qf = try QuizFile(fileName: choosedGenre)
            try drawQuestion(qf)
            
            // タップジェスチャーを作成します。
            let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
            
            // シングルタップで反応するように設定します。
            singleTapGesture.numberOfTapsRequired = 1
            
            // ビューにジェスチャーを設定します。
            view.addGestureRecognizer(singleTapGesture)
            
        } catch {
            print("Error info: \(error)")
        }
    }



    func drawQuestion(_ qf:QuizFile!) throws {
        let oneQuestion = try qf.getOneQuestion()
        
        lQuestion.text = oneQuestion.question
        lResult.text = ""
        
        var shownGenre = ""
        switch choosedGenre {
        case "geinou.txt":
            shownGenre = GENRE_GEINOU
        case "sports.txt":
            shownGenre = GENRE_SPORTS
        case "zatsugaku.txt":
            shownGenre = GENRE_ZATSUGAKU
        default:
            shownGenre = "【】"
        }
        lRestCount.text = "\(shownGenre)  あと\(qf.getRestQuizNum() + 1)問  正解[\(ansOK)] 誤答[\(ansNG)]"

        // 回答の選択肢は都度シャッフルする
        var ansArr = [oneQuestion.answer1, oneQuestion.answer2, oneQuestion.answer3, oneQuestion.answer4]
        ansArr.shuffle()
        lBAnswer1.setTitle(ansArr[0], for: .normal)
        lBAnswer2.setTitle(ansArr[1], for: .normal)
        lBAnswer3.setTitle(ansArr[2], for: .normal)
        lBAnswer4.setTitle(ansArr[3], for: .normal)
        
        lBAnswer1.backgroundColor = UIColor.white
        lBAnswer2.backgroundColor = UIColor.white
        lBAnswer3.backgroundColor = UIColor.white
        lBAnswer4.backgroundColor = UIColor.white
        
        switch oneQuestion.rightAnswer {
        case "1":
            rightAns = oneQuestion.answer1
        case "2":
            rightAns = oneQuestion.answer2
        case "3":
            rightAns = oneQuestion.answer3
        case "4":
            rightAns = oneQuestion.answer4
        default:
            rightAns = oneQuestion.rightAnswer // 99
        }
    }

    /// ボタン以外の場所をタップされた時
    /// - Parameter gesture: タップジェスチャーオブジェクト
    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        // 回答後→別の問題を出す
        if lResult.text != "" {
            do {
                try drawQuestion(qf)
            } catch {
                print("Error info: \(error)")
            }
        }
    }
}

