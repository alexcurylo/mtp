// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
//  TopicsViewController.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/08.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// TopicsViewController
final class TopicsViewController: UITableViewController {

    private let feedbackEditingService: FeedbackEditingServiceProtocol
    private let topics: [TopicProtocol]

    /// :nodoc:
    init(service: FeedbackEditingServiceProtocol) {
        self.feedbackEditingService = service
        self.topics = self.feedbackEditingService.topics
        super.init(style: .plain)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L.feedbackTopics()
    }
}

// MARK: - Table view data source

extension TopicsViewController {

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topics.count
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                         ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
        let topic = topics[indexPath.row]
        cell.textLabel?.text = topic.topicTitle
        return cell
    }
}

// MARK: - Table view delegate

extension TopicsViewController {

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let topic = topics[indexPath.row]
        feedbackEditingService.update(selectedTopic: topic)
        dismiss(animated: true)
    }
}
