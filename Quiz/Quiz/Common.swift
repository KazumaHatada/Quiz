//
//  Common.swift
//  Quiz
//
//  Created by Kazuma Hatada on 2019/07/17.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//

import Foundation

class Common {

    /// 問題が入ったテキストファイルの中身を返却
    ///
    /// - Parameter fileName: ファイル名
    /// - Returns: 中身（String配列）
    /// - Throws: NSError:ファイルが無い時、あってもなぜか読めない時
    class func getCsvLines(_ fileName:String) throws -> Array<String> {
        
        guard let csvPath = Bundle.main.path(forResource:fileName, ofType:nil) else {
            throw NSError(domain: "ファイルがないよ", code: -1, userInfo: nil)
        }
        
        //CSVデータ読み込み
        var csvLines = [String]()
        do {
            let csvString = try String(contentsOfFile: csvPath, encoding: String.Encoding.utf8)
            csvLines = csvString.components(separatedBy: .newlines)
            csvLines.removeLast()
        } catch let error as NSError {
            throw NSError(domain: "\(error)", code: -1, userInfo: nil)
        }
    
        return csvLines
    }

    /// ある文字列に指定文字列がいくつ入ってるかカウントして返却
    ///
    /// - Parameters:
    ///   - str: 検索対象の文字列
    ///   - target: 個数を調べたい文字列
    /// - Returns: 個数
    class func getWordCount(_ str:String, _ target:String) -> Int {
        var count = 0
        var nextRange = str.startIndex..<str.endIndex //最初は文字列全体から探す
        while let range = str.range(of: target, options: .caseInsensitive, range: nextRange) { //.caseInsensitiveで探す方が、lowercaseStringを作ってから探すより普通は早い
            count += 1
            nextRange = range.upperBound..<str.endIndex //見つけた単語の次(range.upperBound)から元の文字列の最後までの範囲で次を探す
        }
        
        return count
    }
}
