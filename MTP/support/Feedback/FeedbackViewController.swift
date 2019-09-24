// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
//  FeedbackViewController.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/07.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import Dispatch
import MessageUI
import UIKit

final class FeedbackViewController: UITableViewController {

    var replacedFeedbackSendingAction: ((Feedback) -> Void)?
    var feedbackDidFailed: ((MFMailComposeResult, NSError) -> Void)?
    var configuration: FeedbackConfiguration {
        didSet { updateDataSource(configuration: configuration) }
    }

    private var wireframe: FeedbackWireframeProtocol?

    private let cellFactories = [CellFactory(UserEmailCell.self),
                                 CellFactory(TopicCell.self),
                                 CellFactory(BodyCell.self),
                                 CellFactory(AttachmentCell.self),
                                 CellFactory(DeviceNameCell.self),
                                 CellFactory(SystemVersionCell.self),
                                 CellFactory(AppNameCell.self),
                                 CellFactory(AppVersionCell.self),
                                 CellFactory(AppBuildCell.self)]

    private lazy var feedbackEditingService: FeedbackEditingServiceProtocol = {
        FeedbackEditingService(editingItemsRepository: configuration.dataSource,
                               feedbackEditingEventHandler: self)
    }()

    private var popNavigationBarHiddenState: (((Bool) -> Void) -> Void)?
    private var attachmentDeleteAction: (() -> Void)? {
        let action = { self.feedbackEditingService.update(attachmentMedia: .none) }
        return feedbackEditingService.hasAttachedMedia ? action : .none
    }

    init(configuration: FeedbackConfiguration) {
        self.configuration = configuration

        super.init(style: .grouped)

        wireframe = FeedbackWireframe(viewController: self,
                                      transitioningDelegate: self,
                                      imagePickerDelegate: self,
                                      mailComposerDelegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.keyboardDismissMode = .onDrag

        cellFactories.forEach(tableView.register(with:))
        updateDataSource(configuration: configuration)

        title = L.feedbackFeedback()
        navigationItem
            .rightBarButtonItem = UIBarButtonItem(title: L.feedbackMail(),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(mailButtonTapped(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        popNavigationBarHiddenState = push(navigationController?.isNavigationBarHidden)
        navigationController?.isNavigationBarHidden = false

        configureLeftBarButtonItem()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        popNavigationBarHiddenState? {
            self.navigationController?.isNavigationBarHidden = $0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource

extension FeedbackViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return configuration.dataSource.numberOfSections
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return configuration.dataSource.section(at: section).count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = configuration.dataSource.section(at: indexPath.section)[indexPath.row]
        return tableView.dequeueCell(to: item,
                                     from: cellFactories,
                                     for: indexPath,
                                     eventHandler: self)
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return configuration.dataSource.section(at: section).title
    }
}

// MARK: - UITableViewDelegate

extension FeedbackViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = configuration.dataSource.section(at: indexPath.section)[indexPath.row]
        switch item {
        case _ as TopicItem:
            wireframe?.showTopicsView(with: feedbackEditingService)
        case _ as AttachmentItem:
            wireframe?.showAttachmentActionSheet(deleteAction: attachmentDeleteAction)
        default: ()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FeedbackViewController: FeedbackEditingEventProtocol {

    func updated(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension FeedbackViewController: UserEmailCellEventProtocol {
    func userEmailTextDidChange(_ text: String?) {
        feedbackEditingService.update(userEmailText: text)
    }
}

extension FeedbackViewController: BodyCellEventProtocol {
    func bodyCellHeightChanged() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func bodyTextDidChange(_ text: String?) {
        feedbackEditingService.update(bodyText: text)
    }
}

extension FeedbackViewController: AttachmentCellEventProtocol {
    func showImage(of item: AttachmentItem) {
        // Pending
    }
}

extension FeedbackViewController {
    private func configureLeftBarButtonItem() {
        if let navigationController = navigationController {
            if navigationController.viewControllers[0] === self {
                navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                   target: self,
                                                                   action: #selector(cancelButtonTapped(_:)))
            } else {
                // Keep the standard back button instead of "Cancel"
                navigationItem.leftBarButtonItem = .none
            }
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: self,
                                                               action: #selector(cancelButtonTapped(_:)))
        }
    }

    private func updateDataSource(configuration: FeedbackConfiguration) { tableView.reloadData() }

    @objc func cancelButtonTapped(_ sender: Any) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.first === self {
                wireframe?.dismiss(completion: .none)
            } else {
                wireframe?.pop()
            }
        } else {
            wireframe?.dismiss(completion: .none)
        }
    }

    @objc func mailButtonTapped(_ sender: Any) {
        do {
            let feedback = try feedbackEditingService.generateFeedback(configuration: configuration)
            (replacedFeedbackSendingAction ?? wireframe?.showMailComposer(with:))?(feedback)
        } catch {
            wireframe?.showFeedbackGenerationError()
        }
    }

    private func terminate(_ result: MFMailComposeResult, _ error: Error?) {
        if presentingViewController?.presentedViewController != .none {
            wireframe?.dismiss(completion: .none)
        } else {
            navigationController?.popViewController(animated: true)
        }

        if result == .failed, let error = error as NSError? {
            feedbackDidFailed?(result, error)
        }
    }
}

extension FeedbackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        switch getMediaFromImagePickerInfo(info) {
        case let media?:
            feedbackEditingService.update(attachmentMedia: media)
            wireframe?.dismiss(completion: .none)
        case _:
            wireframe?.dismiss(completion: .none)
            wireframe?.showUnknownErrorAlert()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        wireframe?.dismiss(completion: .none)
    }
}

extension FeedbackViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        if result == .failed, let error = error as NSError? {
            wireframe?.showMailComposingError(error)
        }

        wireframe?.dismiss(completion:
                          result == .cancelled ? .none : { self.terminate(result, error) })
    }
}

extension FeedbackViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DrawUpPresentationController(presentedViewController: presented,
                                            presenting: presenting)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(
    _ input: [UIImagePickerController.InfoKey: Any]
) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}
