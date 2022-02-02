//
//  DocumentPickerView.swift
//  DocumentPickerView
//
//  Created by Allen Liang on 9/14/21.
//

import Foundation
import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileUrl: URL?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text], asCopy: true)
        
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(fileUrl: $fileUrl)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var fileUrl: URL?
        
        init(fileUrl: Binding<URL?>) {
            _fileUrl = fileUrl
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            fileUrl = urls[0]
        }
    }
}

struct UIActivityViewControllerView: UIViewControllerRepresentable {
    let data: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let ac = UIActivityViewController(activityItems: data, applicationActivities: nil)
        print(data)
        return ac
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIActivityViewController
}
