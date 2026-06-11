import Foundation
import UserNotifications

@MainActor
final class BookingStore: ObservableObject {
    @Published var services: [Service] { didSet { save() } }
    @Published var clients: [Client] { didSet { save() } }
    @Published var staff: [StaffMember] { didSet { save() } }
    @Published var bookings: [Booking] { didSet { save() } }
    @Published var references: [ClientReference] { didSet { save() } }
    @Published var availability: [AvailabilityDay] { didSet { save() } }
    @Published var settings: StudioSettings { didSet { save() } }
    @Published var currentUser: StaffMember?
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding: Bool { didSet { save() } }
    @Published var lastCloudSync: Date?

    private let storageKey = "hairbooking.studio.premium.v2"

    init() {
        if let saved = Self.load(key: storageKey) {
            services = saved.services
            clients = saved.clients
            staff = saved.staff
            bookings = saved.bookings
            references = saved.references
            availability = saved.availability
            settings = saved.settings
            hasCompletedOnboarding = saved.hasCompletedOnboarding
        } else {
            services = Service.samples
            clients = Client.samples
            staff = StaffMember.samples
            references = [
                ClientReference(clientID: Client.samples[1].id, title: "Reference tattoo braccio", kind: .tattooArtist, note: "Linee sottili, nero", createdAt: Date()),
                ClientReference(clientID: Client.samples[2].id, title: "Balayage miele", kind: .hairdresser, note: "Tono caldo naturale", createdAt: Date())
            ]
            availability = AvailabilityDay.standardWeek
            settings = StudioSettings.sample
            hasCompletedOnboarding = false
            bookings = Self.sampleBookings(clients: Client.samples, services: Service.samples, staff: StaffMember.samples)
        }
    }

    var todayBookings: [Booking] { bookings(on: Date()) }

    var upcomingBookings: [Booking] {
        bookings
            .filter { $0.startDate >= Calendar.current.startOfDay(for: Date()) && $0.status != .cancelled }
            .sorted { $0.startDate < $1.startDate }
    }

    var monthlyRevenue: Double {
        bookings
            .filter { Calendar.current.isDate($0.startDate, equalTo: Date(), toGranularity: .month) && $0.status != .cancelled }
            .reduce(0) { $0 + $1.service.price }
    }

    var depositsTotal: Double {
        bookings.reduce(0) { $0 + $1.deposit }
    }

    var balanceDueTotal: Double {
        bookings.filter { $0.status != .cancelled }.reduce(0) { $0 + $1.balanceDue }
    }

    var averageTicket: Double {
        let active = bookings.filter { $0.status != .cancelled }
        guard !active.isEmpty else { return 0 }
        return active.reduce(0) { $0 + $1.service.price } / Double(active.count)
    }

    var completionRate: Double {
        let active = bookings.filter { $0.status != .cancelled }
        guard !active.isEmpty else { return 0 }
        return Double(active.filter { $0.status == .completed }.count) / Double(active.count)
    }

    var bestClients: [(Client, Double)] {
        Dictionary(grouping: bookings.filter { $0.status != .cancelled }, by: { $0.client.id })
            .compactMap { clientID, bookings in
                guard let client = clients.first(where: { $0.id == clientID }) ?? bookings.first?.client else { return nil }
                return (client, bookings.reduce(0) { $0 + $1.service.price })
            }
            .sorted { $0.1 > $1.1 }
    }

    var smartInsights: [SmartInsight] {
        var insights: [SmartInsight] = []
        if todayBookings.isEmpty {
            insights.append(SmartInsight(title: "Giornata libera", message: "Hai spazio per clienti last minute o consulenze.", icon: "bolt.badge.clock", priority: .opportunity))
        }
        if let next = upcomingBookings.first {
            insights.append(SmartInsight(title: "Prossimo appuntamento", message: "\(next.client.name) con \(next.professional.name), \(next.startDate.formatted(date: .omitted, time: .shortened)).", icon: "person.crop.circle.badge.clock", priority: .info))
        }
        if balanceDueTotal > 0 {
            insights.append(SmartInsight(title: "Saldo da incassare", message: "Ci sono \(Self.currency(balanceDueTotal)) ancora aperti.", icon: "creditcard.trianglebadge.exclamationmark", priority: .warning))
        }
        if let top = bestClients.first {
            insights.append(SmartInsight(title: "Cliente premium", message: "\(top.0.name) ha generato \(Self.currency(top.1)).", icon: "crown", priority: .opportunity))
        }
        if settings.syncEnabled {
            insights.append(SmartInsight(title: "Sync cloud attiva", message: lastCloudSync.map { "Ultimo sync \($0.formatted(date: .omitted, time: .shortened))." } ?? "Pronta per sincronizzare.", icon: "icloud", priority: .info))
        }
        return insights
    }

