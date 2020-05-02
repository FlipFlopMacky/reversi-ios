//
//  Referee.swift
//  Reversi
//
//  Created by 槇野郁弥 on 2020/05/02.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import UIKit

class Referee: NSObject {
    /// 盤上に置かれたディスクの枚数が多い方の色を返します。
    /// 引き分けの場合は `nil` が返されます。
    /// - Returns: 盤上に置かれたディスクの枚数が多い方の色です。引き分けの場合は `nil` を返します。
    func sideWithMoreDisks(boardView: BoardView) -> Disk? {
        let darkCount = countDisks(of: .dark, boardView: boardView)
        let lightCount = countDisks(of: .light, boardView: boardView)
        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
    
    func countDisks(of side: Disk, boardView: BoardView) -> Int {
        var count = 0
        
        for y in boardView.yRange {
            for x in boardView.xRange {
                if boardView.diskAt(x: x, y: y) == side {
                    count +=  1
                }
            }
        }
        
        return count
    }
}
