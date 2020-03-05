// @copyright Trollwerks Inc.

import Nuke

/// NukeIntegration
final class NukeIntegration: NSObject, AXNetworkIntegrationProtocol {

    private let AXNetworkIntegrationErrorDomain = "AXNetworkIntegrationErrorDomain"
    private let AXNetworkIntegrationFailedToLoadErrorCode = 6

    /// Delegate
    weak var delegate: AXNetworkIntegrationDelegate?

    private var retrieveImageTasks = NSMapTable < AXPhotoProtocol,
                                                      ImageTask >(keyOptions: .strongMemory,
                                                                  valueOptions: .strongMemory)

    func loadPhoto(_ photo: AXPhotoProtocol) {
        if photo.imageData != nil || photo.image != nil {
            DispatchQueue.toBackground { [weak self] in
                guard let self = self else { return }

                self.delegate?.networkIntegration(self, loadDidFinishWith: photo)
            }
            return
        }

        guard let url = photo.url else { return }

        let progress: ImageTask.ProgressHandler = { [weak self] _, receivedSize, totalSize in
            DispatchQueue.toBackground { [weak self] in
                guard let self = self else { return }

                self.delegate?.networkIntegration(self,
                                                  didUpdateLoadingProgress: CGFloat(receivedSize) / CGFloat(totalSize),
                                                  for: photo)
            }
        }

        let completion: ImageTask.Completion = { [weak self] result in
            guard let self = self else { return }

            self.retrieveImageTasks.removeObject(forKey: photo)

            switch result {
            case .success(let response):
                if let animated = response.image.animatedImageData {
                    photo.imageData = animated
                } else {
                    photo.image = response.image
                }
                DispatchQueue.toBackground { [weak self] in
                    guard let self = self else { return }

                    self.delegate?.networkIntegration(self, loadDidFinishWith: photo)
                }
            case .failure:
                let error = NSError(
                    domain: self.AXNetworkIntegrationErrorDomain,
                    code: self.AXNetworkIntegrationFailedToLoadErrorCode,
                    userInfo: nil
                )
                DispatchQueue.toBackground { [weak self] in
                    guard let self = self else { return }

                    self.delegate?.networkIntegration(self, loadDidFailWith: error, for: photo)
                }
            }
        }

        let task = ImagePipeline.shared.loadImage(with: url,
                                                  progress: progress,
                                                  completion: completion)
        self.retrieveImageTasks.setObject(task, forKey: photo)
    }

    func cancelLoad(for photo: AXPhotoProtocol) {
        guard let downloadTask = self.retrieveImageTasks.object(forKey: photo) else { return }
        downloadTask.cancel()
    }

    func cancelAllLoads() {
        let enumerator = self.retrieveImageTasks.objectEnumerator()

        while let downloadTask = enumerator?.nextObject() as? ImageTask {
            downloadTask.cancel()
        }

        self.retrieveImageTasks.removeAllObjects()
    }
}
