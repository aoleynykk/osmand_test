//
//  MapDownloadManager.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 23.02.2025.
//

import SwiftUI
import Foundation

class MapDownloadManager: ObservableObject {
    static let shared = MapDownloadManager()

    @Published var downloads: [String: DownloadTask] = [:]
    private var downloadQueue = [DownloadTask]()
    private var isDownloading = false
    private var downloadedCities: Set<String> = []

    private let userDefaults = UserDefaults.standard
    private let downloadProgressKey = "downloadProgressKey"
    private let downloadedCitiesKey = "downloadedCitiesKey"

    private init() {
        loadDownloadData()
    }

    func startDownload(for city: String, url: URL) {
        guard downloads[city] == nil else { return }
        let task = DownloadTask(city: city, url: url)
        task.completionHandler = { [weak self] in
            self?.markAsDownloaded(city: city)
        }
        downloads[city] = task
        downloadQueue.append(task)
        processQueue()
    }

    func pauseDownload(for city: String) {
        guard let task = downloads[city] else { return }
        task.pause()
        processQueue()
    }

    func resumeDownload(for city: String) {
        guard let task = downloads[city] else { return }
        if task.isPaused {
            downloadQueue.append(task)
            processQueue()
        }
    }

    func isDownloaded(city: String) -> Bool {
        return downloadedCities.contains(city)
    }

    private func markAsDownloaded(city: String) {
        downloadedCities.insert(city)
        downloads.removeValue(forKey: city)
        saveDownloadData()
    }

    private func processQueue() {
        guard !isDownloading, let nextTask = downloadQueue.first else { return }
        isDownloading = true
        nextTask.start { [weak self] in
            self?.downloadQueue.removeFirst()
            self?.isDownloading = false
            self?.processQueue()
        }
    }

    private func loadDownloadData() {
        if let savedCities = userDefaults.array(forKey: downloadedCitiesKey) as? [String] {
            downloadedCities = Set(savedCities)
        }

        if let savedProgress = userDefaults.dictionary(forKey: downloadProgressKey) as? [String: Double] {
            for (city, progress) in savedProgress {
                if let task = downloads[city] {
                    task.progress = progress
                }
            }
        }
    }

    func saveDownloadData() {
        userDefaults.set(Array(downloadedCities), forKey: downloadedCitiesKey)

        var progressDict: [String: Double] = [:]
        for (city, task) in downloads {
            progressDict[city] = task.progress
        }
        userDefaults.set(progressDict, forKey: downloadProgressKey)
    }
}



class DownloadTask: NSObject, ObservableObject {
    let city: String
    let url: URL
    var task: URLSessionDownloadTask?
    var isPaused = false
    var completionHandler: (() -> Void)?

    @Published var progress: Double = 0.0

    init(city: String, url: URL) {
        self.city = city
        self.url = url
    }

    func start(completion: @escaping () -> Void) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session.downloadTask(with: url)
        task?.resume()
        self.completionHandler = completion
    }

    func pause() {
        task?.cancel(byProducingResumeData: { _ in })
        isPaused = true
    }
}

extension DownloadTask: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            self.progress = 1.0
            self.completionHandler?()
        }
    }
}
