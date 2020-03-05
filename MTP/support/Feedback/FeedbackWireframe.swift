// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/25.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import MessageUI
import MobileCoreServices
import Photos

/// FeedbackWireframeProtocol
protocol FeedbackWireframeProtocol {

    /// showTopicsView
    /// - Parameter service: FeedbackEditingServiceProtocol
    func showTopicsView(with service: FeedbackEditingServiceProtocol)
    /// showMailComposer
    /// - Parameter feedback: Feedback
    func showMailComposer(with feedback: Feedback)
    /// contact with MTP API
    /// - Parameter feedback: Feedback
    /// - Parameter completion: Completion
    func contact(feedback: Feedback,
                 completion: @escaping (Result<Bool, Error>) -> Void)
    /// showAttachmentActionSheet
    /// - Parameter deleteAction: Action
    func showAttachmentActionSheet(deleteAction: (() -> Void)?)
    /// showFeedbackGenerationError
    func showFeedbackGenerationError()
    /// showUnknownErrorAlert
    func showUnknownErrorAlert()
    /// showMailComposingError
    /// - Parameter error: Error
    func showMailComposingError(_ error: NSError)
    /// dismiss
    /// - Parameter completion: Handler
    func dismiss(completion: (() -> Void)?)
    /// pop
    func pop()
}

/// FeedbackWireframe
final class FeedbackWireframe {

    private weak var viewController: UIViewController?
    private weak var transitioningDelegate: UIViewControllerTransitioningDelegate?
    private weak var imagePickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    private weak var mailComposerDelegate: MFMailComposeViewControllerDelegate?

    /// :nodoc:
    init(viewController: UIViewController,
         transitioningDelegate: UIViewControllerTransitioningDelegate,
         imagePickerDelegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
         mailComposerDelegate: MFMailComposeViewControllerDelegate) {
        self.viewController = viewController
        self.transitioningDelegate = transitioningDelegate
        self.imagePickerDelegate = imagePickerDelegate
        self.mailComposerDelegate = mailComposerDelegate
    }
}

extension FeedbackWireframe: FeedbackWireframeProtocol {

    /// :nodoc:
    func showTopicsView(with service: FeedbackEditingServiceProtocol) {
        let controller = TopicsViewController(service: service)
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = transitioningDelegate

        DispatchQueue.main.async { self.viewController?.present(controller, animated: true) }
    }

    /// :nodoc:
    func showMailComposer(with feedback: Feedback) {
        guard MFMailComposeViewController.canSendMail() else { return showMailConfigurationError() }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = mailComposerDelegate
        controller.setToRecipients(feedback.to)
        controller.setCcRecipients(feedback.cc)
        controller.setBccRecipients(feedback.bcc)
        controller.setSubject(feedback.subject)
        controller.setMessageBody(feedback.body, isHTML: feedback.isHTML)
        if let jpeg = feedback.jpeg {
            controller.addAttachmentData(jpeg, mimeType: "image/jpeg", fileName: "screenshot.jpg")
        } else if let mp4 = feedback.mp4 {
            controller.addAttachmentData(mp4, mimeType: "video/mp4", fileName: "screenshot.mp4")
        }
        viewController?.present(controller, animated: true)
    }

    /// :nodoc:
    func showAttachmentActionSheet(deleteAction: (() -> Void)?) {
        let alertController = UIAlertController(title: .none,
                                                message: .none,
                                                preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(
                UIAlertAction(title: L.feedbackPhotoLibrary(),
                              style: .default) { _ in self.showImagePicker(sourceType: .photoLibrary) })
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(
                UIAlertAction(title: L.feedbackCamera(),
                              style: .default) { _ in self.showImagePicker(sourceType: .camera) })
        }

        if let delete = deleteAction {
            alertController.addAction(
                UIAlertAction(title: L.feedbackDelete(),
                              style: .destructive) { _ in delete() })
        }

        alertController.addAction(UIAlertAction(title: L.feedbackCancel(),
                                                style: .cancel))
        let screenSize = UIScreen.main.bounds
        alertController.popoverPresentationController?.sourceView = viewController?.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,
                                                                           y: screenSize.size.height / 2,
                                                                           width: 0,
                                                                           height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)