    var noShowRisks: [NoShowRisk] {
        upcomingBookings
            .map { riskProfile(for: $0) }
            .sorted { first, second in
                if first.score == second.score { return first.booking.startDate < second.booking.startDate }
                return first.score > second.score
            }
    }

    var demandSegments: [DemandSegment] {
        let activeBookings = bookings.filter { $0.status != .cancelled }
        let grouped = Dictionary(grouping: activeBookings) { booking in
            let hour = Calendar.current.component(.hour, from: booking.startDate)
            switch hour {
            case 6..<12: return "Mattina"
            case 12..<17: return "Pomeriggio"
            default: return "Sera"
            }
        }

        return ["Mattina", "Pomeriggio", "Sera"].map { label in
            let segmentBookings = grouped[label] ?? []
            return DemandSegment(
                label: label,
                bookingCount: segmentBookings.count,
                revenue: segmentBookings.reduce(0) { $0 + $1.service.price }
            )
        }
    }

    var servicePerformance: [ServicePerformance] {
        Dictionary(grouping: bookings.filter { $0.status != .cancelled }, by: { $0.service.id })
            .compactMap { serviceID, bookings in
                guard let service = services.first(where: { $0.id == serviceID }) ?? bookings.first?.service else { return nil }
                return ServicePerformance(
                    service: service,
                    bookingCount: bookings.count,
                    revenue: bookings.reduce(0) { $0 + $1.service.price }
                )
            }
            .sorted { first, second in
                if first.revenue == second.revenue { return first.bookingCount > second.bookingCount }
                return first.revenue > second.revenue
            }
    }

    var cancelledBookingsCount: Int {
        bookings.filter { $0.status == .cancelled }.count
    }

    var activeBookingsCount: Int {
        bookings.filter { $0.status != .cancelled }.count
    }

    var nextSevenDaysRevenue: Double {
        weeklyWorkload.reduce(0) { $0 + $1.expectedRevenue }
    }

