//
//  Game.swift
//  BullsAndCows
//
//  Created by SERGEY SHLYAKHIN on 04.11.2020.
//

import Foundation

struct Game {
    private var level: Int
    var word = [Int]()
    var tryWord = [Int]()
    var numbers = [0,1,2,3,4,5]
    var allLetters: Int {
        (level + 2) > numbers.count ? numbers.count : (level + 2)
    }
    var isReadyForCheck: Bool {
        guard !tryWord.isEmpty else {
            return false
        }
        return tryWord.count == allLetters
    }
    var isRightGuess: Bool {
        guard !tryWord.isEmpty else {
            return false
        }
        return tryWord == word
    }
    
    init(level: Int) {
        self.level = level
        numbers.shuffle()
        for index in 0 ... (allLetters - 1) {
            word.append(numbers[index])
        }
    }
    
    mutating func updateTryWord(add letter: Int) {
        tryWord.append(letter)
    }
    
    mutating func cancelTryWord() {
        tryWord = []
    }
    
    func checkTryWord() -> String {
        var bools = 0
        var cows = 0
        
        for (index, letter) in tryWord.enumerated() {
            if letter == word[index] {
                bools += 1
            } else if word.contains(letter) {
                cows += 1
            }
        }
        
        return " : \(bools)🐂 \(cows)🐄" //🐮
    }
}

