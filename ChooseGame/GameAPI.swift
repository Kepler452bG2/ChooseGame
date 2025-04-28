//
//  GameAPI.swift
//  ChooseGame
//
//  Created by Shepard on 28.04.2025.
//
import Foundation
import SwiftUI

// Статус ошибок API
enum APIError: Error {
    case encodingFailed
}

// Структура игрока для API
struct APIPlayer: Codable {
    var id: Int
    var positionX: CGFloat
    var positionY: CGFloat
    var isActive: Bool
}

// Структура ответа на инициализацию игры
struct GameInitializationResponse: Codable {
    var success: Bool
    var message: String
    var players: [APIPlayer]
}

// Структура задания
struct APITaskResponse: Codable {
    var success: Bool
    var taskDescription: String
}

// Функция для создания новой игры и возврата JSON
func initializeNewGame(playersCount: Int) -> Result<Data, APIError> {
    var players: [APIPlayer] = []
    for index in 0..<playersCount {
        let player = APIPlayer(id: index, positionX: 0, positionY: 0, isActive: true)
        players.append(player)
    }
    
    let response = GameInitializationResponse(
        success: true,
        message: "Игра началась!",
        players: players
    )
    
    do {
        let jsonData = try JSONEncoder().encode(response)
        return .success(jsonData)
    } catch {
        return .failure(.encodingFailed)
    }
}

// Функция получения случайного задания и возврата JSON
func getRandomTask(difficulty: Difficulty) -> Result<Data, APIError> {
    let tasks: [String]
    
    switch difficulty {
    case .easy:
        tasks = ["Сделай 10 приседаний", "Покрутись вокруг себя 5 раз", "Похлопай в ладоши 20 раз"]
    case .medium:
        tasks = ["Сделай 15 отжиманий", "Пробеги на месте 30 секунд", "Прыгай на одной ноге 10 секунд"]
    case .hard:
        tasks = ["Сделай мостик", "Сядь на шпагат (или попытайся)", "Отожмись на одной руке 5 раз"]
    }
    
    let selectedTask = tasks.randomElement() ?? "Нет задания"
    
    let response = APITaskResponse(success: true, taskDescription: selectedTask)
    
    do {
        let jsonData = try JSONEncoder().encode(response)
        return .success(jsonData)
    } catch {
        return .failure(.encodingFailed)
    }
}




