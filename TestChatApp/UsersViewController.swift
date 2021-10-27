//
//  UsersViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import UIKit
import ProgressHUD

class UsersViewController: UITableViewController {

    // MARK: - Private variables

    private var users: [User] = []
    private var filteredUsers: [User] = []
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureNavBar()
        downloadUsers()
    }

    func downloadUsers() {
        FUserListener.shared.downloadUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                    self.tableView.reloadData()
                case .failure(let error):
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
    }

    func configureNavBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Const.searchUser
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    func filterContent(for text: String) {
        filteredUsers = users.filter { $0.username.lowercased().contains(text.lowercased()) }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : users.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell else {
            assert(false, "wrong cell")
            return UITableViewCell()
        }
        let user  = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension UsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
        }
    }
}

extension UsersViewController {
    enum Const {
        static let searchUser = NSLocalizedString("", value: "Search user", comment: "")
    }
}
