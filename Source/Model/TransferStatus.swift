//
//  TransferStatus.swift
//  CloudStatus
//
//  Created by Friedrich Gräter on 31/01/16.
//  Copyright © 2016 Friedrich Gräter. All rights reserved.
//

enum TransferStatus {
	case UpToDate, Uploading, Downloading, Bidirectional, Unknown
	
	func combineWithTransferStatus(transferStatus: TransferStatus) -> TransferStatus {
		if (transferStatus == self) {
			return self
		}
		else if (transferStatus == .UpToDate) {
			return self
		}
		else if (self == .UpToDate) {
			return transferStatus
		}
		else {
			return .Bidirectional
		}
	}
}
