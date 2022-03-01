//
//  TextfieldsValidation.swift
//  GoogleAuthUsingFCM
//
//  Created by Admin on 01/03/22.
//

import Foundation

class TextfieldsValidation {
    static func validateSignInInput(email: String?, password: String?,confirmedPass: String?, name: String?) ->(email: String, password: String, name: String)? {
        guard let email = email else {return nil }
        guard let reEnteredPassword = confirmedPass else {return nil }
        guard let password = password else { return nil}
        guard let name = name else {return nil}
        if email.isEmpty{
            return nil
        }else {
            if password.isEmpty && reEnteredPassword.isEmpty {
                return nil
            } else {
                if password == reEnteredPassword {
                    if name.isEmpty {
                        return nil
                    }else {
                        return (email,password,name)
                    }
                } else {
                    return nil
                }
            }
        }
    }
}


//private func validateSignInInput() ->(email: String, password: String, name: String)? {
//    guard let email = emailTextField.text else {return nil }
//    guard let reEnteredPassword = reEnteredPasswordTextField.text else {return nil }
//    guard let password = passwordTextField.text else { return nil}
//    guard let name = nameTextField.text else {return nil}
//    if email.isEmpty{
//        self.resetComponentsToDefault()
//        self.showAlert(title: "Warning", message: "Enter Email")
//    }else {
//        if password.isEmpty && reEnteredPassword.isEmpty {
//            self.resetComponentsToDefault()
//            self.showAlert(title: "Warning", message: "Enter Password")
//        } else {
//            if password == reEnteredPassword {
//                if name.isEmpty {
//                    self.resetComponentsToDefault()
//                    self.showAlert(title: "Warning", message: "Enter Name!")
//                }else {
//                    return (email,password,name)
//                }
//            } else {
//                self.resetComponentsToDefault()
//                self.showAlert(title: "Warning", message: "Both Password must be same")
//            }
//        }
//    }
//    return nil
//}
