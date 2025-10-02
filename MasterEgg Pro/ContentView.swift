import SwiftUI
import UserNotifications
import CoreBluetooth  // For Bluetooth scales placeholder

// MARK: - Color Extensions
extension Color {
    static let eggYellow = Color(red: 1.0, green: 0.85, blue: 0.24)  // #FFD93D
    static let coralRed = Color(red: 1.0, green: 0.42, blue: 0.42)  // #FF6B6B
    static let grassGreen = Color(red: 0.24, green: 0.84, blue: 0.6)  // #3DD598
    static let skyBlue = Color(red: 0.29, green: 0.56, blue: 0.89)  // #4A90E2
    static let creamWhite = Color(red: 1.0, green: 0.98, blue: 0.9)  // #FFF9E6
}

// MARK: - Data Models
struct Breed: Identifiable, Codable {
    let id = UUID()
    let name: String
    let origin: String
    let description: String
    let productivity: String
    var imageName: String { return name.lowercased().replacingOccurrences(of: " ", with: "_") }  // Placeholder
}

struct IncubationBatch: Identifiable, Codable {
    let id = UUID()
    let name: String
    let startDate: Date
    var expectedHatchDate: Date {
        Calendar.current.date(byAdding: .day, value: 21, to: startDate) ?? startDate
    }
    var currentDay: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(0, min(days + 1, 21))
    }
    var isCompleted: Bool {
        return Date() > expectedHatchDate
    }
}

struct EggWeightRecord: Identifiable, Codable {
    let id = UUID()
    let weight: Double  // in grams
    let date: Date
    var category: String {
        switch weight {
        case 0..<50: return "S"
        case 50..<60: return "M"
        case 60..<70: return "L"
        default: return "XL"
        }
    }
}

// MARK: - Persistence Manager
class DataManager: ObservableObject {
    @Published var batches: [IncubationBatch] = []
    @Published var weights: [EggWeightRecord] = []
    @Published var unlockedBreeds: [Breed] = []
    
    let breeds: [Breed] = [
        Breed(name: "Ancona", origin: "Italy", description: "Known for its mottled black and white plumage, Ancona chickens are active and hardy. They are noted for being noisy.", productivity: "Egg-laying, good production."),
        Breed(name: "Andalusian", origin: "Spain", description: "Andalusian chickens have blue plumage and are known for their active nature. They are also noted for being noisy and good flyers.", productivity: "Egg-laying, prolific layers."),
        Breed(name: "Australorp", origin: "Australia", description: "Australorp chickens are large, black birds known for their calm temperament. They are a heavy, soft feather breed.", productivity: "Dual-purpose, good for both eggs and meat."),
        Breed(name: "Barnevelder", origin: "Netherlands", description: "Barnevelder chickens are known for their dark brown eggs and attractive plumage. They are a heavy, soft feather breed.", productivity: "Dual-purpose, good egg layers with decent meat production."),
        Breed(name: "Brahma", origin: "Asia", description: "Brahma chickens are large with feathered legs and a gentle disposition. They are a heavy, soft feather breed.", productivity: "Dual-purpose, suitable for meat and moderate egg production."),
        Breed(name: "Cochin", origin: "China", description: "Cochin chickens are fluffy, heavy birds with abundant feathering, including on their legs. They are a heavy, soft feather breed.", productivity: "Dual-purpose, good for meat with moderate egg laying."),
        Breed(name: "Dominique", origin: "USA", description: "Dominique chickens have a barred plumage pattern and are one of the oldest American breeds. They are a heavy, soft feather breed and rare.", productivity: "Dual-purpose, used for both eggs and meat."),
        Breed(name: "Dorking", origin: "UK", description: "Dorking chickens are known for their five-toed feet and are a traditional heavy breed. They are a heavy, soft feather breed.", productivity: "Dual-purpose, good for meat and egg production."),
        Breed(name: "Faverolles", origin: "France", description: "Faverolles chickens have feathered legs and a friendly disposition, often kept for exhibition. They are a heavy, soft feather breed.", productivity: "Dual-purpose, suitable for eggs and meat."),
        Breed(name: "Hamburgh", origin: "Germany", description: "Hamburgh chickens are small, active birds with ornate plumage, known for their egg-laying abilities. They are a light, soft feather breed.", productivity: "Egg-laying, prolific layers."),
        Breed(name: "ISA Brown", origin: "France", description: "Developed in 1978 by a French company for optimum egg production, ISA Brown is known for its gentle nature and resilience.", productivity: "High egg laying rate."),
        Breed(name: "Plymouth Rock", origin: "USA", description: "Introduced in the late 1900s and named after its town of origin, it is relaxed, responsive, and kid-friendly.", productivity: "Excellent egg laying rate."),
        Breed(name: "Naked Neck", origin: "Transylvania", description: "Known for its featherless neck, giving it a turkey-like appearance, this breed is distinctive and quirky.", productivity: "General purpose."),
        Breed(name: "Orpington", origin: "UK", description: "Created by British breeders at the turn of the 20th century, it is hardy, fluffy, and designed to endure cold winters.", productivity: "High egg laying rate, hardy in cold."),
        Breed(name: "Silkie", origin: "China", description: "Known for fluffy, puffy plumage and small stature (1.5-2 kg), Silkies stand out with a celebrity-like appearance.", productivity: "Ornamental, moderate eggs."),
        Breed(name: "New Hampshire Red", origin: "USA", description: "Developed in the early 1900s by New Hampshire farmers to improve on Rhode Island Reds, it is gentle and warm.", productivity: "Reliable egg production, fast-growing."),
        Breed(name: "Frizzle", origin: "Unknown", description: "Known for unique feathers that curl outwards, giving a glamorous, trend-setting look.", productivity: "Pet suitability, moderate eggs."),
        Breed(name: "Belgian d’Uccle", origin: "Belgium", description: "Originating from Uccle, Belgium, these vibrant chickens come in various shapes, colors, and sizes, known for being sweet and cuddly pets.", productivity: "Ornamental, low egg production.")
    ]
    
