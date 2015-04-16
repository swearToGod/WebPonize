import Cocoa

class DropView: NSView, NSDraggingDestination {
    
    var config: ApplicationConfig
        
    override init(frame: NSRect) {

        self.config = AppDelegate.getAppDelegate().config
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {

        self.config = AppDelegate.getAppDelegate().config
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let acceptDragTypes = [
            NSPasteboardTypePNG,
            NSColorPboardType,
            NSFilenamesPboardType,
            NSImage.imagePasteboardTypes()
        ]

        registerForDraggedTypes(acceptDragTypes)
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        self.config.getOutputDirectory(self.window!) { (dir: String, completion: (Void -> Void)) in
        
            let compressionLevel: Int = self.config.getCompressionLevel()
            let isLossless: Bool = self.config.getIsLossless()
            let isNoAlpha: Bool = self.config.getIsNoAlpha()
            
            // get dragged files' path
            let pboard: NSPasteboard = sender.draggingPasteboard()
            let filePaths: [String] = pboard.propertyListForType(NSFilenamesPboardType) as [String]
            
            // create operation & add into queue
            var queue = NSOperationQueue()
            queue.maxConcurrentOperationCount = 1

            for filePath in filePaths {

                let operation = ConvertOperation(
                    outputDir: dir,
                    filePath: filePath,
                    compressionLevel: compressionLevel,
                    isLossless: isLossless,
                    isNoAlpha: isNoAlpha)
                
                // Find a way to make this called after all operations are complete.
                // Otherwise, the way it is now, we can only save 1 file before we give up access to our directory.
                operation.completion = completion

                queue.addOperation(operation)
            }
        }
        
        return true
    }
    
    var onDraggingEnteredHandler: ((sender: NSDraggingInfo) -> Void)?
    
    var onDraggingExitedHandler: ((sender: NSDraggingInfo) -> Void)?
    
    var onDraggingEndedHandler: ((sender: NSDraggingInfo) -> Void)?
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation  {
        
        // delegate to view controller
        self.onDraggingEnteredHandler?(sender: sender)
        
        return NSDragOperation.Copy
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        
        // delegate to view controller
        self.onDraggingExitedHandler?(sender: sender!)
    }

    override func draggingEnded(sender: NSDraggingInfo?) {
        
        // delegate to view controller
        self.onDraggingEndedHandler?(sender: sender!)
    }
}
