//
//  RecentChatsViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 29.10.2021.
//

import UIKit
import ProgressHUD

class RecentChatsViewController: UITableViewController {

    // MARK: - Private variables

    private var chatItems: [RecentChat] = []
    private var filteredChatItems: [RecentChat] = []
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureNavBar()
        dowloadChats()
    }

    func configureNavBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Const.searchChat
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    func dowloadChats() {
        FRecentListener.shared.downloadChats { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chats):
                    self.chatItems = chats
                    self.tableView.reloadData()
                case .failure(let error):
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
    }

    func filterContent(for text: String) {
        filteredChatItems = chatItems
            .filter { $0.receiverName.lowercased().contains(text.lowercased()) }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredChatItems.count : chatItems.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? RecentCell else {
            return UITableViewCell()
        }
        let chatItem = searchController.isActive ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        cell.configure(recent: chatItem)
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension RecentChatsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
        }
    }
}

extension RecentChatsViewController {
    enum Const {
        static let searchChat = NSLocalizedString("", value: "Search chat", comment: "")
    }
}