    let embryoStages: [String] = [
        "Day 1: The germinal disc is at the blastodermal stage.",
        "Day 2: Appearance of the first groove at the center of the blastoderm.",
        "Day 3: The embryo is lying on its left side. Onset of blood circulation.",
        "Day 4: Development of the amniotic cavity.",
        "Day 5: Sensible increase in the embryo’s size; the embryo takes a C shape.",
        "Day 6: The vitelline membrane continues to grow.",
        "Day 7: Thinning of the neck.",
        "Day 8: The vitelline membrane covers almost the whole yolk.",
        "Day 9: Appearance of claws.",
        "Day 10: The nostrils are present as narrow apertures.",
        "Day 11: The palpebral aperture has an elliptic shape.",
        "Day 12: Feather follicles surround the external auditory meatus.",
        "Day 13: The allantois shrinks.",
        "Day 14: Down covers almost the whole body.",
        "Day 15 & 16: Few morphological changes: chick and down continue to grow.",
        "Day 17: The embryo’s renal system produces urates.",
        "Day 18: Onset of vitellus internalization.",
        "Day 19: Acceleration of vitellus resorption.",
        "Day 20: Vitellus fully resorbed.",
        "Day 21: The chick uses its wing as a guide and its legs to turn around."
    ]
    
    init() {
        loadData()
        unlockDailyBreed()
    }
    
