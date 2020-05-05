//
//  PlayData.swift
//  Reversi
//
//  Created by 槇野郁弥 on 2020/05/05.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import UIKit

class PlayData {
    
    static let shared = PlayData()
    private init() {
        
    }
    
    enum FileIOError: Error {
        case write(path: String, cause: Error?)
        case read(path: String, cause: Error?)
    }
    
    enum Player: Int {
        case manual = 0
        case computer = 1
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
    
    /// ゲームの状態をファイルから読み込み、復元します。
    class func loadGame(boardView: BoardView) throws {
        var path: String {
            (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game")
        }
        
        let input = try String(contentsOfFile: path, encoding: .utf8)
        var lines: ArraySlice<Substring> = input.split(separator: "\n")[...]
        
        guard var line = lines.popFirst() else {
            throw FileIOError.read(path: path, cause: nil)
        }
        
        do { // turn
            guard
                let diskSymbol = line.popFirst(),
                let disk = Optional<Disk>(symbol: diskSymbol.description)
            else {
                throw FileIOError.read(path: path, cause: nil)
            }
            
            NotificationCenter.default.post(name: .updateTurnNotify, object: nil, userInfo: ["disc": disk as Any])
        }

        // players
        for side in Disk.sides {
            guard
                let playerSymbol = line.popFirst(),
                let playerNumber = Int(playerSymbol.description),
                let player = Player(rawValue: playerNumber)
            else {
                throw FileIOError.read(path: path, cause: nil)
            }

            NotificationCenter.default.post(name: .updatePlayerControlsNotify, object: nil, userInfo: ["rawValue": player.rawValue, "side": side])
        }

        do { // board
            guard lines.count == boardView.height else {
                throw FileIOError.read(path: path, cause: nil)
            }
            
            var y = 0
            while let line = lines.popFirst() {
                var x = 0
                for character in line {
                    let disk = Disk?(symbol: "\(character)").flatMap { $0 }
                    boardView.setDisk(disk, atX: x, y: y, animated: false)
                    x += 1
                }
                guard x == boardView.width else {
                    throw FileIOError.read(path: path, cause: nil)
                }
                y += 1
            }
            guard y == boardView.height else {
                throw FileIOError.read(path: path, cause: nil)
            }
        }

        NotificationCenter.default.post(name: .updateMessageViewsNotify, object: nil)
        NotificationCenter.default.post(name: .updateCountLabelsNotify, object: nil)
    }
}
