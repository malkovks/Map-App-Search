//
//  OnboardingViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 16.02.2023.
//
//onboarding view with displaying some important elements
import UIKit



class OnboardingViewController: UIViewController {
    
    private let cellData = [
        OnboardingData(title: "Здравствуйте!", info: "Меня зовут Константин и я рад представить вашему вниманию мое приложение Поиск на Карте. Обязательно изучите информацию ниже, чтобы в полной мере насладиться использованием приложения!", image: UIImage(named: "appleMap")!),
        OnboardingData(title: "Поиск", info: "В данном приложении имеется функция как поиска стран, городов и просто улиц, так и конкретных заведений, которые могут окружать по близости пользователя. Даже учитывая ограничения от сервера, этого хватит, чтобы найти необходимые места.", image: UIImage(named: "search")!),
        OnboardingData(title: "Избранное", info: "Приложение позволяет не только искать места как при помощи поиска или ручного поиска на карте, но и также добавлять Ваши любимые места в раздел Избранное, хранить эту информацию и не переживать за ее утерю.", image: UIImage(named: "data")!),
        OnboardingData(title: "Навигация", info: "В этом приложении вы можете искать и отображать удобные маршруты из любой точки в любую другую точку, которую вам нужно. Вы можете отслеживать время и дистанцию, которую нужно пересечь, выбрав при этом вариант движение к конечной точке.", image: UIImage(named: "route")!),
        OnboardingData(title: "Геолокация", info: "Это приложение позволяет отслеживать вашу геолокацию, чтобы Вам было удобнее ориентироваться и использовать весь полноценный функционал приложения. Желаю вам хорошо провести время!", image: UIImage(named: "geolocation")!)
    
    ]
    
    private let mainTitleLabel: UILabel = {
       let label = UILabel()
        label.text = "Добро пожаловать в\nMap Search 🎉"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.tintColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.contentMode = .scaleAspectFit
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let tableViewCustom = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            Core.shared.setIsNotNewUser()
            self.dismiss(animated: true)
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        closeButton.frame = CGRect(x: view.frame.size.width-50, y: 10, width: 40, height: 40)
        mainTitleLabel.frame = CGRect(x: 20, y: 20+view.safeAreaInsets.top+20, width: view.frame.size.width-40, height: 80)
        tableViewCustom.frame = CGRect(x: 20, y: 20+view.safeAreaInsets.top+40+mainTitleLabel.frame.size.height, width: view.frame.size.width-40, height: view.frame.size.height-100)
    }
    
    @objc private func didTapDismiss(){
        Core.shared.setIsNotNewUser()
        self.dismiss(animated: true)
        return
    }
    
    private func setupView(){
        view.addSubview(mainTitleLabel)
        view.addSubview(closeButton)
        view.addSubview(tableViewCustom)
        view.backgroundColor = .secondarySystemBackground
        
        closeButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
    }
    
    private func setupNavigationBar(){
        title = "Добро пожаловать!"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func setupTableView(){
        tableViewCustom.delegate = self
        tableViewCustom.dataSource = self
        tableViewCustom.register(UITableViewCell.self, forCellReuseIdentifier: "cellOnboarding")
        tableViewCustom.backgroundColor = .secondarySystemBackground
        tableViewCustom.separatorStyle = .none
    }


}

extension OnboardingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellOnboarding")
        let data = cellData[indexPath.row]
        cell.backgroundColor = .secondarySystemBackground
        
        cell.textLabel?.text = data.title
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.image = data.image
        
        cell.detailTextLabel?.text = data.info
        cell.detailTextLabel?.numberOfLines = 0

        cell.detailTextLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
}
