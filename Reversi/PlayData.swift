//
//  PlayData.swift
//  Reversi
//
//  Created by 槇野郁弥 on 2020/05/05.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import UIKit

class PlayData: NSObject {
    
    enum FileIOError: Error {
        case write(path: String, cause: Error?)
        case read(path: String, cause: Error?)
    }
    
    /// ゲームの状態をファイルに書き出し、保存します。
    class func saveGame(boardView: BoardView, turn: Disk?, playerControls: [UISegmentedControl]!) throws {
        var path: String {
            (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game")
        }
        
        var output: String = ""
        output += turn.symbol
        for side in Disk.sides {
            output += playerControls[side.index].selectedSegmentIndex.description
        }
        output += "\n"
        
        for y in boardView.yRange {
            for x in boardView.xRange {
                output += boardView.diskAt(x: x, y: y).symbol
            }
            output += "\n"
        }
        
        do {
            try output.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error {
            throw FileIOError.read(path: path, cause: error)
        }
    }
}
