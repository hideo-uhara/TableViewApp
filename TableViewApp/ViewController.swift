//
// ViewController.swift
//

import Cocoa

class Location {
	var location: String
	
	init(location: String) {
		self.location = location
	}
}

class ViewController: NSViewController {
	
	let tableRowPasteboardType: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: "private.table-row") // 行の移動用
	
	var list: [Location] = [
		Location(location: "東京"),
		Location(location: "New York"),
		Location(location: "Hawaii"),
		Location(location: "Ayers Rock"),
		Location(location: "富士山"),
		Location(location: "Cape Hope"),
		Location(location: "鎌倉"),
		Location(location: "Egypt"),
		Location(location: "Everest"),
		Location(location: "Alps"),
		Location(location: "Machu Picchu"),
		Location(location: "Nile"),
		Location(location: "Niagara"),
	]
	
	var draggingDestinationFeedbackStyleRegular: Bool = true
	
	@IBOutlet var tableView: NSTableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//self.tableView.usesAlternatingRowBackgroundColors = true
		self.tableView.registerForDraggedTypes([self.tableRowPasteboardType])
	}

	override var representedObject: Any? {
		didSet {
		}
	}
	
	@IBAction func segmentedControlAction(_ sender: NSSegmentedControl) {
		
		switch sender.selectedSegment {
		case 0:
			self.draggingDestinationFeedbackStyleRegular = true
		case 1:
			self.draggingDestinationFeedbackStyleRegular = false
		default:
			break
		}
	}
}
	
extension ViewController: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.list.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let tableCellView: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TableCellView"), owner: nil) as! NSTableCellView
		let titleTextField: NSTextField = tableCellView.viewWithTag(1) as! NSTextField
		
		titleTextField.stringValue = self.list[row].location
		
		return tableCellView
	}

}

extension ViewController: NSTableViewDelegate {
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		if let tableView: NSTableView = notification.object as? NSTableView {
			let selectionIndexes: IndexSet = tableView.selectedRowIndexes
			
			selectionIndexes.forEach { (index) in
				print(self.list[index].location)
			}
		}
	}
	
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return 24.0
	}
	
	func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
		
		if self.draggingDestinationFeedbackStyleRegular {
			tableView.draggingDestinationFeedbackStyle = .regular
		} else {
			tableView.draggingDestinationFeedbackStyle = .gap
		}
	}
	
	func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		tableView.draggingDestinationFeedbackStyle = .none
	}
	
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		let item: NSPasteboardItem = NSPasteboardItem()
		
		item.setString(String(row), forType: self.tableRowPasteboardType)
		
		return item
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		
		if info.draggingSource as? NSTableView == tableView {
			if dropOperation == .above { // 行間への移動の場合
				return .move
			}
		}
		
		return []
	}
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		let pasteboard: NSPasteboard = info.draggingPasteboard
		
		if info.draggingSource as? NSTableView == tableView {
			guard let draggingRow: Int = Int(pasteboard.string(forType: self.tableRowPasteboardType)!) else {
				return false
			}
			
			// 行の移動
			var row: Int = row
			
			if draggingRow < row {
				row -= 1
			}
			
			let movedItem: Location = self.list[draggingRow]
			
			self.list.remove(at: draggingRow)
			self.list.insert(movedItem, at: row)
			
			tableView.beginUpdates()
			tableView.moveRow(at: draggingRow, to: row)
			tableView.endUpdates()
			
			return true
		} else {
			return false
		}
	}
	
}
