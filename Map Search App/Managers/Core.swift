//
//  Core.swift
//  Map Search App
//
//  Created by Константин Малков on 16.02.2023.
/*
 This class is for onboarding checking.
 Check if it was opened first time. If opened, next times Onboarding view would not display again.
 */

import UIKit

class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser()  {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}
