//
//  FileStorage.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 26.10.2021.
//

import UIKit
import Firebase
import FirebaseStorage
import ProgressHUD

struct NoUploadLinkError: Error {}

class FileStorage {

    private static let storage = Storage.storage()

    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = storage.reference(forURL: kFilePath).child(directory)
        let data = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        task = storageRef.putData(data!, metadata: nil) { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()

            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NoUploadLinkError()))
                }
            }
        }

        task.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percent = progress.completedUnitCount / progress.totalUnitCount
            ProgressHUD.showProgress(CGFloat(percent))
        }
    }
}
