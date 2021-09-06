//
//  MainViewController.swift
//  BullsAndCows
//
//  Created by SERGEY SHLYAKHIN on 03.11.2020.
//

import UIKit

enum Section: Int, CaseIterable {
    case instruction
    case attempts
    case congratulation
}

class MainViewController: UITableViewController {

    //MARK: - Properties
    var tries = [String]()
    
    var currentGame: Game!
    var level = 1 {
        didSet {
            navigationItem.leftBarButtonItem?.title = "Level\(level):"
        }
    }
    private let maxLevel = 4
    private var colorsForButtons = Array("🟥🟧🟨🟩🟦🟪⬛️⬜️🟫")
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateNavigationBarButtons()
        generateToolbar()
        
        newRound(withLevel: level)
    }
    
    //MARK: - Methods
    func generateNavigationBarButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(pressedButtonCancel))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Level", style: .plain, target: self, action: #selector(pressedButtonLevel))
    }
    
    func generateToolbar() {
        var buttons = [UIBarButtonItem]()
        for _ in 0...5 {
            let button = UIBarButtonItem(title: " ", style: .plain, target: self, action: #selector(pressedColorButton(sender:)))
            buttons.append(button)
        }
        
        let barItem7 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barItem8 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pressedSubmit))
        
        toolbarItems = buttons + [barItem7, barItem8]
        
        navigationController?.isToolbarHidden = false
    }
    
    func newRound(withLevel level: Int) {
        self.level = level
        currentGame = Game(level: level)
        
        if !tries.isEmpty {
            tries.removeAll()
            tableView.reloadData()
        }
        
        newColorsForToolbarButtons()
        toolbarItems?.last?.isEnabled = false
        
        updateTitle()
    }
    
    func newColorsForToolbarButtons() {
        colorsForButtons.shuffle()
        for (index, button) in toolbarItems!.dropLast(2).enumerated() {
            button.title = String(colorsForButtons[index])
            button.isEnabled = true
        }
    }
    
    func updateTitle(with number: Int? = nil) {
        var currentTitle = ""
        if let number = number {
            currentTitle = title!.replacingOccurrences(of: " X", with: "") + String(colorsForButtons[number])
        }
        currentTitle += String(repeating: " X", count: currentGame.allLetters - currentTitle.count)
        title = currentTitle
    }
    
    @objc func pressedButtonLevel() {
        
        let message = "Choose level: "
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        for level in 1 ... maxLevel {
            let levelAction = UIAlertAction(title: "Level \(level)", style: .default, handler: { _ in self.newRound(withLevel: level)})
            alertController.addAction(levelAction)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
           
        present(alertController, animated: true, completion: nil)
    }

    func updateStatusGame() {
        if currentGame.isReadyForCheck {
            toolbarItems?.last?.isEnabled = true
            for button in toolbarItems!.dropLast(2) {
                button.title = "☝️"
                button.isEnabled = false
            }
        }
    }
    
    @objc func pressedSubmit() {
        let currentTry = title! + currentGame.checkTryWord()
        tries.append(currentTry)
        tableView.reloadData()
        
        //догадка верна
        if currentGame.isRightGuess {
            let alertController = UIAlertController(title: "WIN!", message: "\(tries.count) tries", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: { _ in self.pressedButtonCancel()})
            
            alertController.addAction(actionOK)
            
            if level < maxLevel {
                let actionNewLevel = UIAlertAction(title: "New level", style: .default, handler: { [self] _  in self.newRound(withLevel: level + 1)})
                
                alertController.addAction(actionNewLevel)
            }
            
            present(alertController, animated: true, completion: nil)
        } else {
            pressedButtonCancel()
        }
        
    }
    
    //нажата кнопка отмена
    @objc func pressedButtonCancel() {
        if !currentGame.isRightGuess {
            currentGame.cancelTryWord()
            for (index, button) in toolbarItems!.dropLast(2).enumerated() {
                button.title = String(colorsForButtons[index])
                button.isEnabled = true
            }
            updateTitle()
        }
        toolbarItems?.last?.isEnabled = false
    }
    
    //нажата цветная кнопка
    @objc func pressedColorButton(sender: UIBarButtonItem) {
        
        if let number = toolbarItems?.firstIndex(of: sender) {
            currentGame.updateTryWord(add: number)
            
            sender.isEnabled = false
            sender.title = "☝️"
            
            updateTitle(with: number)
            updateStatusGame()
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .instruction:
            return ""
        case .attempts:
            return "ATTEMPTS"
        case .congratulation:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .instruction:
            return 1
        case .attempts:
            return tries.count
        case .congratulation:
            return currentGame.isRightGuess ? 1 : 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Try", for: indexPath)
        
        switch section {
        case .instruction:
            cell.textLabel?.text = "Try guess color code."
        case .attempts:
            cell.textLabel?.text = tries[indexPath.row]
        case .congratulation:
            if currentGame.isRightGuess {
                
                let font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight(rawValue: 0.6))
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.red,
                    .paragraphStyle: paragraphStyle
                ]
                
                let attributedString = NSAttributedString(string: "Good job!!!", attributes: attributes)
                cell.textLabel?.attributedText = attributedString
            }
        }
        
        return cell
    }
    
}
