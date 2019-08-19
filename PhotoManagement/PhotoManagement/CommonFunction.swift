//
//  CommonFunction.swift
//  PhotoManagement
//
//  Created by Kazuma Hatada on 2019/08/06.
//  Copyright © 2019 Kazuma Hatada. All rights reserved.
//

import Foundation

func formatDateToStr(_ target:Date?) -> String {
    if target != nil {
        let format = DateFormatter()
        format.timeStyle = .short
        format.dateStyle = .short
        format.locale = Locale(identifier: "ja_JP")
        // 2018/01/12 00:00
        return format.string(from: target!)
    } else {
        return "Unknown Date"
    }
}
