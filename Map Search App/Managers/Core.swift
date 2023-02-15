//
//  Core.swift
//  Map Search App
//
//  Created by Константин Малков on 16.02.2023.
//

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
