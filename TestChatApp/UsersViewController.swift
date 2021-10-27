//
//  UsersViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import UIKit

class UsersViewController: UITableViewController {

    // MARK: - Private variables

    private var users: [User] = []
    private var filteredUsers: [User] = []
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
