//
//  Photo.swift
//  Test_Task_Quanta
//
//  Created by Rauan on 28.05.2024.
//

import Foundation

struct Photo: Identifiable, Decodable, Equatable {
    let id: Int
    let title: String
    let url: String
}
