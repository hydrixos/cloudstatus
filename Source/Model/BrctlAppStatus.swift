//
//  BrctlAppStatus.swift
//  CloudStatus
//
//  Created by Friedrich Gräter on 31/01/16.
//  Copyright © 2016 Friedrich Gräter. All rights reserved.
//

import Foundation

struct BrctlAppStatus {
	let appName : String
	
	var uploadingCount : UInt = 0
	var downloadingCount : UInt = 0
	
	init(appName: String) {
		self.appName = appName
	}
	
	var transferStatus : TransferStatus {
		get {
			let isDownloading = self.downloadingCount > 0
			let isUploading = self.uploadingCount > 0
			
			if (isDownloading && isUploading) {
				return .Bidirectional
			}
			else if (isDownloading) {
				return .Downloading
			}
			else if (isUploading) {
				return .Uploading
			}
			
			return .UpToDate
		}
	}
}
