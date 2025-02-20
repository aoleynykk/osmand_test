//
//  UIDevice + ext.swift
//  osmand_test
//
//  Created by Alex Oliynyk on 20.02.2025.
//

import Foundation
import UIKit

extension UIDevice {
    private func formatToGB(_ bytes: Int64) -> Double {
        return Double(bytes) / 1_073_741_824.0
    }

    var totalDiskSpace: Double {
        return formatToGB(totalDiskSpaceInBytes)
    }

    var freeDiskSpace: Double {
        return formatToGB(freeDiskSpaceInBytes)
    }

    var usedDiskSpace: Double {
        return formatToGB(usedDiskSpaceInBytes)
    }

    private var totalDiskSpaceInBytes: Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }

    private var freeDiskSpaceInBytes: Int64 {
        if let space = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
            return space
        } else {
            return 0
        }
    }

    private var usedDiskSpaceInBytes: Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}
