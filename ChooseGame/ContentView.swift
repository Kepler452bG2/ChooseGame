//
//  ContentView.swift
//  ChooseGame
//
//  Created by Shepard on 28.04.2025.
//

import SwiftUI

struct Player: Identifiable {
    var id: Int
    var position: CGPoint
    var isActive: Bool
}
enum Difficulty: String, CaseIterable, Codable {
    case easy = "Легкий"
    case medium = "Средний"
    case hard = "Сложный"
}
struct ContentView: View {
    @State private var playersCount: Int = 0
    @State private var players: [Player] = []
    @State private var isSelecting = false
    @State private var winner: Player? = nil
    @State private var isGameStarted = false
    @State private var showTask = false
    @State private var taskText = ""
    @State private var winnerPosition: CGPoint = .zero
    @State private var isAnimatingWinner = false
    @State private var timer: Timer? = nil
    @State private var timeLeft = 30
    @State private var modeWithElimination = false
    @State private var difficulty: Difficulty = .easy


    var body: some View {
        VStack {
            Text("Chooser Game")
                .font(.largeTitle)
                .padding()

            if !isGameStarted {
                Text("Положите пальцы на экран")
                    .padding()

                Text("Касания: \(playersCount)")
                    .font(.title)

                ZStack {
                    Color.gray.opacity(0.2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if playersCount < 10 {
                                        let player = Player(id: playersCount, position: value.location, isActive: true)
                                        players.append(player)
                                        playersCount += 1
                                    }
                                }
                        )
                }
                .frame(height: 300)

                Toggle("Режим с выбыванием", isOn: $modeWithElimination)
                    .padding()

                Picker("Выберите сложность задания", selection: $difficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button("Начать выбор") {
                    startSelection()
                }
                .padding()
                .disabled(playersCount < 2)
            } else {
                if let winner = winner {
                    VStack(spacing: 20) {
                        Text("🎉 Победил игрок №\(winner.id + 1)!")
                            .font(.largeTitle)
                            .bold()
                            .opacity(showTask ? 1 : 0)
                            .onAppear {
                                withAnimation(.easeIn(duration: 1)) {
                                    showTask = true
                                }
                            }

                        Circle()
                            .stroke(Color.green, lineWidth: 5)
                            .frame(width: 100, height: 100)
                            .position(winnerPosition)
                            .scaleEffect(isAnimatingWinner ? 1.1 : 1)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                    isAnimatingWinner.toggle()
                                }
                            }

                        if showTask {
                            Text("Задание: \(taskText)")
                                .font(.title2)
                                .padding()

                            Text("Осталось времени: \(timeLeft) секунд")
                                .font(.title2)
                                .padding()

                            Button("Выполнить задание") {
                                completeTask()
                            }
                            .padding()

                            Button("Играть снова") {
                                resetGame()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    Text("Выбираем победителя...")
                        .font(.title)
                        .padding()
                }
            }
        }
        .padding()
        .onChange(of: timeLeft) { newValue in
            if newValue == 0 {
                if modeWithElimination, let currentWinner = winner {
                    eliminatePlayer(currentWinner)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // Инициализация игры через JSON API
    func startNewGame() {
        let result = initializeNewGame(playersCount: playersCount)
        switch result {
        case .success(let jsonData):
            do {
                let decoded = try JSONDecoder().decode(GameInitializationResponse.self, from: jsonData)
                players = decoded.players.map { player in
                    Player(id: player.id, position: CGPoint(x: player.positionX, y: player.positionY), isActive: player.isActive)
                }
                playersCount = players.count
            } catch {
                print("Ошибка декодирования игроков: \(error)")
            }
        case .failure(let error):
            print("Ошибка API: \(error)")
        }
    }

    func startSelection() {
        isGameStarted = true
        winner = nil
        showTask = false
        isAnimatingWinner = true
        timeLeft = 30

        startNewGame()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            winner = players.randomElement()
            winnerPosition = winner?.position ?? .zero

            withAnimation(.easeInOut(duration: 2)) {
                winnerPosition = winner?.position ?? .zero
            }

            loadTask()

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeLeft > 0 {
                    timeLeft -= 1
                }
            }
        }
    }

    // Загрузка задания через JSON API
    func loadTask() {
        let result = getRandomTask(difficulty: difficulty)
        switch result {
        case .success(let jsonData):
            do {
                let decoded = try JSONDecoder().decode(APITaskResponse.self, from: jsonData)
                taskText = decoded.taskDescription
            } catch {
                print("Ошибка декодирования задания: \(error)")
                taskText = "Ошибка задания"
            }
        case .failure(let error):
            print("Ошибка API: \(error)")
            taskText = "Ошибка задания"
        }
        showTask = true
    }

    func completeTask() {
        if modeWithElimination, let currentWinner = winner {
            eliminatePlayer(currentWinner)
        }
        resetGame()
    }

    func eliminatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players.remove(at: index)
            playersCount -= 1
        }
    }

    func resetGame() {
        playersCount = 0
        players = []
        isGameStarted = false
        winner = nil
        showTask = false
        taskText = ""
        winnerPosition = .zero
        isAnimatingWinner = false
        timeLeft = 30
        timer?.invalidate()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
