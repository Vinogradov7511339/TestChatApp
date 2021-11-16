//
//  ChannelsViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import UIKit
import ProgressHUD

class ChannelsViewController: UITableViewController {

    // MARK: - Views

    @IBOutlet weak var segmentControl: UISegmentedControl!

    // MARK: - Private variables

    private var allChannels: [Channel] = []
    private var subscribedChannels: [Channel] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Const.title
        navigationItem.largeTitleDisplayMode = .always
        tableView.tableFooterView = UIView()
        loadSubscribedChannels()
        loadAllChannels()

        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        FChannelListener.shared.removeListener()
    }

    @objc func refresh() {
        if segmentControl.selectedSegmentIndex == 0 {
            loadSubscribedChannels()
        } else {
            loadAllChannels()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentControl.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelCell else {
            return UITableViewCell()
        }
        let channel = segmentControl.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        cell.configure(with: channel)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channel = segmentControl.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        if channel.memberIds.contains(User.currentId!) {
            open(channel: channel)
        } else {
            showChannelDetails(channel)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let channel = segmentControl.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        return channel.adminId != User.currentId! && channel.memberIds.contains(User.currentId!)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let channel = segmentControl.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        unfollow(from: channel)
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if segmentControl.selectedSegmentIndex == 0 {
            loadSubscribedChannels()
        } else {
            loadAllChannels()
        }
    }
}

// MARK: - Actions
extension ChannelsViewController {
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
}

// MARK: - Private
private extension ChannelsViewController {
    func loadSubscribedChannels() {
        FChannelListener.shared.loadSubscribedChannels { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let channels):
                    self.subscribedChannels = channels
                    self.refreshControl?.endRefreshing()
                    if self.segmentControl.selectedSegmentIndex == 0 {
                        self.tableView.reloadData()
                    }

                case .failure(let error):
                    self.refreshControl?.endRefreshing()
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
    }

    func loadAllChannels() {
        FChannelListener.shared.loadAllChannels { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let channels):
                    self.allChannels = channels
                    self.refreshControl?.endRefreshing()
                    if self.segmentControl.selectedSegmentIndex != 0 {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    self.refreshControl?.endRefreshing()
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
    }

    func unfollow(from channel: Channel) {
        var updatedChannel = channel
        updatedChannel.memberIds = channel.memberIds.filter { $0 != User.currentId! }
        FChannelListener.shared.upload(channel: updatedChannel) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.subscribedChannels.removeAll(where: { $0.id == channel.id })
            }
        }
    }
}

// MARK: - Navigation
private extension ChannelsViewController {
    func showChannelDetails(_ channel: Channel) {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "channelDetailController")
        guard let controller = controller as? ChannelDetailsViewController else {
            return
        }
        controller.channel = channel
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func open(channel: Channel) {
        let controller = ChannelChatViewController(channel: channel)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Local constants
extension ChannelsViewController {
    enum Const {
        static let title = NSLocalizedString("", value: "Channels", comment: "")
    }
}
