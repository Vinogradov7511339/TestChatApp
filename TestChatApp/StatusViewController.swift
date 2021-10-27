//
//  StatusViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 27.10.2021.
//

import UIKit
import ProgressHUD

class StatusViewController: UITableViewController {

    // MARK: - Private variables

    private var statusArray: [String] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadStatuses()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath)
        let status = statusArray[indexPath.row]
        cell.textLabel?.text = status
        cell.accessoryType = User.currentUser?.status == status ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateCellStatus(indexPath)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .tableviewBG
        return view
    }
}

// MARK: - Private
private extension StatusViewController {
    func loadStatuses() {
        statusArray = UserDefaults.standard.object(forKey: kUserStatus) as? [String] ?? Status.allCases.map { $0.rawValue }
        tableView.reloadData()
    }

    func updateCellStatus(_ indexPath: IndexPath) {
        guard var user = User.currentUser else { return }
        user.status = statusArray[indexPath.row]
        LocalStorage.save(user: user) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            FUserListener.shared.saveUserToFirestore(user) { error in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
