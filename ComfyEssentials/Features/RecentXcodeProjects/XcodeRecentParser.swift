//
//  XcodeRecentParser.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/1/26.
//
//  Summary:
//  Reads and decodes Xcode's recent-projects list stored in the
//  binary `.sfl4` file located at:
//
//  ~/Library/Application Support/com.apple.sharedfilelist/
//  com.apple.LSSharedFileList.ApplicationRecentDocuments/
//  com.apple.dt.xcode.sfl4
//
//  Notes:
//  - The `.sfl4` file is a keyed archive (binary property list).
//  - Requires Full Disk Access permissions.
//

import Foundation

actor XcodeRecentParser {

    private let sfl4URL: URL
    private let sfl4Data: Data?
    private let sfl4Error: Error?

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        sfl4URL = home
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("com.apple.sharedfilelist")
            .appendingPathComponent("com.apple.LSSharedFileList.ApplicationRecentDocuments")
            .appendingPathComponent("com.apple.dt.xcode.sfl4")

        do {
            sfl4Data = try Data(contentsOf: sfl4URL)
            sfl4Error = nil
        } catch {
            sfl4Data = nil
            sfl4Error = error
        }
    }
    
    public func getXcodeItems() -> [XcodeFile]? {
        guard let data = sfl4Data else {
            print("Xcode sfl4 contents nil: \(sfl4Error?.localizedDescription ?? "unknown error")")
            return nil
        }
        
        guard let items = items(from: unarchiveBinaryPlist(data)) else { return nil }
        
        return items.compactMap { item -> XcodeFile? in
            guard let bookmark = item["Bookmark"] as? Data ?? item["bookmark"] as? Data else {
                return nil
            }
            var stale: ObjCBool = false
            guard let url = try? NSURL(
                resolvingBookmarkData: bookmark,
                options: [.withoutUI, .withoutMounting],
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            ) as URL else { return nil }
            
            return XcodeFile(url: url)
        }
    }
    
    public func readPlistFile(at url: URL) -> String {
        guard let data = try? Data(contentsOf: url) else {
            print("Error extracting data from: \(url)")
            return ""
        }
        print("Data extracted from: \(url) contents: \(data)")
        let unarchived = propertyList(from: data)
        print("Unarchived: \(String(describing: unarchived))")
        return ""
    }

}

// MARK: - Helpers
extension XcodeRecentParser {
    private func unarchiveBinaryPlist(_ data: Data) -> Any? {
        let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver?.requiresSecureCoding = false
        return unarchiver?.decodeObject(forKey: NSKeyedArchiveRootObjectKey)
    }
    
    private func items(from dict: Any?) -> [[String: Any]]? {
        (dict as? [String: Any])?["items"] as? [[String: Any]]
    }
    
    private func propertyList(from data: Data) -> Any? {
        try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    }
}
