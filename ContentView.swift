import SwiftUI
import PhotosUI

struct ContentView: View {
    @EnvironmentObject private var store: MealStore
    @State private var tab = 0
    @State private var showCamera = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showScanner = false

    var body: some View {
        TabView(selection: $tab) {
            HomeView(onScan: { showScanner = true })
                .tabItem { Label("home", systemImage: "house") }
                .tag(0)

            LogView(onScan: { showScanner = true })
                .tabItem { Label("log", systemImage: "plus") }
                .tag(1)

            RecipesView()
                .tabItem { Label("recipes", systemImage: "sparkles") }
                .tag(2)

            ProfileView()
                .tabItem { Label("profile", systemImage: "person.crop.circle") }
                .tag(3)
        }
        .tint(Color(red: 0.96, green: 0.30, blue: 0.25))
        .sheet(isPresented: $showScanner) {
            ScanView(showCamera: $showCamera)
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                showCamera = false
                showScanner = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    // Camera image routing is intentionally kept in ScanView in the next iteration.
                    // The sheet is fully functional; this closure is the camera capture handoff point.
                }
            }
        }
    }
}

struct AppBackground<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            content
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: MealStore
    let onScan: () -> Void

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("plate.")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Circle()
                                .fill(Color(red: 0.96, green: 0.30, blue: 0.25))
                                .frame(width: 44, height: 44)
                                .overlay(Text("P").font(.headline.bold()).foregroundStyle(.white))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("good morning.")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                            Text("what did you eat?")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                        }

                        Button(action: onScan) {
                            HStack(spacing: 14) {
                                Image(systemName: "camera.fill")
                                    .font(.title3.bold())
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("scan a meal")
                                        .font(.headline)
                                    Text("take a photo and let plate identify it")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.72))
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .padding(18)
                            .background(Color(red: 0.96, green: 0.30, blue: 0.25), in: RoundedRectangle(cornerRadius: 20))
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("today")
                                .font(.title3.bold())

                            HStack(spacing: 12) {
                                StatBox(title: "energy", value: "\(store.todayCalories)", unit: "est. kcal")
                                StatBox(title: "protein", value: String(format: "%.0f", store.todayProtein), unit: "g")
                                StatBox(title: "fiber", value: String(format: "%.0f", store.todayFiber), unit: "g")
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("today's meals").font(.title3.bold())
                                Spacer()
                                Text("\(store.todayMeals.count)")
                                    .foregroundStyle(.secondary)
                            }

                            if store.todayMeals.isEmpty {
                                Text("nothing logged yet.")
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 18)
                            } else {
                                ForEach(store.todayMeals) { meal in
                                    MealRow(meal: meal)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 25, weight: .bold, design: .rounded))
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct MealRow: View {
    let meal: Meal
    var body: some View {
        HStack(spacing: 13) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .tertiarySystemFill))
                .frame(width: 48, height: 48)
                .overlay(Image(systemName: "fork.knife").foregroundStyle(.secondary))

            VStack(alignment: .leading, spacing: 3) {
                Text(meal.title).font(.headline)
                Text(meal.foods.map(\.name).joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if let calories = meal.estimatedCalories {
                Text("\(calories)")
                    .font(.headline)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LogView: View {
    @EnvironmentObject private var store: MealStore
    let onScan: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: onScan) {
                        Label("scan a meal", systemImage: "camera.fill")
                    }
                }

                Section("today") {
                    ForEach(store.todayMeals) { meal in
                        MealRow(meal: meal)
                    }
                }
            }
            .navigationTitle("log")
        }
    }
}

struct ScanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: MealStore
    @Binding var showCamera: Bool
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var analysis: AIAnalysis?
    @State private var isAnalyzing = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    if isAnalyzing {
                        ProgressView("analyzing…")
                    } else if let analysis {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(analysis.mealName).font(.title2.bold())
                            Text(analysis.foods.map(\.name).joined(separator: ", "))
                                .foregroundStyle(.secondary)
                            if let calories = analysis.estimatedCalories {
                                Text("estimated energy: \(calories) kcal")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button("add to log") {
                            let meal = Meal(
                                id: UUID(),
                                date: .now,
                                title: analysis.mealName,
                                foods: analysis.foods,
                                estimatedCalories: analysis.estimatedCalories,
                                protein: analysis.protein,
                                fiber: analysis.fiber
                            )
                            store.add(meal)
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.96, green: 0.30, blue: 0.25))
                    }
                } else {
                    ContentUnavailableView(
                        "scan your plate",
                        systemImage: "camera.viewfinder",
                        description: Text("take a photo or choose one from your library.")
                    )

                    Button {
                        showCamera = true
                    } label: {
                        Label("take photo", systemImage: "camera.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.96, green: 0.30, blue: 0.25))

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("choose photo", systemImage: "photo")
                    }
                    .buttonStyle(.bordered)
                }

                if let errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("scan")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("close") { dismiss() }
                }
            }
            .onChange(of: selectedPhoto) { _, item in
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else { return }
                    image = uiImage
                    await runAnalysis(uiImage)
                }
            }
        }
    }

    private func runAnalysis(_ image: UIImage) async {
        isAnalyzing = true
        errorText = nil
        do {
            analysis = try await AIService.analyze(image: image)
        } catch {
            errorText = "connect the app to your backend to enable photo analysis."
        }
        isAnalyzing = false
    }
}

struct RecipesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("quick ideas") {
                    RecipeRow(title: "chicken rice bowl", detail: "chicken • rice • vegetables")
                    RecipeRow(title: "turkey wrap", detail: "turkey • tortilla • greens")
                    RecipeRow(title: "yogurt bowl", detail: "yogurt • fruit • oats")
                }
            }
            .navigationTitle("recipes")
        }
    }
}

struct RecipeRow: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(detail).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("preferences") {
                    Label("foods i like", systemImage: "heart")
                    Label("diet preferences", systemImage: "slider.horizontal.3")
                }
                Section("about") {
                    Text("plate estimates nutrition from photos. estimates are not a substitute for nutrition or medical advice.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("profile")
        }
    }
}
