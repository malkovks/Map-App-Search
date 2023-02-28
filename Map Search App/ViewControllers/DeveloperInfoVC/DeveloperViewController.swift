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
                                Дорогие пользователи, перед использованием я надеюсь вы прочтете это сообщение.
                                Данное приложение является тестовым проектом, не являющимся коммерческим и используется только в пробной работе для тестирования кода, устройства и прочих вещей. Приложение сделано на подобие Yandex Maps, Google Maps, Apple Maps и прочие.
                                Если вы заинтересованы в том как можно улучшить данное приложение, имеются какие-либо идеи, а также вопросы относительно производительности приложения, вы можете связаться со мной при помощи ссылок, указанных ниже
                                Хорошего вам использования приложения!
                                """
    
    private let githubButton: UIButton = {
       let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Перейти на GitHub"
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
        button.configuration?.title = "Написать на почту"
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
        button.configuration?.title = "Написать в телеграмм"
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
        title = "Информация о разработчике"

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
