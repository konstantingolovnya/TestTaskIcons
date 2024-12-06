//
//  ImageSaveService.swift
//  TestTaskIcons
//
//  Created by Konstantin on 04.12.2024.
//

import Foundation
import UIKit
import Photos

protocol ImageSaveServiceProtocol {
    func save(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImageSaveService: ImageSaveServiceProtocol {
    
    func save(_ image: UIImage, completion: @escaping (Result<Void, any Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(NSError(domain: "PhotoLibrary", code: 0, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"])))
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if let error = error {
                    completion(.failure(error))
                } else if success {
                    completion(.success(()))
                }
            }
        }
    }
}
