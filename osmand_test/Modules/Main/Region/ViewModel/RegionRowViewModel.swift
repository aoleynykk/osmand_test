//
//  RegionRowViewModel.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import Foundation

class RegionRowViewModel: ObservableObject, DownloadManagerDelegate {
    @Published var progress: Float = 0.0
    @Published var isDownloading = false
    @Published var isDownloaded = false

    private var url: URL
    private var localFilePath: URL

    init(url: URL) {
        self.url = url
        self.localFilePath = DownloadManager.shared.localFilePath(for: url)
        self.isDownloaded = FileManager.default.fileExists(atPath: localFilePath.path)
        DownloadManager.shared.delegate = self
    }

    func startDownload() {
        guard !isDownloaded else { return }
        isDownloading = true
        DownloadManager.shared.enqueueDownload(from: url)
    }

    // MARK: - DownloadManagerDelegate
    func downloadProgress(for url: URL, progress: Float) {
        DispatchQueue.main.async {
            if self.url == url {
                print(progress)
                self.progress = progress
            }
        }
    }

    func downloadCompleted(for url: URL, filePath: URL) {
        DispatchQueue.main.async {
            if self.url == url {
                self.progress = 1.0
                self.isDownloading = false
                self.isDownloaded = true
            }
        }
    }

    func downloadFailed(for url: URL, error: Error) {
        DispatchQueue.main.async {
            if self.url == url {
                self.isDownloading = false
                self.progress = 0.0
            }
        }
    }
}
