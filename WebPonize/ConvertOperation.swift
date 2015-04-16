import Cocoa

class ConvertOperation: NSOperation {
    
    let filePath: String
    let compressionLevel: Int
    let isLossless: Bool
    let isNoAlpha: Bool
    var outputDirectory: String
    var completion: (Void -> Void)?
    
    init(outputDir: String, filePath: String, compressionLevel: Int, isLossless: Bool, isNoAlpha: Bool) {
        self.outputDirectory = outputDir
        self.filePath = filePath
        self.compressionLevel = compressionLevel
        self.isLossless = isLossless
        self.isNoAlpha = isNoAlpha
        super.init()
        
        self.queuePriority = NSOperationQueuePriority.Normal
    }

    override func main() {

        if self.cancelled {
            return
        }

        let converter = libwebp(outputDirectory: outputDirectory, filePath: self.filePath)
        converter.encode(
            self.compressionLevel,
            isLossless: self.isLossless,
            isNoAlpha: self.isNoAlpha
        )
        completion?()
    }
}
