//
//  RegionCell.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import SwiftUI
import Combine

struct RegionRow: View {

    let region: Region

    @ObservedObject private var downloadManager = MapDownloadManager.shared

    @State private var isDownloading = false

    @State private var isDownloaded = false

    @State private var progress: Double = 0.0

    @State private var cancellables = Set<AnyCancellable>()

    init(region: Region) {
        self.region = region
    }

    var body: some View {
        VStack {
            HStack {
                Image("ic_custom_show_on_map")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isDownloaded || progress == 1 ? .downloadedIcon : .defaultIcon)

                VStack(alignment: .leading, spacing: 4) {
                    Text(region.name.capitalized)
                        .foregroundStyle(.black)
                        .font(.system(size: 16, weight: .regular))

                    if (isDownloading || progress != 0) && !isDownloaded {
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.blue)
                    }
                }
                .padding(.leading, 4)

                Spacer()

                if region.isAvailableToDownload && !isDownloaded {
                    Image(isDownloading ? "ic_custom_pause" : "ic_custom_download")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            if isDownloading {
                                pauseDownload()
                            } else {
                                startDownload()
                            }
                        }
                }
            }
        }
        .onChange(of: progress) { _ in
            if progress == 1 {
                isDownloaded = true
            }
        }
        .onAppear {
            checkDownloadStatus()
        }
        .onDisappear {
            downloadManager.saveDownloadData()
        }
    }

    private func startDownload() {
        guard let downloadURL = region.downloadURL else { return }

        downloadManager.startDownload(for: region.name, url: downloadURL)

        if let task = downloadManager.downloads[region.name] {
            task.$progress
                .sink { newProgress in
                    self.progress = newProgress
                }
                .store(in: &cancellables)
        }

        downloadManager.$downloads
            .map { $0[region.name] != nil }
            .sink { newIsDownloading in
                self.isDownloading = newIsDownloading
            }
            .store(in: &cancellables)

        downloadManager.$downloads
            .map { _ in downloadManager.isDownloaded(city: region.name) }
            .sink { newIsDownloaded in
                self.isDownloaded = newIsDownloaded
            }
            .store(in: &cancellables)
    }

    private func pauseDownload() {
        downloadManager.pauseDownload(for: region.name)
    }

    private func checkDownloadStatus() {
        isDownloaded = downloadManager.isDownloaded(city: region.name)
        if let task = downloadManager.downloads[region.name] {
            isDownloading = true
            progress = task.progress
        }

        if let task = downloadManager.downloads[region.name] {
            task.$progress
                .sink { newProgress in
                    self.progress = newProgress
                }
                .store(in: &cancellables)
        }
    }
}
