//
//  CalculatorViewController.swift
//  CalculatorAssignment2
//
//  Created by sukhjeet singh sandhu on 16/06/16.
//  Copyright © 2016 sukhjeet singh sandhu. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    //MARK: views
    fileprivate let buttonsView = UIView()
    fileprivate let display: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "0"
        $0.textAlignment = .right
        $0.font = $0.font.withSize(55)
        $0.setContentHuggingPriority(251, for: .vertical)
        $0.setContentCompressionResistancePriority(751, for: .vertical)
        $0.adjustsFontSizeToFitWidth = true
        $0.backgroundColor = UIColor(red: 148/255, green: 148/255, blue: 148/255, alpha: 1)
        return $0
    }(UILabel())

    fileprivate let descriptionDisplay: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = " "
        $0.textAlignment = .right
        $0.font = $0.font.withSize(40)
        $0.setContentHuggingPriority(251, for: .vertical)
        $0.setContentCompressionResistancePriority(751, for: .vertical)
        $0.adjustsFontSizeToFitWidth = true
        $0.backgroundColor = UIColor(red: 148/255, green: 148/255, blue: 148/255, alpha: 1)
        return $0
    }(UILabel())

    //MARK: Calc properties
    fileprivate var userIsInTheMiddleOfTyping = false
    fileprivate var brain = CalculatorBrain()
    fileprivate var doesDotExists = false
    fileprivate var savedOperation: AnyObject?
    fileprivate var buttons: [[UIButton]] = []
    fileprivate let buttonTitles = [["AC", "⌫", "sin", "cos"], ["x²", "x³", "π", "e"], ["+", "±", "M", "→M"], ["-", "7", "8", "9"],["×", "4", "5", "6"], ["÷", "1", "2", "3"], ["√", ".", "0", "="]]
    fileprivate var displayValue: Double? {
        get {
            if let text = display.text, let value = Double(text) {
                return value
            } else {
                return nil
            }
        }
        set {
            if let value = newValue {
                display.text = String(value)
                descriptionDisplay.text = brain.description + (brain.isPartialResult ? "..." : "=")
            } else {
                display.text = "0"
                descriptionDisplay.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    //MARK: Lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        view.backgroundColor = .white
        createDisplay()
        createDescriptionDisplay()
        addbuttonsView()
        createButtons()
    }

    //MARK: Adding subviews
    fileprivate func createDisplay() {
        view.addSubview(display)
        view.addConstraint(NSLayoutConstraint(item: display, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: UIApplication.shared.statusBarFrame.size.height))
        view.addConstraint(NSLayoutConstraint(item: display, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 8.0))
        view.addConstraint(NSLayoutConstraint(item: display, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -8.0))
    }

    fileprivate func createDescriptionDisplay() {
        view.addSubview(descriptionDisplay)
        view.addConstraint(NSLayoutConstraint(item: descriptionDisplay, attribute: .top, relatedBy: .equal, toItem: display, attribute: .bottom, multiplier: 1.0, constant: 1.0))
        view.addConstraint(NSLayoutConstraint(item: descriptionDisplay, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 8.0))
        view.addConstraint(NSLayoutConstraint(item: descriptionDisplay, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -8.0))
        
    }

    fileprivate func addbuttonsView() {
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        view.addConstraint(NSLayoutConstraint(item: buttonsView, attribute: .top, relatedBy: .equal, toItem: descriptionDisplay, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: buttonsView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 8.0))
        view.addConstraint(NSLayoutConstraint(item: buttonsView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -8.0))
        view.addConstraint(NSLayoutConstraint(item: buttonsView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -8.0))
        view.layoutIfNeeded()
    }

    fileprivate func createButtons() {
        let buttonRows = 7
        let buttonColumns = 4
        let gapInButtonWidth: CGFloat = 1
        let gapInButtonHeight: CGFloat = 1

        for row in 0..<buttonRows {
            for column in 0..<buttonColumns {
                let button: UIButton = {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    $0.setTitle(buttonTitles[row][column], for: UIControlState())
                    if Double($0.titleLabel!.text!) != nil || $0.titleLabel!.text! == "." || $0.titleLabel!.text! == "=" {
                        $0.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
                    } else {
                        $0.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
                    }
                    $0.setTitleColor(.black, for: UIControlState())
                    $0.titleLabel?.font = $0.titleLabel?.font.withSize(30)
                    $0.addTarget(self, action: #selector(performAction), for: .touchUpInside)
                    return $0
                }(UIButton())
                buttonsView.addSubview(button)
                
                if row - 1 >= 0 {

                    // If it is not the first row, we are setting the top constraint of the button to the bottom constraint of the button above it.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: buttons[row - 1][column], attribute: .bottom, multiplier: 1.0, constant: gapInButtonHeight))

                    // we are making height of the button to equal to the height of the button above it.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: buttons[row - 1][column], attribute: .height, multiplier: 1.0, constant: 0.0))
                } else {

                    // If it is the first row, we are setting the top constraint of the button to the buttonsView's top constraint.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: buttonsView, attribute: .top, multiplier: 1.0, constant: 0.0))
                }

                if column - 1 >= 0 {

                    // If it is not the first column, we are setting the leading constraint of the button to the trailing constraint of the button behind it.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: buttons[row][column - 1], attribute: .trailing, multiplier: 1.0, constant: gapInButtonWidth))

                    // we are making width of the button to equal to the width of the button behind it.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: buttons[row][column - 1], attribute: .width, multiplier: 1.0, constant: 0.0))
                } else {

                    // If it is the first column, we are setting the leading constraint of the button to the buttonsView's leading constraint.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: buttonsView, attribute: .leading, multiplier: 1.0, constant: 0.0))
                }

                if column == buttonColumns - 1 {

                    // If it is the last column, we are setting trailing constraint of this button to the trailing constraint of buttonsView.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: buttonsView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
                }

                if row == buttonRows - 1 {

                    // If it is the last row, we are setting bottom constraint of this button to the bottom constraint of buttonsView.
                    buttonsView.addConstraint(NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: buttonsView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
                }

                if buttons.count == row {
                    buttons.append([button])
                } else {
                    buttons[row].append(button)
                }
            }
        }
    }

    //MARK: Append and backspace methods
    fileprivate func appendDigitOrDot(_ isInMiddle:Bool, title: String) {
        if isInMiddle {
            display.text = display.text! + title
            if title == "." {
                doesDotExists = true
            }
        } else {
            display.text = title
            if title == "." {
                doesDotExists = true
            }
        }
    }

    fileprivate func backSpace() {
        if display.text?.characters.count != 1 {
            if let index = display.text?.characters.index(before: (display.text?.endIndex)!) {
                let removedDigit = display.text?.remove(at: index)
                if removedDigit == "." {
                    doesDotExists = false
                }
            }
        } else {
            if brain.undo() {
                savedOperation = brain.program
                brain.program = savedOperation!
                displayValue = brain.result
            } else {
                displayValue = nil
            }
            doesDotExists = false
        }
    }

    //MARK: Target method for buttons
    func performAction(_ sender:UIButton) {
        let title = sender.currentTitle!
        if Double(title) != nil {
            appendDigitOrDot(userIsInTheMiddleOfTyping, title: title)
            userIsInTheMiddleOfTyping = true
        } else if title == "." {
            if !doesDotExists {
                appendDigitOrDot(userIsInTheMiddleOfTyping, title: title)
                userIsInTheMiddleOfTyping = true
            }
        } else if title == "⌫" {
            backSpace()
        } else if title == "M" {
            brain.setOpreand(title)
        } else if title == "→M" {
            brain.variableValues["M"] = displayValue
            if let savedOperation = savedOperation {
                brain.program = savedOperation
                displayValue = brain.result
            }
        } else {
            doesDotExists = false
            if userIsInTheMiddleOfTyping {
                brain.setOperand(displayValue!)
                userIsInTheMiddleOfTyping = false
            }
            brain.performOperation(title)
            if title == "AC" {
                displayValue = nil
                savedOperation = nil
                brain.variableValues.removeAll()
            } else {
                displayValue = brain.result
            }
            savedOperation = brain.program
        }
    }
}
