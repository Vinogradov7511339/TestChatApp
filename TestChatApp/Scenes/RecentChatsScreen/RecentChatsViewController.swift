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

    @IBAction func createChatButtonTouchUpInside(_ sender: UIBarButtonItem) {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "usersScreen")
        guard let controller = controller as? UsersViewController else {
            return
        }
        navigationController?.pushViewController(controller, animated: true)
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

    func open(recent: RecentChat) {
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        let controller = ChatViewController(recent: recent)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatItem = searchController.isActive ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        FRecentListener.shared.nulifyUnreadCounter(chatItem)
        open(recent: chatItem)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let chatItem = searchController.isActive ? filteredChatItems[indexPath.row] : chatItems[indexPath.row]
        FRecentListener.shared.delete(recent: chatItem)
        let _ = searchController.isActive ? filteredChatItems.remove(at: indexPath.row) : chatItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
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
