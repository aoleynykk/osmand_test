//
//  RegionCell.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import SwiftUI

struct RegionRow: View {

    let region: Region

    @StateObject private var viewModel: RegionRowViewModel

    init(region: Region) {
        self.region = region
        _viewModel = StateObject(wrappedValue: RegionRowViewModel(url: region.downloadURL ?? URL.applicationDirectory))
    }

    var body: some View {
        VStack {
            HStack {
                Image("ic_custom_show_on_map")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(viewModel.isDownloaded ? .downloadedIcon : .defaultIcon)

                Text(region.name.capitalized)
                    .foregroundStyle(.black)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.leading, 4)

                Spacer()

                if region.isAvailableToDownload && !viewModel.isDownloaded {
                    Image("ic_custom_download")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.defaultIcon)
                        .onTapGesture {
                            viewModel.startDownload()
                        }
                }
            }
        }
        if viewModel.isDownloading {
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle())
        }
    }
}