    var weeklyWorkload: [WorkloadDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            let dayBookings = bookings(on: date).filter { $0.status != .cancelled }
            let capacityMinutes = workingCapacityMinutes(on: date)
            return WorkloadDay(
                date: date,
                bookingCount: dayBookings.count,
                bookedMinutes: dayBookings.reduce(0) { $0 + $1.service.durationMinutes },
                capacityMinutes: capacityMinutes,
                expectedRevenue: dayBookings.reduce(0) { $0 + $1.service.price }
            )
        }
    }

    func login(email: String, password: String) -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, password.count >= 4 else { return false }
        currentUser = staff.first { $0.role == .owner } ?? staff.first
        isAuthenticated = true
        return true
    }

    func logout() {
        isAuthenticated = false
        currentUser = nil
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func bookings(on date: Date) -> [Booking] {
        bookings
            .filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
            .sorted { $0.startDate < $1.startDate }
    }

    func weekDates(containing date: Date = Date()) -> [Date] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .weekOfYear, for: date)
        let start = interval?.start ?? calendar.startOfDay(for: date)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    func bookings(for professional: StaffMember, on date: Date) -> [Booking] {
        bookings(on: date).filter { $0.professional.id == professional.id }
    }

    func clientHistory(for client: Client) -> [Booking] {
        bookings.filter { $0.client.id == client.id }.sorted { $0.startDate > $1.startDate }
    }

    func references(for client: Client) -> [ClientReference] {
        references.filter { $0.clientID == client.id }.sorted { $0.createdAt > $1.createdAt }
    }

    func inactiveClients(limit: Int = 5) -> [Client] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date()
        return clients.filter { client in
            let latest = bookings.filter { $0.client.id == client.id && $0.status != .cancelled }.map(\.startDate).max()
            return latest.map { $0 < cutoff } ?? true
        }
        .prefix(limit)
        .map { $0 }
    }

    func availabilityRule(for date: Date) -> AvailabilityDay? {
        let weekday = Calendar.current.component(.weekday, from: date)
        return availability.first { $0.weekday == weekday }
    }

    func suggestedSlots(for service: Service? = nil, professional: StaffMember? = nil, on date: Date = Date(), limit: Int = 5) -> [SuggestedSlot] {
        let duration = service?.durationMinutes ?? 60
        let operators = staff.filter { member in
            member.isActive && (professional == nil || member.id == professional?.id) && (service == nil || member.specialties.contains(service!.professionalType))
        }
        guard let rule = availabilityRule(for: date), rule.isOpen else { return [] }

        let calendar = Calendar.current
        let dayStart = calendar.date(bySettingHour: rule.startHour, minute: 0, second: 0, of: date) ?? date
        let dayEnd = calendar.date(bySettingHour: rule.endHour, minute: 0, second: 0, of: date) ?? date
        let breakStart = calendar.date(bySettingHour: rule.breakStartHour, minute: 0, second: 0, of: date) ?? dayEnd
        let breakEnd = calendar.date(bySettingHour: rule.breakEndHour, minute: 0, second: 0, of: date) ?? dayEnd
        var slots: [SuggestedSlot] = []

        for member in operators {
            var cursor = max(roundToNextQuarter(Date()), dayStart)
            let busy = bookings(for: member, on: date).filter { $0.status != .cancelled }
            while cursor < dayEnd && slots.count < limit {
                let end = calendar.date(byAdding: .minute, value: duration, to: cursor) ?? cursor
                let overlapsBooking = busy.contains { cursor < $0.endDate && end > $0.startDate }
                let overlapsBreak = cursor < breakEnd && end > breakStart
                if end <= dayEnd && !overlapsBooking && !overlapsBreak {
                    slots.append(SuggestedSlot(startDate: cursor, durationMinutes: duration, professional: member))
                }
                cursor = calendar.date(byAdding: .minute, value: 30, to: cursor) ?? dayEnd
            }
        }

        return slots.sorted { $0.startDate < $1.startDate }.prefix(limit).map { $0 }
    }

    func addBooking(client: Client, service: Service, professional: StaffMember, startDate: Date, status: BookingStatus, notes: String, deposit: Double, paidAmount: Double, referenceTitle: String) -> Booking? {
        guard conflictingBooking(service: service, professional: professional, startDate: startDate) == nil else { return nil }
        let existingClient = clients.first { $0.id == client.id } ?? client
        if !clients.contains(where: { $0.id == existingClient.id }) { clients.append(existingClient) }
        let booking = Booking(client: existingClient, service: service, professional: professional, startDate: startDate, status: status, notes: notes, deposit: deposit, paidAmount: paidAmount, referenceTitle: referenceTitle)
        bookings.append(booking)
        scheduleReminder(for: booking)
        return booking
    }

    func updateBooking(_ booking: Booking, client: Client, service: Service, professional: StaffMember, startDate: Date, status: BookingStatus, notes: String, deposit: Double, paidAmount: Double, referenceTitle: String) -> Bool {
        guard conflictingBooking(service: service, professional: professional, startDate: startDate, excluding: booking.id) == nil else { return false }
        guard let index = bookings.firstIndex(where: { $0.id == booking.id }) else { return false }
        let updated = Booking(id: booking.id, client: client, service: service, professional: professional, startDate: startDate, status: status, notes: notes, deposit: deposit, paidAmount: paidAmount, referenceTitle: referenceTitle)
        bookings[index] = updated
        scheduleReminder(for: updated)
        return true
    }

    func updateClient(_ client: Client) {
        guard let index = clients.firstIndex(where: { $0.id == client.id }) else { return }
        clients[index] = client
        bookings = bookings.map { $0.client.id == client.id ? $0.replacing(client: client) : $0 }
    }

    func updateService(_ service: Service) {
        guard let index = services.firstIndex(where: { $0.id == service.id }) else { return }
        services[index] = service
        bookings = bookings.map { $0.service.id == service.id ? $0.replacing(service: service) : $0 }
    }

    func serviceHasBookings(_ service: Service) -> Bool {
        bookings.contains { $0.service.id == service.id }
    }

    func deleteService(_ service: Service) -> Bool {
        guard !serviceHasBookings(service) else { return false }
        services.removeAll { $0.id == service.id }
        return true
    }

    func updateStaff(_ member: StaffMember) {
        guard let index = staff.firstIndex(where: { $0.id == member.id }) else { return }
        staff[index] = member
        bookings = bookings.map { $0.professional.id == member.id ? $0.replacing(professional: member) : $0 }
    }

    func staffHasBookings(_ member: StaffMember) -> Bool {
        bookings.contains { $0.professional.id == member.id }
    }

    func deleteStaff(_ member: StaffMember) -> Bool {
        guard !staffHasBookings(member), staff.count > 1 else { return false }
        staff.removeAll { $0.id == member.id }
        return true
    }

    func addReference(client: Client, title: String, kind: ProfessionalType, note: String) {
        references.append(ClientReference(clientID: client.id, title: title, kind: kind, note: note, createdAt: Date()))
    }

    func conflictingBooking(service: Service, professional: StaffMember, startDate: Date, excluding excludedID: Booking.ID? = nil) -> Booking? {
        let endDate = Calendar.current.date(byAdding: .minute, value: service.durationMinutes, to: startDate) ?? startDate
        return bookings.first { booking in
            booking.id != excludedID &&
            booking.professional.id == professional.id &&
            booking.status != .cancelled &&
            startDate < booking.endDate &&
            endDate > booking.startDate
        }
    }

    func updateStatus(for booking: Booking, status: BookingStatus) {
        guard let index = bookings.firstIndex(where: { $0.id == booking.id }) else { return }
        bookings[index].status = status
    }

    func deleteBookings(ids: [Booking.ID]) {
        bookings.removeAll { ids.contains($0.id) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids.map(\.uuidString))
    }

    func backupText() -> String {
        let snapshot = Snapshot(services: services, clients: clients, staff: staff, bookings: bookings, references: references, availability: availability, settings: settings, hasCompletedOnboarding: hasCompletedOnboarding)
        guard let data = try? JSONEncoder.bookingEncoder.encode(snapshot) else { return "{}" }
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    func performCloudSync() {
        lastCloudSync = Date()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleReminder(for booking: Booking) {
        guard booking.status == .confirmed || booking.status == .waiting else { return }
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -2, to: booking.startDate) ?? booking.startDate
        guard reminderDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Appuntamento in arrivo"
        content.body = "\(booking.client.name) con \(booking.professional.name) - \(booking.service.name)"
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let request = UNNotificationRequest(identifier: booking.id.uuidString, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [booking.id.uuidString])
        UNUserNotificationCenter.current().add(request)
    }

    private func save() {
        let snapshot = Snapshot(services: services, clients: clients, staff: staff, bookings: bookings, references: references, availability: availability, settings: settings, hasCompletedOnboarding: hasCompletedOnboarding)
        guard let data = try? JSONEncoder.bookingEncoder.encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func load(key: String) -> Snapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder.bookingDecoder.decode(Snapshot.self, from: data)
    }

    private static func sampleBookings(clients: [Client], services: [Service], staff: [StaffMember]) -> [Booking] {
        let calendar = Calendar.current
        let today = Date()
        let morning = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
        let afternoon = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: today) ?? today
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: morning) ?? morning
        return [
            Booking(client: clients[0], service: services[0], professional: staff[0], startDate: morning, status: .confirmed, notes: "Richiesto shampoo delicato", deposit: 0, paidAmount: 0),
            Booking(client: clients[1], service: services[13], professional: staff[2], startDate: afternoon, status: .waiting, notes: "Porta reference sul telefono", deposit: 50, paidAmount: 0, referenceTitle: "Reference tattoo braccio"),
            Booking(client: clients[2], service: services[7], professional: staff[1], startDate: tomorrow, status: .confirmed, notes: "Balayage naturale", deposit: 40, paidAmount: 0, referenceTitle: "Balayage miele")
        ]
    }

    private func roundToNextQuarter(_ date: Date) -> Date {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)
        let remainder = minute % 15
        return calendar.date(byAdding: .minute, value: remainder == 0 ? 0 : 15 - remainder, to: date) ?? date
    }

    private static func currency(_ value: Double) -> String {
        value.formatted(.currency(code: "EUR"))
    }

    private func workingCapacityMinutes(on date: Date) -> Int {
        guard let rule = availabilityRule(for: date), rule.isOpen else { return 0 }
        let workingHours = max(rule.endHour - rule.startHour, 0)
        let breakHours = max(rule.breakEndHour - rule.breakStartHour, 0)
        let dailyMinutes = max(workingHours - breakHours, 0) * 60
        return dailyMinutes * staff.filter(\.isActive).count
    }

    private func riskProfile(for booking: Booking) -> NoShowRisk {
        var score = 10
        var reasons: [String] = []
        let history = clientHistory(for: booking.client)
        let cancelledCount = history.filter { $0.status == .cancelled }.count

        if booking.status == .waiting {
            score += 25
            reasons.append("prenotazione non confermata")
        }
        if booking.deposit == 0 && booking.service.price > 0 {
            score += 20
            reasons.append("nessun acconto registrato")
        }
        if cancelledCount > 0 {
            score += min(cancelledCount * 15, 30)
            reasons.append("storico con cancellazioni")
        }
        if booking.service.durationMinutes >= 120 {
            score += 15
            reasons.append("servizio lungo")
        }
        if Calendar.current.component(.hour, from: booking.startDate) >= 18 {
            score += 10
            reasons.append("fascia serale")
        }

        let boundedScore = min(score, 100)
        let level: RiskLevel
        switch boundedScore {
        case 0..<35: level = .low
        case 35..<65: level = .medium
        default: level = .high
        }

        return NoShowRisk(
            booking: booking,
            score: boundedScore,
            level: level,
            reasons: reasons.isEmpty ? ["profilo stabile"] : reasons
        )
    }
}

private struct Snapshot: Codable {
    var services: [Service]
    var clients: [Client]
    var staff: [StaffMember]
    var bookings: [Booking]
    var references: [ClientReference]
    var availability: [AvailabilityDay]
    var settings: StudioSettings
    var hasCompletedOnboarding: Bool
}

private extension JSONEncoder {
    static var bookingEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var bookingDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
