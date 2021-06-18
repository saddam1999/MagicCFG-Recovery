//
//  ViewController.swift
//  MagicCFG Recovery
//
//  Created by Jan Fabel on 04.02.21.
//

import Cocoa
import NMSSH

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async {
            main_iproxy()
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidDisappear() {
        exit(0)
    }
    

    
    @IBOutlet weak var StartBTN: NSButton!
    
    @IBAction func Erase(_ sender: Any) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "⚠️ Warning / 警告"
        alert.informativeText = "Your device will be factory resetted if you continue... Confirm your decision... / 如果您继续使用，您的设备将被工厂重置... 确认您的决定..."
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Erase / 擦除")
        alert.addButton(withTitle: "Cancel / 取消")
        let res = alert.runModal()
        if res == NSApplication.ModalResponse.alertFirstButtonReturn {
            DispatchQueue.global(qos: .background).async {
                eraseSSH()
            }
        }
        return
        
    }
    
    @IBAction func StartRecovery(_ sender: Any) {
        StartBTN.isEnabled = false
        OutputSerial.stringValue = ""
        OutputIMEI.stringValue = ""
        OutputWMac.stringValue = ""
        OutputBMac.stringValue = ""
        DispatchQueue.global(qos: .background).async { [self] in
            
            do {
                print("Starting function")
                var file = runSSH("cat") ?? "lol"
            
                /// iPhone 5S - 6Splus
                let range = NSRange(location: 0, length: file.count)
                let regex = try! NSRegularExpression(pattern: "o.[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}", options: .caseInsensitive)
                let regex2 = try! NSRegularExpression(pattern: "p.[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}", options: .caseInsensitive)
                let go = regex.matches(in: file, options: [], range: range)
                let go2 = regex2.matches(in: file, options: [], range: range)

                go.map {
                    var lol = String(file[Range($0.range, in: file)!])
                    lol.removeFirst()
                    DispatchQueue.main.async {
                        self.OutputWMac.stringValue = lol
                    }
                        }
                go2.map {
                    var lol = String(file[Range($0.range, in: file)!])
                    lol.removeFirst()
                    DispatchQueue.main.async {
                        self.OutputBMac.stringValue = lol
                    }                        }
                
                
                /// iPhone 7 - X
                
                let regex3 = try! NSRegularExpression(pattern: "WMac[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}", options: .caseInsensitive)
                let regex4 = try! NSRegularExpression(pattern: "BMac[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}", options: .caseInsensitive)
                let go3 = regex3.matches(in: file, options: [], range: range)
                let go4 = regex4.matches(in: file, options: [], range: range)

                go3.map {
                    var lol = String(file[Range($0.range, in: file)!])
                    lol = lol.replacingOccurrences(of: "WMac", with: "")
                    DispatchQueue.main.async {
                        self.OutputWMac.stringValue = lol
                    }                        }
                go4.map {
                    var lol = String(file[Range($0.range, in: file)!])
                    lol = lol.replacingOccurrences(of: "BMac", with: "")
                    DispatchQueue.main.async {
                        self.OutputBMac.stringValue = lol
                    }                        }

                let regex5 = try! NSRegularExpression(pattern: "imei..[0-9]{15}", options: .caseInsensitive)
                let regex6 = try! NSRegularExpression(pattern: "SrNm[\\x00-\\x7F]{1,2}[a-z0-9]{10,15}", options: .caseInsensitive)
                let go5 = regex5.matches(in: file, options: [], range: range)
                let go6 = regex6.matches(in: file, options: [], range: range)

                go5.map {
                    var lol = String(file[Range($0.range, in: file)!])
                    lol = lol.replacingOccurrences(of: "imei", with: "")
                    DispatchQueue.main.async {
                        self.OutputIMEI.stringValue = lol
                    }                        }
                go6.map {
                    var lol = String(file[Range($0.range, in: file)!])
                    print(lol)
                    lol = lol.replacingOccurrences(of: "SrNm", with: "")
                    lol.removeDangerousCharsForSYSCFG()
                    DispatchQueue.main.async {
                        self.OutputSerial.stringValue = lol
                    }                        }

                DispatchQueue.main.async {
                    self.StartBTN.isEnabled = true
                }
                                
            }
        }
    }
    
    @IBOutlet weak var OutputSerial: NSTextField!
    @IBOutlet weak var OutputWMac: NSTextField!
    @IBOutlet weak var OutputBMac: NSTextField!
    @IBOutlet weak var OutputIMEI: NSTextField!

    

    @IBAction func CopyIMEI(_ sender: Any) {
        let str = OutputIMEI.stringValue

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        let b = pasteboard.setString(str, forType: .string)
        print(b)
    }
    @IBAction func CopyBMac(_ sender: Any) {
        let str = OutputBMac.stringValue

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        let b = pasteboard.setString(str, forType: .string)
        print(b)
    }
    @IBAction func CopyWMac(_ sender: Any) {
        let str = OutputWMac.stringValue

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        let b = pasteboard.setString(str, forType: .string)
        print(b)
    }
    @IBAction func CopySN(_ sender: Any) {
        let str = OutputSerial.stringValue

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        let b = pasteboard.setString(str, forType: .string)
        print(b)
    }
    @IBAction func createBackup(_ sender: Any) {
        
        if OutputSerial.stringValue == "" || OutputWMac.stringValue == "" || OutputBMac.stringValue == "" {
            return
        }
        var value = OutputWMac.stringValue
        value.removeDangerousCharsForSYSCFG()
        value = parseMactoMacHex(hex: value)
        var value2 = OutputBMac.stringValue
        value2.removeDangerousCharsForSYSCFG()
        value2 = parseMactoMacHex(hex: value2)
        
        let backupSTR = """
        syscfg add SrNm \(OutputSerial.stringValue)
        syscfg add WMac \(value)
        syscfg add BMac \(value2)
        """
        DispatchQueue.main.async {
            if backupSTR != "" {
                let SaveToFile = NSSavePanel()
                SaveToFile.allowedFileTypes = ["txt"]
             SaveToFile.nameFieldStringValue = "\(self.OutputSerial.stringValue)_basic_sysCFG_backup"
                SaveToFile.begin { (result) -> Void in

                    if result.rawValue == NSFileHandlingPanelOKButton {
                        let filename = SaveToFile.url

                        do {
                            try backupSTR.write(to: filename!, atomically: true, encoding: String.Encoding.utf8)
                            print("Successfully written to \(filename!)")
                            } catch {
                            print("Failed to write to \(filename!)...\n Please check your write permissions or contact the developer!")
                        }

                    } else {
                        print("Canceled")
                    }
                 
                }
             
            }}}
}






extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension String {

    mutating func removeDangerousCharsForSYSCFG() {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_:+").inverted as NSCharacterSet
        self = (self.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
    }
}

extension String {
//: ### Base64 encoding a string
    internal func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

//: ### Base64 decoding a string
    internal func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

func parseMactoMacHex(hex: String) -> String {
    var hex = hex
    hex = hex.replacingOccurrences(of: ":", with: "")
    let v1 = hex[0...1]
    let v2 = hex[2...3]
    let v3 = hex[4...5]
    let v4 = hex[6...7]
    let v5 = hex[8...9]
    let v6 = hex[10...11]
let mac = "0x\(v4)\(v3)\(v2)\(v1) 0x0000\(v6)\(v5) 0x00000000 0x00000000"
return mac
}



extension StringProtocol {
    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension Collection {
    var pairs: [SubSequence] {
        var startIndex = self.startIndex
        let count = self.count
        let n = count/2 + count % 2
        return (0..<n).map { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return self[startIndex..<endIndex]
        }
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.dropFirst().reversed()
            where distance(to: index).isMultiple(of: n) {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}
