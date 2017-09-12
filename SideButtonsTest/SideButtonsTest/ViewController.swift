//
//  ViewController.swift
//  SideButtonsTest
//
//  Created by MCUCSIE on 9/9/17.
//  Copyright © 2017 MCUCSIE. All rights reserved.
//

import UIKit
import RHSideButtons

class ViewController: UIViewController {

    var buttonsArr = [RHButtonView]()
    var sideButtonsView: RHSideButtons?

    override func viewDidLoad() {
        super.viewDidLoad()

        addSideButton()
    }

    func addSideButton() {
        let triggerButton = RHTriggerButtonView(pressedImage: UIImage(named: "exit_icon")!) {
            $0.image = UIImage(named: "trigger_img")
            $0.hasShadow = true
        }

        sideButtonsView = RHSideButtons(parentView: view, triggerButton: triggerButton)
        sideButtonsView?.delegate = self
        sideButtonsView?.dataSource = self
        sideButtonsView?.setTriggerButtonPosition(CGPoint(x: view.bounds.width - 85,
                                                          y: view.bounds.height - 85))

        for index in 1...3 {
            buttonsArr.append(generateButton(withImgName: "icon_\(index)"))
        }

        sideButtonsView?.reloadButtons()

    }

    func generateButton(withImgName imgName: String) -> RHButtonView {

        return RHButtonView {
            $0.image = UIImage(named: imgName)
            $0.hasShadow = true
        }

    }
}

extension ViewController: RHSideButtonsDataSource {

    func sideButtonsNumberOfButtons(_ sideButtons: RHSideButtons) -> Int {
        return buttonsArr.count
    }

    func sideButtons(_ sideButtons: RHSideButtons, buttonAtIndex index: Int) -> RHButtonView {
        return buttonsArr[index]
    }
}

extension ViewController: RHSideButtonsDelegate {

    func sideButtons(_ sideButtons: RHSideButtons, didSelectButtonAtIndex index: Int) {
        print("🍭 button index tapped: \(index)")
    }

    func sideButtons(_ sideButtons: RHSideButtons, didTriggerButtonChangeStateTo state: RHButtonState) {
        print("🍭 Trigger button")
    }
}