    func saveData() {
        if let encodedBatches = try? JSONEncoder().encode(batches) {
            UserDefaults.standard.set(encodedBatches, forKey: "batches")
        }
        if let encodedWeights = try? JSONEncoder().encode(weights) {
            UserDefaults.standard.set(encodedWeights, forKey: "weights")
        }
        if let encodedUnlocked = try? JSONEncoder().encode(unlockedBreeds) {
            UserDefaults.standard.set(encodedUnlocked, forKey: "unlockedBreeds")
        }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "batches"),
           let decoded = try? JSONDecoder().decode([IncubationBatch].self, from: data) {
            batches = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "weights"),
           let decoded = try? JSONDecoder().decode([EggWeightRecord].self, from: data) {
            weights = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "unlockedBreeds"),
           let decoded = try? JSONDecoder().decode([Breed].self, from: data) {
            unlockedBreeds = decoded
        }
    }
    
    func unlockDailyBreed() {
        let today = Calendar.current.component(.day, from: Date())
        let lastUnlockDay = UserDefaults.standard.integer(forKey: "lastUnlockDay")
        if today != lastUnlockDay && unlockedBreeds.count < breeds.count {
            let nextBreed = breeds[unlockedBreeds.count]
            unlockedBreeds.append(nextBreed)
            UserDefaults.standard.set(today, forKey: "lastUnlockDay")
            saveData()
            scheduleNotification(title: "New Breed of the Day Available!", body: "Check the encyclopedia.")
        }
    }
}

// MARK: - Notification Helper
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
}

func scheduleNotification(title: String, body: String, date: Date? = nil) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    var trigger: UNNotificationTrigger
    if let date = date {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    } else {
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    }
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}

// MARK: - Bluetooth Manager (Placeholder for smart scales)
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    @Published var isConnected = false
    @Published var weight: Double = 0.0
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

// MARK: - Custom Animations and Modifiers
struct EggCrackAnimation: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.15 : 1.0)
            .rotationEffect(.degrees(isAnimating ? 8 : -8))
            .animation(.spring(response: 0.4, dampingFraction: 0.3).repeatCount(3), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

struct FeatherFallAnimation: ViewModifier {
    @State private var offsetY: CGFloat = -150
    @State private var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5)) {
                    offsetY = 150
                    opacity = 0.0
                }
            }
    }
}

struct GrowShrinkAnimation: ViewModifier {
    let weight: Double
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                let baseScale: CGFloat = 1.0 + (CGFloat(weight) / 100.0) * 0.25
                withAnimation(.easeInOut(duration: 0.6)) {
                    scale = baseScale
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        scale = 1.0
                    }
                }
            }
    }
}

struct SparkleAnimation: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isAnimating {
                        Image(systemName: "sparkles")
                            .foregroundColor(.eggYellow)
                            .scaleEffect(1.8)
                            .opacity(0.7)
                            .offset(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatCount(4)) {
                    isAnimating = true
                }
            }
    }
}

struct BounceAnimation: ViewModifier {
    @State private var offsetY: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                    offsetY = -10
                }
            }
    }
}

// MARK: - Main App
@main
struct EggMasterProApp: App {
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.font, Font.custom("Poppins-Regular", size: 16))
        }
    }
}

// MARK: - ContentView (Tab Bar)
struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            IncubationView()
                .tabItem {
                    Label("Incubation", systemImage: "oval.fill")
                }
            
            WeightView()
                .tabItem {
                    Label("Egg Weights", systemImage: "scalemass.fill")
                }
            
            EncyclopediaView()
                .tabItem {
                    Label("Encyclopedia", systemImage: "book.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
        }
        .accentColor(.eggYellow)
        .font(.system(.body, design: .rounded))
    }
}

