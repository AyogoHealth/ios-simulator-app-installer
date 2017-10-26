import Cocoa
import Foundation

class SimulatorSelectionWindowController: NSWindowController {
    
    @IBOutlet weak var selectionPopUpButton: NSPopUpButton!
    
    var onSelected: ((Simulator) -> Void)!
    var simulators: [Simulator]!
    
    class func controller(_ simulators: [Simulator], onSelected: @escaping (Simulator) -> Void) -> SimulatorSelectionWindowController {
        let controller = SimulatorSelectionWindowController(windowNibName: "SimulatorSelection")
        controller.simulators = simulators
        controller.onSelected = onSelected
        return controller
    }
    
    override func windowDidLoad() {
        let titles = simulators.map { $0.name }
        
        selectionPopUpButton.removeAllItems()
        selectionPopUpButton.menu = NSMenu(title: "Simulators")
        selectionPopUpButton.addItems(withTitles: titles)
    }
    
    @IBAction func launchTapped(_ sender: NSButton) {
        close()
        onSelected(simulators[selectionPopUpButton.indexOfSelectedItem])
    }
    
    @IBAction func cancelTapped(_ sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
}
