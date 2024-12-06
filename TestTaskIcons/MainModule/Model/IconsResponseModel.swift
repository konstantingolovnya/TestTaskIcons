//
//  IconResponseModel.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import Foundation

struct IconsResponseModel: Codable {
    let icons: [Icon]
}

struct Icon: Codable {
    let iconID: Int
    let tags: [String]
    let rasterSizes: [RasterSize]
    
    enum CodingKeys: String, CodingKey {
        case iconID = "icon_id"
        case tags
        case rasterSizes = "raster_sizes"
    }
}

struct RasterSize: Codable {
    let size: Int
    let sizeWidth: Int
    let sizeHeight: Int
    let formats: [IconFormat]
    
    enum CodingKeys: String, CodingKey {
        case size
        case sizeWidth = "size_width"
        case sizeHeight = "size_height"
        case formats
    }
}

struct IconFormat: Codable {
    let format: String
    let previewURL: String
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case format
        case previewURL = "preview_url"
        case downloadURL = "download_url"
    }
}
