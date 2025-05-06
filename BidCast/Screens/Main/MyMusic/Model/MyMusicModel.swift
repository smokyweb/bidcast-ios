//
//  MyMusicModel.swift
//  Rise Shine Swing App
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

//MARK: CategoryModel.
struct CategoryModel: Codable {
    var id: Int
    var title : String?
    var description : String?
    var icon : String?
    var bg_color : String?
    var music : [MusicModel]?
    
}
//MARK: MusicModel.
struct MusicModel : Codable{
    var id : Int?
    var title : String?
    var user_id : Int?
    var category_id : Int?
    var url : String?
    var artist_name : String?
}

// MARK: - SongModel
struct SongModel: Codable {
    var id, userID: Int?
    var categoryID: Int?
    var artistName, title: String?
    var url: String?
    var type: String?
    var appleMusicSongID: String?
    var status: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case categoryID = "category_id"
        case artistName = "artist_name"
        case title, url, type
        case appleMusicSongID = "apple_music_song_id"
        case status
    }
}


//MARK: SongListModel.
struct AddMusicModel: Codable {
    var user_id: Int?
    var id: Int?
    var category_id: String?
    var title: String?
    var artist_name: String?
    var url: String?
}


// MARK: - AddAllMusicModel
struct AddAllMusicModel: Codable {
    var artistName: String?
    var userID: Int?
    var title : String?
    var type : String?
    var appleMusicSongID: String?
    var status : Int?
    var id: Int?
    var url: String?

    enum CodingKeys: String, CodingKey {
        case artistName = "artist_name"
        case userID = "user_id"
        case title, type
        case appleMusicSongID = "apple_music_song_id"
        case url
        case status, id
    }
}

//MARK: AddFinalMusic.
struct AddFinalMusicModel : Codable{
    
}

//MARK: deleteSongFromCategoryModel.
struct deleteSongFromCategoryModel : Codable{
    
}

//MARK: DeleteMusicModel
struct DeleteMusicModel : Codable{
    
}

