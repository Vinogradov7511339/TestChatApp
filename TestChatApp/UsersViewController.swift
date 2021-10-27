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

        self.refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
        configureNavBar()
        downloadUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always // TODO: - remove maybe
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func downloadUsers() {
        FUserListener.shared.downloadUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                case .failure(let error):
                    ProgressHUD.showError(error.localizedDescription)
                    self.refreshControl?.endRefreshing()
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

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard refreshControl?.isRefreshing ?? false else {
            return
        }
        downloadUsers()
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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .tableviewBG
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
