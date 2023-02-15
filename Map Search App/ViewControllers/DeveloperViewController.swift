//
//  DeveloperInformationViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 30.01.2023.
//

import Foundation
import UIKit
import MessageUI
import SPAlert

class DeveloperViewController: UIViewController {
    
    private let textForView = """
                                Dear user, before using I'll hope you will read it.
                                This application is only testing example of future application,which sooner will tested and using different type of mapkit (such as 2GIS, YandexMap, Google or something like this). Before using I hope You ready that there may cause some bugs, app error and other mistakes which I possibily could make.
                                If You interested to contact with me to share some ideas, notes and problems that you get when using this application I will leave below ways to contact with me and check my projects.
                                """
    
    private let githubButton: UIButton = {
       let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Go to GitHub"
        button.configuration?.image = UIImage(named: "github_img")?.withTintColor(.black).withRenderingMode(.alwaysOriginal)
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .lightGray
        button.configuration?.baseForegroundColor = .black
        return button
    }()
    
    private let mailButton: UIButton = {
       let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Write to Mail"
        button.configuration?.image = UIImage(named: "gmail_img")
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .lightGray
        button.configuration?.baseForegroundColor = .black
        return button
    }()
    
    private let telegramButton: UIButton = {
       let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Write to Telegram"
        button.configuration?.image = UIImage(named: "telegram_img")
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .lightGray
        button.configuration?.baseForegroundColor = .black
        return button
    }()
    
    private let developerTextView: UITextView = {
       let text = UITextView()
        text.font = .systemFont(ofSize: 18, weight: .light)
        text.contentMode = .scaleAspectFit
        text.textAlignment = .justified
        text.isScrollEnabled = false
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        title = "Information from Developer"

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let top = view.safeAreaInsets.top
        let twoHeight = top
        let threeHeight = twoHeight + developerTextView.frame.size.height
        developerTextView.frame = CGRect(x: 10, y: twoHeight+20, width: view.frame.size.width-20, height: 320)
        githubButton.frame = CGRect(x: 10, y: threeHeight+30, width: view.frame.size.width-20, height: 55)
        mailButton.frame = CGRect(x: 10, y: threeHeight+40+githubButton.frame.size.height, width: view.frame.size.width-20, height: 55)
        telegramButton.frame = CGRect(x: 10, y: threeHeight+50+githubButton.frame.size.height+mailButton.frame.size.height, width: view.frame.size.width-20, height: 55)
    }
    
    @objc private func didTapDismissView(){
        dismiss(animated: true)
    }
    
    @objc private func didTapOpenGithub(){
        if let url = URL(string: "https://github.com/kokmalkok") {
            UIApplication.shared.open(url,options: [:],completionHandler: nil )
        }
    }
    
    @objc private func didTapOpenMail(){
        guard MFMailComposeViewController.canSendMail() else {
            return SPAlert.present(title: "Error opening Mail", preset: .error, haptic: .error)
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["malkov.ks.apple@gmail.com"])
        composer.setSubject("Q&A")
        composer.setMessageBody("Hello, Konstantin...", isHTML: false)
        present(composer,animated: true)
    }
    
    @objc private func didTapOpenTelegram(){
        if let url = URL(string: "https://t.me/kokmalkok") {
            UIApplication.shared.open(url,options: [:],completionHandler: nil )
        }
    }
    
    private func setupView(){
        view.addSubview(developerTextView)
        view.addSubview(githubButton)
        view.addSubview(mailButton)
        view.addSubview(telegramButton)
        developerTextView.text = textForView
        developerTextView.isEditable = false
        
        
        view.backgroundColor = .systemBackground
        
        githubButton.addTarget(self, action: #selector(didTapOpenGithub), for: .touchUpInside)
        mailButton.addTarget(self, action: #selector(didTapOpenMail), for: .touchUpInside)
        telegramButton.addTarget(self, action: #selector(didTapOpenTelegram), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismissView))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
}

extension DeveloperViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        switch result {
        case .cancelled:
            print("Canceled")
        case .failed:
            SPAlert.present(title: "Error", preset: .error)
        case .sent:
            SPAlert.present(title: "Mail sended successfully", preset: .done, haptic: .success)
        case .saved:
            print("saved")
        @unknown default:
            fatalError("Error of opening Mail!")
        }
        
        controller.dismiss(animated: true)
        
    }
}
