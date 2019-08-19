//
//  QuizFile.swift
//  Quiz
//
//  Created by Kazuma Hatada on 2019/07/18.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//

import Foundation

class QuizFile {
    var quizFileName = ""
    
    var quizStrings = [String]()
    
    var totalQuizCount = -1
    
    var unloadedQuizID = [String]()

    init (fileName:String) throws {
        quizFileName = fileName
        
        quizStrings = try Common.getCsvLines(fileName)
        
        totalQuizCount = quizStrings.count
        
        for oneQuiz in quizStrings {
            if oneQuiz == "" {
                continue
            }
            
            if Common.getWordCount(oneQuiz, "\t") != 6 {
                print ("Invalid line: \(oneQuiz)")
                continue
            }
            
            let oneQuizArr = oneQuiz.components(separatedBy: "\t")
            guard let _:Int = Int(oneQuizArr[6]) else {
                print ("Invalid rightAnswer: \(oneQuiz)")
                continue
            }
            
            unloadedQuizID.append(oneQuizArr[0])
        }
    }
    
    func getOneQuestion (_ duplicate:Bool = false) throws
    -> (question:String, answer1:String, answer2:String, answer3:String, answer4:String, rightAnswer:String) {
        
        var oneQuiz = ""
        
        if (duplicate) {
            oneQuiz = quizStrings.randomElement()!
        } else {
            if let tempID = unloadedQuizID.randomElement() {
                let tempIDIndex = unloadedQuizID.firstIndex(of: tempID)
                oneQuiz = quizStrings.filter({ $0.hasPrefix(tempID) })[0]
                unloadedQuizID.remove(at: tempIDIndex!)
            } else {
                return ("もう問題がないよ", "", "", "", "", "99")
            }
        }
        
        let oneQuizArr = oneQuiz.components(separatedBy: "\t")
        return (oneQuizArr[1], oneQuizArr[2], oneQuizArr[3], oneQuizArr[4], oneQuizArr[5], oneQuizArr[6])
    }

    /// あと何問残ってるか
    func getRestQuizNum () -> Int {
        return unloadedQuizID.count
    }
}
