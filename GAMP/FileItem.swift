//
//  FileItem.swift
//  GAMP
//
//  Created by Aleksander Marciniak on 3/23/26.
//


import Foundation
import AppKit

struct FileItem: Identifiable, Hashable {
    var id: String { url.path }
    let url: URL
    let name: String
    let isDirectory: Bool
    
    var icon: NSImage {
        NSWorkspace.shared.icon(forFile: url.path)
    }
}
