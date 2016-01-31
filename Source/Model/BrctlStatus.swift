//
//  BrctlStatus
//  CloudStatus
//
//  Created by Friedrich Gräter on 31/01/16.
//  Copyright © 2016 Friedrich Gräter. All rights reserved.
//

import Foundation

struct BrctlStatus {
	let appStates : [BrctlAppStatus]
	let transferStatus : TransferStatus

	init(appStates: [BrctlAppStatus]) {
		self.appStates = appStates
		var transferStatus = TransferStatus.UpToDate
		
		for appState in appStates {
			transferStatus = appState.transferStatus.combineWithTransferStatus(transferStatus)
		}
		
		self.transferStatus = transferStatus
	}

	static func statusWithCompletionHandler(completionHandler: BrctlStatus -> Void) {
		NSTask.runTaskWithLaunchPath("/usr/bin/brctl", arguments: ["status"]) { (task, output) -> Void in
			completionHandler(BrctlStatus(appStates: parseAppStatesFromOutput(output)))
		}
	}
	
	private static func parseAppStatesFromOutput(output: String) -> [BrctlAppStatus] {
		var appStates : [BrctlAppStatus] = []

		var lastAppStatus : BrctlAppStatus?
		
		output.enumerateLines { (line, stop) -> () in
			// Start new app status
			if line.hasPrefix("<") {
				guard let nameRange = line.rangeOfString("[a-zA-Z0-9.]+", options: .RegularExpressionSearch, range: Range(start: line.startIndex.advancedBy(1), end: line.endIndex)) else {
					return;
				}

				let currentAppIdentifier = line.substringWithRange(nameRange)
				if (currentAppIdentifier.characters.count == 0) {
					return;
				}
				
				let currentAppName = currentAppIdentifier.componentsSeparatedByString(".").last!.capitalizedString
				
				if let lastAppStatus = lastAppStatus {
					appStates.append(lastAppStatus)
				}

				lastAppStatus = BrctlAppStatus(appName: currentAppName)
			}

			// Increment download counter
			if line.rangeOfString("\\s*\\> download", options: .RegularExpressionSearch) != nil {
				lastAppStatus?.downloadingCount += 1
			}
			
			// Increment upload counter
			if line.rangeOfString("\\s*\\> upload", options: .RegularExpressionSearch) != nil {
				lastAppStatus?.uploadingCount += 1
			}
		}
		
		return appStates
	}
}