// MARK: - DashboardView
struct DashboardView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showFeathers = false
    @State private var showAddSheet = false
    
    var dailyBreed: Breed? {
        dataManager.unlockedBreeds.last
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 28) {
                        Text("Welcome to EggMaster Pro!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.coralRed)
                            .padding(.top, 40)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                        
                        // Mascot Greeting
                        Image(systemName: "bird.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.eggYellow)
                            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                            .modifier(BounceAnimation())
                        
                        // Current Incubations Card
                        if !dataManager.batches.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Current Incubations")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.skyBlue)
                                    ForEach(dataManager.batches.filter { !$0.isCompleted }) { batch in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(batch.name)
                                                    .font(.headline)
                                                Text("Day \(batch.currentDay)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            ProgressView(value: Double(batch.currentDay), total: 21)
                                                .progressViewStyle(CircularProgressViewStyle(tint: .grassGreen))
                                                .frame(width: 50, height: 50)
                                        }
                                        .padding()
                                        .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .white]), startPoint: .top, endPoint: .bottom))
                                        .cornerRadius(18)
                                        .shadow(radius: 6)
                                    }
                                }
                            }
                        }
                        
                        // Recent Weights Card
                        if !dataManager.weights.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Recent Egg Weights")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.skyBlue)
                                    ForEach(dataManager.weights.sorted(by: { $0.date > $1.date }).prefix(3)) { record in
                                        HStack {
                                            Text("\(record.weight, specifier: "%.1f") g")
                                                .foregroundColor(.eggYellow)
                                            Spacer()
                                            Text(record.category)
                                                .font(.headline)
                                                .foregroundColor(.grassGreen)
                                        }
                                        .padding()
                                        .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .white]), startPoint: .top, endPoint: .bottom))
                                        .cornerRadius(18)
                                        .shadow(radius: 6)
                                    }
                                }
                            }
                        }
                        
                        // Daily Encyclopedia Card
                        if let breed = dailyBreed {
                            CardView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Breed of the Day")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.skyBlue)
                                    BreedCard(breed: breed)
                                }
                            }
                        }
                        
                        Button(action: {
                            showFeathers = true
                            showAddSheet = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                showFeathers = false
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.grassGreen)
                                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 16)
                }
                .navigationTitle("Home")
                .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .skyBlue.opacity(0.2)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
                
                // Feather Fall Animation
                if showFeathers {
                    ForEach(0..<7) { _ in
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.coralRed)
                            .font(.system(size: 24))
                            .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: -50)
                            .modifier(FeatherFallAnimation())
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddRecordView(dataManager: dataManager) { showFeathers = true }
            }
        }
    }
}

// MARK: - AddRecordView
struct AddRecordView: View {
    @ObservedObject var dataManager: DataManager
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var newBatchName = ""
    @State private var newStartDate = Date()
    @State private var newWeight: Double = 0.0
    @State private var selectedOption = 0
    
    var body: some View {
        NavigationView {
            CardView {
                VStack(spacing: 20) {
                    Text("Add New Record")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.coralRed)
                    
                    Picker("Record Type", selection: $selectedOption) {
                        Text("New Batch").tag(0)
                        Text("Egg Weight").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .tint(.grassGreen)
                    
                    if selectedOption == 0 {
                        TextField("Batch Name", text: $newBatchName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .rounded))
                        DatePicker("Start Date", selection: $newStartDate, displayedComponents: .date)
                            .font(.system(.body, design: .rounded))
                    } else {
                        TextField("Weight in grams", value: $newWeight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.system(.body, design: .rounded))
                    }
                    
                    Button("Add") {
                        if selectedOption == 0 {
                            let batch = IncubationBatch(name: newBatchName.isEmpty ? "Batch \(dataManager.batches.count + 1)" : newBatchName, startDate: newStartDate)
                            dataManager.batches.append(batch)
                            scheduleReminders(for: batch)
                        } else {
                            let record = EggWeightRecord(weight: newWeight, date: Date())
                            dataManager.weights.append(record)
                        }
                        dataManager.saveData()
                        onAdd()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.grassGreen)
                    .font(.system(.headline, design: .rounded))
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .white]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
        }
    }
    
    func scheduleReminders(for batch: IncubationBatch) {
        for day in 1...18 {
            for time in [9, 15, 21] {
                if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: batch.startDate),
                   let reminderDate = Calendar.current.date(bySetting: .hour, value: time, of: date) {
                    scheduleNotification(title: "Time to Flip Eggs 🐣", body: "For batch \(batch.name)", date: reminderDate)
                }
            }
        }
        for day in [1, 7, 14] {
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: batch.startDate),
               let reminderDate = Calendar.current.date(bySetting: .hour, value: 12, of: date) {
                scheduleNotification(title: "Check Humidity", body: "For batch \(batch.name)", date: reminderDate)
            }
        }
        scheduleNotification(title: "Hatch Time!", body: "Batch \(batch.name) is ready to hatch.", date: batch.expectedHatchDate)
    }
}

