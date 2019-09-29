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

/// FeedbackViewController
final class FeedbackViewController: UITableViewController {

    private enum Delivery {
        case api
        case mail
    }

    private let delivery: Delivery = .api

    private var replacedFeedbackSendingAction: ((Feedback) -> Void)?
    private var feedbackDidFailed: ((MFMailComposeResult, NSError) -> Void)?
    private var configuration: FeedbackConfiguration {
        didSet { updateDataSource(configuration: configuration) }
    }

    private var wireframe: FeedbackWireframeProtocol?

    private let cellFactories = [CellFactory(UserEmailCell.self),
                                 CellFactory(UserPhoneCell.self),
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

    /// :nodoc:
    init(configuration: FeedbackConfiguration) {
        self.configuration = configuration

        super.init(style: .grouped)

        wireframe = FeedbackWireframe(viewController: self,
                                      transitioningDelegate: self,
                                      imagePickerDelegate: self,
                                      mailComposerDelegate: self)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.keyboardDismissMode = .onDrag

        let backgroundView = GradientView {
            $0.set(gradient: [.dodgerBlue, .azureRadiance],
                   orientation: .topRightBottomLeft)
        }
        tableView.backgroundView = backgroundView

        cellFactories.forEach(tableView.register(with:))
        updateDataSource(configuration: configuration)

        title = L.feedbackFeedback()
        let actionTitle: String
        let action: Selector
        switch delivery {
        case .api:
            actionTitle = L.feedbackSend()
            action = #selector(sendButtonTapped(_:))
        case .mail:
            actionTitle = L.feedbackMail()
            action = #selector(mailButtonTapped(_:))
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: actionTitle,
                style: .plain,
                target: self,
                action: action
        )
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        popNavigationBarHiddenState = push(navigationController?.isNavigationBarHidden)
        navigationController?.isNavigationBarHidden = false

        configureLeftBarButtonItem()
    }

    /// :nodoc:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        popNavigationBarHiddenState? {
            self.navigationController?.isNavigationBarHidden = $0
        }
    }
}

// MARK: - UITableViewDataSource

extension FeedbackViewController {

    /// :nodoc:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return configuration.dataSource.numberOfSections
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return configuration.dataSource.section(at: section).count
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = configuration.dataSource.section(at: indexPath.section)[indexPath.row]
        return tableView.dequeueCell(to: item,
                                     from: cellFactories,
                                     for: indexPath,
                                     eventHandler: self)
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return configuration.dataSource.section(at: section).title
    }
}

// MARK: - UITableViewDelegate

extension FeedbackViewController {

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .white
        }
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
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

    /// :nodoc:
    func updated(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension FeedbackViewController: UserEmailCellEventProtocol {

    /// :nodoc:
    func userEmailTextDidChange(_ text: String?) {
        feedbackEditingService.update(userEmailText: text)
    }
}

extension FeedbackViewController: UserPhoneCellEventProtocol {

    /// :nodoc:
    func userPhoneTextDidChange(_ text: String?) {
        feedbackEditingService.update(userPhoneText: text)
    }
}

extension FeedbackViewController: BodyCellEventProtocol {

    /// :nodoc:
    func bodyCellHeightChanged() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    /// :nodoc:
    func bodyTextDidChange(_ text: String?) {
        feedbackEditingService.update(bodyText: text)
    }
}

extension FeedbackViewController: AttachmentCellEventProtocol {

    /// :nodoc:
    func showImage(of item: AttachmentItem) {
        // Pending
    }
}

private extension FeedbackViewController {

    func configureLeftBarButtonItem() {
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

    func updateDataSource(configuration: FeedbackConfiguration) { tableView.reloadData() }

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

    @objc func sendButtonTapped(_ sender: Any) {
        view.endEditing(true)
        do {
            let feedback = try feedbackEditingService.generateFeedback(configuration: configuration)
            wireframe?.contact(feedback: feedback) { [weak self] result in
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure:
                    break
                }
            }
        } catch {
            wireframe?.showFeedbackGenerationError()
        }
    }

    func terminate(_ result: MFMailComposeResult, _ error: Error?) {
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

extension FeedbackViewController: UIImagePickerControllerDelegate {

    /// :nodoc:
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

    /// :nodoc:
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        wireframe?.dismiss(completion: .none)
    }
}

extension FeedbackViewController: UINavigationControllerDelegate { }

extension FeedbackViewController: MFMailComposeViewControllerDelegate {

    /// :nodoc:
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

    /// :nodoc:
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