        viewController?.present(alertController, animated: true)
    }

    /// :nodoc:
    func showFeedbackGenerationError() {
        let alertController = UIAlertController(title: L.feedbackError(),
                                                message: L.feedbackFeedbackGenerationErrorMessage(),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L.feedbackDismiss(),
                                                style: .cancel))
        viewController?.present(alertController, animated: true)
    }

    /// :nodoc:
    func showUnknownErrorAlert() {
        let title = L.feedbackUnknownError()
        let alertController = UIAlertController(title: title,
                                                message: .none,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L.feedbackDismiss(),
                                                style: .default))
        viewController?.present(alertController, animated: true)
    }

    /// :nodoc:
    func showMailComposingError(_ error: NSError) {
        let alertController = UIAlertController(title: L.feedbackError(),
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L.feedbackDismiss(),
                                                style: .cancel))
        viewController?.present(alertController, animated: true)
    }

    /// :nodoc:
    func dismiss(completion: (() -> Void)?) {
        viewController?.dismiss(animated: true, completion: completion)
    }

    /// :nodoc:
    func pop() { viewController?.navigationController?.popViewController(animated: true) }
}

private extension FeedbackWireframe {

    func showMailConfigurationError() {
        let alertController = UIAlertController(title: L.feedbackError(),
                                                message: L.feedbackMailConfigurationErrorMessage(),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L.feedbackDismiss(),
                                                style: .cancel))
        viewController?.present(alertController, animated: true)
    }

    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .photoLibrary,
           PHPhotoLibrary.authorizationStatus() == .notDetermined {
            if !UIApplication.isTesting {
                PHPhotoLibrary.requestAuthorization { _ in }
            }
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [kUTTypeImage as String]
                                  //, kUTTypeMovie as String
        imagePicker.allowsEditing = false
        imagePicker.delegate = imagePickerDelegate
        imagePicker.modalPresentationStyle = .formSheet
        let presentation = imagePicker.popoverPresentationController
        presentation?.permittedArrowDirections = .any
        presentation?.sourceView = viewController?.view
        presentation?.sourceRect = viewController?.view.frame ?? CGRect.zero
        viewController?.present(imagePicker, animated: true)
    }
}

extension FeedbackWireframe: ServiceProvider {

    func contact(feedback: Feedback,
                 completion: @escaping (Result<Bool, Error>) -> Void) {
        note.modal(info: L.contactingMTP())

        guard let jpeg = feedback.jpeg else {
            contact(payload: ContactPayload(
                        with: feedback,
                        image: nil,
                        user: data.user
                    ),
                    completion: completion)
            return
        }

        net.mtp.upload(
            photo: jpeg,
            caption: nil,
            location: nil) { [weak self] result in
                guard let self = self else {
                    Services().note.dismissModal()
                    return
                }

                switch result {
                case .success(let reply):
                    self.contact(payload: ContactPayload(
                                    with: feedback,
                                    image: reply,
                                    user: self.data.user
                                 ),
                                 completion: completion)
                case .failure(let error):
                    self.note.modal(failure: error,
                                    operation: L.contactMTP())
                    completion(.failure(error))
                }
        }
    }

    private func contact(payload: ContactPayload,
                         completion: @escaping (Result<Bool, Error>) -> Void) {
        net.contact(payload: payload) { [note] result in
             switch result {
             case .success:
                 note.modal(success: L.success())
                 DispatchQueue.main.asyncAfter(deadline: .short) {
                     note.dismissModal()
                     completion(.success(true))
                 }
                 return
             case .failure(let error):
                 note.modal(failure: error,
                            operation: L.contactMTP())
                 completion(.failure(error))
            }
        }
    }
}