// MARK: - CardView Wrapper for Consistent Styling
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding(20)
        .background(
            LinearGradient(gradient: Gradient(colors: [.white, .creamWhite]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
        .padding(.horizontal, 12)
    }
}

// MARK: - IncubationView
struct IncubationView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showingAddBatch = false
    @State private var newName = ""
    @State private var newStartDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.batches) { batch in
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(batch.name)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.coralRed)
                            Text("Day \(batch.currentDay) of 21")
                                .font(.system(.subheadline, design: .rounded))
                            ProgressView(value: Double(batch.currentDay), total: 21)
                                .progressViewStyle(LinearProgressViewStyle(tint: .skyBlue))
                                .frame(height: 12)
                                .cornerRadius(6)
                            Text(dataManager.embryoStages[safe: batch.currentDay - 1] ?? "")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.gray)
                                .italic()
                            if batch.currentDay == 21 {
                                Text("Egg is Cracking!")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.grassGreen)
                                    .modifier(EggCrackAnimation())
                            }
                        }
                    }
                }
                .onDelete { indices in
                    dataManager.batches.remove(atOffsets: indices)
                    dataManager.saveData()
                }
            }
            .navigationTitle("Incubation Planner")
            .toolbar {
                Button("Add") {
                    showingAddBatch = true
                }
            }
            .sheet(isPresented: $showingAddBatch) {
                CardView {
                    VStack(spacing: 20) {
                        Text("New Batch")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        TextField("Name", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .rounded))
                        DatePicker("Start Date", selection: $newStartDate, displayedComponents: .date)
                            .font(.system(.body, design: .rounded))
                        Button("Create") {
                            let batch = IncubationBatch(name: newName.isEmpty ? "Batch \(dataManager.batches.count + 1)" : newName, startDate: newStartDate)
                            dataManager.batches.append(batch)
                            dataManager.saveData()
                            scheduleReminders(for: batch)
                            showingAddBatch = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.grassGreen)
                        .font(.system(.headline, design: .rounded))
                    }
                }
                .padding()
            }
            .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .skyBlue.opacity(0.2)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
        }
    }
    
    func scheduleReminders(for batch: IncubationBatch) {
        for day in 1...18 {
            for time in [9, 15, 21] {
                if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: batch.startDate),
                   let reminderDate = Calendar.current.date(bySetting: .hour, value: time, of: date) {
                    scheduleNotification(title: "Time to Flip Eggs 🐣", body: "For batch \(batch.name)", date: reminderDate)
                }
            }
        }
        for day in [1, 7, 14] {
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: batch.startDate),
               let reminderDate = Calendar.current.date(bySetting: .hour, value: 12, of: date) {
                scheduleNotification(title: "Check Humidity", body: "For batch \(batch.name)", date: reminderDate)
            }
        }
        scheduleNotification(title: "Hatch Time!", body: "Batch \(batch.name) is ready to hatch.", date: batch.expectedHatchDate)
    }
}

// MARK: - Array Safe Index
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - WeightView
struct WeightView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var manualWeight: Double = 0.0
    @State private var showingAddManual = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 28) {
                if bluetoothManager.isConnected {
                    Text("Weight from Scale: \(bluetoothManager.weight, specifier: "%.1f") g")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.grassGreen)
                        .modifier(GrowShrinkAnimation(weight: bluetoothManager.weight))
                } else {
                    Text("Searching for Smart Scale...")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Button("Manual Input") {
                    showingAddManual = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.coralRed)
                .font(.system(.headline, design: .rounded))
                
                List(dataManager.weights) { record in
                    HStack {
                        Text("\(record.weight, specifier: "%.1f") g")
                            .foregroundColor(.eggYellow)
                            .font(.system(.headline, design: .rounded))
                        Spacer()
                        Text(record.category)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.grassGreen)
                        Spacer()
                        Text(record.date, style: .date)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .white]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(18)
                    .shadow(radius: 6)
                }
