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
struct ConvertImageError: Error {}
struct CorruptedURLError: Error {}
struct ConvertVideoError: Error {}

class FileStorage {

    private static let storage = Storage.storage()

    class func save(file: NSData, name: String) {
        let path = documentsURL.appendingPathComponent(name, isDirectory: false)
        file.write(to: path, atomically: true)
    }

    // MARK: - Images

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

    class func downloadImage(_ url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let fileName = fileName(from: url), isFileExist(fileName) {
            let filePath = filePath(for: fileName)
            if let image = UIImage(contentsOfFile: filePath) {
                completion(.success(image))
            } else {
                completion(.failure(ConvertImageError()))
            }
        } else {
            guard let imageURL = URL(string: url) else {
                completion(.failure(CorruptedURLError()))
                return
            }
            let queue = DispatchQueue(label: "imageDownloadQueue")
            queue.async {
                if let data = NSData(contentsOf: imageURL), let fileName = fileName(from: url) {
                    FileStorage.save(file: data, name: fileName)
                    if let image = UIImage(data: data as Data) {
                        DispatchQueue.main.async {
                            completion(.success(image))
                        }
                    } else {
                        completion(.failure(ConvertImageError()))
                    }
                } else {
                    completion(.failure(ConvertImageError()))
                }
            }
        }
    }

    // MARK: - Videos

    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = storage.reference(forURL: kFilePath).child(directory)
        var task: StorageUploadTask!
        task = storageRef.putData(video as Data, metadata: nil) { metadata, error in
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
                    DispatchQueue.main.async {
                        completion(.success(url.absoluteString))
                    }
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

    class func downloadVideo(_ url: String, completion: @escaping (Result<(Bool, String), Error>) -> Void) {
        let fileName = fileName(from: url)! + ".mov"
        if isFileExist(fileName) {
            completion(.success((true, fileName)))
        } else {
            guard let videoURL = URL(string: url) else {
                completion(.failure(CorruptedURLError()))
                return
            }
            let queue = DispatchQueue(label: "videoDownloadQueue")
            queue.async {
                DispatchQueue.main.async {
                    if let data = NSData(contentsOf: videoURL) {
                        FileStorage.save(file: data, name: fileName)
                        completion(.success((true, fileName)))
                    } else {
                        completion(.failure(ConvertVideoError()))
                    }
                }
            }
        }
    }

    // MARK: - Audio
}

// MARK: - Helpers
extension FileStorage {
    static var documentsURL: URL {
        FileManager.default.urls(
            for: .documentDirectory,
               in: .userDomainMask).last!
    }

    static func filePath(for name: String) -> String {
        return documentsURL.appendingPathComponent(name).path
    }

    static func isFileExist(_ path: String) -> Bool {
        let fullPath = filePath(for: path)
        return FileManager.default.fileExists(atPath: fullPath)
    }
}
