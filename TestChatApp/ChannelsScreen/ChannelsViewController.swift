//
//  ChannelsViewController.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 02.11.2021.
//

import UIKit

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
}

// MARK: - Actions
extension ChannelsViewController {
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
    }
}

// MARK: - Local constants
extension ChannelsViewController {
    enum Const {
        static let title = NSLocalizedString("", value: "Channels", comment: "")
    }
}