//                .onDelete { indices in
//                    dataManager.weights.remove(atOffsets: indices)
//                    dataManager.saveData()
//                }
            }
            .navigationTitle("Egg Weight Measurement")
            .sheet(isPresented: $showingAddManual) {
                CardView {
                    VStack(spacing: 20) {
                        Text("Enter Weight")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        TextField("Weight in grams", value: $manualWeight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.system(.body, design: .rounded))
                        Button("Add") {
                            let record = EggWeightRecord(weight: max(0, manualWeight), date: Date())
                            dataManager.weights.append(record)
                            dataManager.saveData()
                            showingAddManual = false
                            manualWeight = 0.0
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.grassGreen)
                        .font(.system(.headline, design: .rounded))
                    }
                }
                .padding()
            }
            .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .skyBlue.opacity(0.2)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
        }
    }
}

// MARK: - EncyclopediaView
struct EncyclopediaView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showSparkle = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 28) {
                    Text("Chicken Encyclopedia")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.skyBlue)
                        .padding(.top, 40)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    if let daily = dataManager.unlockedBreeds.last {
                        CardView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Breed of the Day")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.coralRed)
                                BreedCard(breed: daily)
                                    .modifier(SparkleAnimation())
                            }
                        }
                    }
                    
                    Text("Collection")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.coralRed)
                        .padding(.horizontal, 16)
                    
                    ForEach(dataManager.unlockedBreeds) { breed in
                        BreedCard(breed: breed)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Encyclopedia")
            .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .skyBlue.opacity(0.2)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
        }
    }
}

struct BreedCard: View {
    let breed: Breed
    @State private var isShared = false
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text(breed.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.eggYellow)
                Text("Origin: \(breed.origin)")
                    .font(.system(.subheadline, design: .rounded))
                Text(breed.description)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.gray)
                Text("Productivity: \(breed.productivity)")
                    .font(.system(.subheadline, design: .rounded))
                    .italic()
                Button("Share") {
                    isShared = true
                }
                .buttonStyle(.bordered)
                .tint(.grassGreen)
                .font(.system(.headline, design: .rounded))
            }
        }
        .alert("Shared!", isPresented: $isShared) {
            Button("OK") {}
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isShared)
    }
}

// MARK: - StatisticsView
struct StatisticsView: View {
    @StateObject private var dataManager = DataManager()
    
    var completedBatches: Int {
        dataManager.batches.filter { $0.isCompleted }.count
    }
    
    var eggCategories: [String: Int] {
        Dictionary(grouping: dataManager.weights, by: { $0.category }).mapValues { $0.count }
    }
    
    var collectionProgress: Double {
        Double(dataManager.unlockedBreeds.count) / Double(dataManager.breeds.count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    Text("Statistics")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.eggYellow)
                        .padding(.top, 40)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Completed Incubations: \(completedBatches)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.skyBlue)
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.grassGreen)
                                .padding(.top, 8)
                                .modifier(BounceAnimation())
                        }
                    }
                    
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Egg Size Distribution:")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.skyBlue)
                            ForEach(eggCategories.sorted(by: { $0.key < $1.key }), id: \.key) { category, count in
                                HStack {
                                    Text(category)
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                    Spacer()
                                    Rectangle()
                                        .fill(LinearGradient(gradient: Gradient(colors: [.coralRed, .eggYellow]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: CGFloat(count) * 30, height: 24)
                                        .cornerRadius(6)
                                    Text("\(count)")
                                        .font(.system(.caption, design: .rounded))
                                }
                            }
                        }
                    }
                    
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Collection Progress: \(dataManager.unlockedBreeds.count) / \(dataManager.breeds.count)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.skyBlue)
                            ProgressView(value: collectionProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .grassGreen))
                                .frame(height: 12)
                                .cornerRadius(6)
                        }
                    }
                    
                    if dataManager.unlockedBreeds.count >= 10 {
                        CardView {
                            Text("Badge: 10 Breeds Unlocked! 🎉")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.coralRed)
                                .modifier(SparkleAnimation())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .navigationTitle("Statistics")
            .background(LinearGradient(gradient: Gradient(colors: [.creamWhite, .skyBlue.opacity(0.2)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
        }
    }
}



#Preview {
    ContentView()
}
