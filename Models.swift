import Foundation

struct FoodItem: Codable, Identifiable {
    let id: UUID
    var name: String
    var amount: String
    var calories: Int?
    var protein: Double?
    var fiber: Double?
}

struct Meal: Codable, Identifiable {
    let id: UUID
    var date: Date
    var title: String
    var foods: [FoodItem]
    var estimatedCalories: Int?
    var protein: Double?
    var fiber: Double?
}

@MainActor
final class MealStore: ObservableObject {
    @Published var meals: [Meal] = [] {
        didSet { save() }
    }

    private let key = "plate.meals.v1"

    init() { load() }

    var todayMeals: [Meal] {
        meals.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }

    var todayCalories: Int {
        todayMeals.compactMap(\.estimatedCalories).reduce(0, +)
    }

    var todayProtein: Double {
        todayMeals.compactMap(\.protein).reduce(0, +)
    }

    var todayFiber: Double {
        todayMeals.compactMap(\.fiber).reduce(0, +)
    }

    func add(_ meal: Meal) { meals.append(meal) }

    private func save() {
        guard let data = try? JSONEncoder().encode(meals) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Meal].self, from: data) else { return }
        meals = decoded
    }
}
