//
//  StatusItemController.swift
//  CloudStatus
//
//  Created by Friedrich Gräter on 31/01/16.
//  Copyright © 2016 Friedrich Gräter. All rights reserved.
//

import Cocoa

class StatusItemController : NSObject {
	private let statusItem : NSStatusItem
	private let timerSource : dispatch_source_t
	
	override init() {
		statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
		statusItem.menu = NSMenu()
		statusItem.enabled = true

		timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
		status = BrctlStatus(appStates: [])
		
		super.init()

		// Setup menu
		statusItem.target = self
		
		// Set up timer
		dispatch_source_set_timer(timerSource, DISPATCH_TIME_NOW, NSEC_PER_SEC, NSEC_PER_SEC)
		dispatch_source_set_event_handler(timerSource) { [weak self] in
			BrctlStatus.statusWithCompletionHandler { status in
				self?.status = status
			}
		}
		dispatch_resume(timerSource)
	}
	
	deinit {
		dispatch_source_cancel(timerSource)
	}
	
	private(set) var status : BrctlStatus {
		didSet {
			statusItem.image = status.transferStatus.statusItemImage
			
			guard let menu = statusItem.menu else {
				return;
			}
			
			// Remove outdated menu entries
			menu.removeAllItems()
			
			// Add new menu items
			for appStatus in status.appStates {
				if ((appStatus.transferStatus == .Unknown) || (appStatus.transferStatus == .UpToDate)) {
					continue;
				}

				var loadingStatusTitles : [String] = []
				if appStatus.downloadingCount > 0 {
					loadingStatusTitles += ["\(appStatus.downloadingCount) down"]
				}
				if appStatus.uploadingCount > 0 {
					loadingStatusTitles += ["\(appStatus.uploadingCount) up"]
				}
				
				let appTitle = appStatus.appName + " (\(loadingStatusTitles.joinWithSeparator("; ")))"

				let newItem = NSMenuItem(title: appTitle, action: nil, keyEquivalent: "")
				newItem.enabled = false
				newItem.image = status.transferStatus.menuImage
				
				menu.addItem(newItem)
			}
			
			// Add separator before "quit" item
			if (menu.itemArray.count > 0) {
				menu.addItem(NSMenuItem.separatorItem())
			}
			
			// Add other menu items
			statusItem.menu?.addItemWithTitle("About", action: "orderFrontStandardAboutPanel:", keyEquivalent: "")
			statusItem.menu?.addItemWithTitle("Quit", action: "quit:", keyEquivalent: "")
		}
	}
}

extension TransferStatus {
	var statusItemImage : NSImage? {
		switch(self) {
		case .Unknown:
			return NSImage(named: "Cloud-Unknown")
		case .UpToDate:
			return NSImage(named: "Cloud-UpToDate")
		case .Uploading:
			return NSImage(named: "Cloud-Upload")
		case .Downloading:
			return NSImage(named: "Cloud-Download")
		case .Bidirectional:
			return NSImage(named: "Cloud-Upload")
		}
	}
	
	var menuImage : NSImage? {
		switch(self) {
			case .Unknown, .UpToDate:
				return nil
			case .Uploading:
				return NSImage(named: "Menu-Upload")
			case .Downloading:
				return NSImage(named: "Menu-Download")
			case .Bidirectional:
				return NSImage(named: "Menu-Upload")
		}
	}
}
