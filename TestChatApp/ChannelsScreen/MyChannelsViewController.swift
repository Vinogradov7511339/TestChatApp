//
//  MyChannelsViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import UIKit
import ProgressHUD

class MyChannelsViewController: UITableViewController {

    // MARK: - Private variables

    private var channels: [Channel] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadChannels()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? AddChannelViewController else { return }
        controller.channelToEdit = sender as? Channel
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelCell else {
            return UITableViewCell()
        }
        let channel = channels[indexPath.row]
        cell.configure(with: channel)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: "newChannelSeque", sender: channel)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let channel = channels.remove(at: indexPath.row)
        FChannelListener.shared.delete(channel: channel)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Actions
extension MyChannelsViewController {
    @IBAction func addChannelTouchUpInside(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newChannelSeque", sender: self)
    }
}

// MARK: - Private
private extension MyChannelsViewController {
    func loadChannels() {
        FChannelListener.shared.loadMyChannels { result in
            switch result {
            case .success(let channels):
                self.channels = channels
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }
}


