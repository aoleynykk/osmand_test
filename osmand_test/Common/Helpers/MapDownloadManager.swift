//
//  MapDownloadManager.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import Foundation

protocol DownloadManagerDelegate: AnyObject {
    func downloadProgress(for url: URL, progress: Float)
    func downloadCompleted(for url: URL, filePath: URL)
    func downloadFailed(for url: URL, error: Error)
}

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    private var queue: [URL] = []
    private var isDownloading = false
    weak var delegate: DownloadManagerDelegate?

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func enqueueDownload(from url: URL) {
        guard !isDownloading else {
            queue.append(url)
            return
        }
        startDownload(from: url)
    }

    private func startDownload(from url: URL) {
        isDownloading = true
        let task = session.downloadTask(with: url)
        task.resume()
    }

    func localFilePath(for url: URL) -> URL {
        let fileName = url.lastPathComponent
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(fileName)
    }

    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.delegate?.downloadProgress(for: url, progress: progress)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let destinationURL = localFilePath(for: url)

        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            DispatchQueue.main.async {
                self.delegate?.downloadCompleted(for: url, filePath: destinationURL)
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.downloadFailed(for: url, error: error)
            }
        }

        isDownloading = false
        processNextDownload()
    }

    private func processNextDownload() {
        if let nextURL = queue.first {
            queue.removeFirst()
            startDownload(from: nextURL)
        }
    }
}
