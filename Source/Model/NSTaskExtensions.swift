//
//  NSTaskExtensions.swift
//  CloudStatus
//
//  Created by Friedrich Gräter on 31/01/16.
//  Copyright © 2016 Friedrich Gräter. All rights reserved.
//

import Foundation

extension NSTask {
	class func runTaskWithLaunchPath(launchPath: String, arguments: [String], completionHandler: (NSTask, String) -> Void) {
		// Setup task
		let task = NSTask()
		task.launchPath = launchPath
		task.arguments = arguments
		
		// Setup output pipe
		let pipe = NSPipe()
		task.standardOutput = pipe
		var output = String()
		
		pipe.fileHandleForReading.readabilityHandler = { readHandle in
			guard let string = String(data: readHandle.availableData, encoding: NSUTF8StringEncoding) else {
				return;
			}
			
			output.appendContentsOf(string)
		}
		
		// Setup completion handler
		task.terminationHandler = { task in
			completionHandler(task, output)
		}
		
		// Start execution
		task.launch()
	}
}
