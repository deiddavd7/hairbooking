import Foundation

enum ProfessionalType: String, CaseIterable, Identifiable, Codable {
    case hairdresser = "Parrucchiere"
    case tattooArtist = "Tatuatore"

    var id: String { rawValue }
}

enum BookingStatus: String, CaseIterable, Identifiable, Codable {
    case confirmed = "Confermata"
    case waiting = "In attesa"
    case completed = "Completata"
    case cancelled = "Annullata"

    var id: String { rawValue }
}

enum StaffRole: String, CaseIterable, Identifiable, Codable {
    case owner = "Titolare"
    case manager = "Manager"
    case operatorRole = "Operatore"
    case assistant = "Assistente"

    var id: String { rawValue }
}

enum InsightPriority: String, Codable {
    case info
    case opportunity
    case warning
}

enum RiskLevel: String, Codable {
    case low = "Basso"
    case medium = "Medio"
    case high = "Alto"
}

struct Service: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var durationMinutes: Int
    var price: Double
    var professionalType: ProfessionalType
}

struct Client: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var phone: String
    var email: String
    var notes: String
}

struct StaffMember: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var role: StaffRole
    var specialties: [ProfessionalType]
    var colorName: String
    var isActive: Bool
}

struct AvailabilityDay: Identifiable, Codable, Hashable {
    var id = UUID()
    var weekday: Int
    var isOpen: Bool
    var startHour: Int
    var endHour: Int
    var breakStartHour: Int
    var breakEndHour: Int
}

struct ClientReference: Identifiable, Codable, Hashable {
    var id = UUID()
    var clientID: Client.ID
    var title: String
    var kind: ProfessionalType
    var note: String
    var createdAt: Date
}

struct StudioSettings: Codable, Hashable {
    var studioName: String
    var tagline: String
    var phone: String
    var email: String
    var syncEnabled: Bool
    var automaticBackupEnabled: Bool
}

struct Booking: Identifiable, Codable, Hashable {
    var id = UUID()
    var client: Client
    var service: Service
    var professional: StaffMember
    var startDate: Date
    var status: BookingStatus
    var notes: String
    var deposit: Double
    var paidAmount: Double
    var referenceTitle: String

    var endDate: Date {
        Calendar.current.date(byAdding: .minute, value: service.durationMinutes, to: startDate) ?? startDate
    }

    var balanceDue: Double {
        max(service.price - deposit - paidAmount, 0)
    }

    init(
        id: UUID = UUID(),
        client: Client,
        service: Service,
        professional: StaffMember = StaffMember.samples[0],
        startDate: Date,
        status: BookingStatus,
        notes: String,
        deposit: Double = 0,
        paidAmount: Double = 0,
        referenceTitle: String = ""
    ) {
        self.id = id
        self.client = client
        self.service = service
        self.professional = professional
        self.startDate = startDate
        self.status = status
        self.notes = notes
        self.deposit = deposit
        self.paidAmount = paidAmount
        self.referenceTitle = referenceTitle
    }

    func replacing(client: Client) -> Booking {
        Booking(id: id, client: client, service: service, professional: professional, startDate: startDate, status: status, notes: notes, deposit: deposit, paidAmount: paidAmount, referenceTitle: referenceTitle)
    }

    func replacing(service: Service) -> Booking {
        Booking(id: id, client: client, service: service, professional: professional, startDate: startDate, status: status, notes: notes, deposit: deposit, paidAmount: paidAmount, referenceTitle: referenceTitle)
    }

    func replacing(professional: StaffMember) -> Booking {
        Booking(id: id, client: client, service: service, professional: professional, startDate: startDate, status: status, notes: notes, deposit: deposit, paidAmount: paidAmount, referenceTitle: referenceTitle)
    }
}

struct SmartInsight: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var message: String
    var icon: String
    var priority: InsightPriority
}

struct SuggestedSlot: Identifiable, Hashable {
    var id = UUID()
    var startDate: Date
    var durationMinutes: Int
    var professional: StaffMember
}

struct NoShowRisk: Identifiable, Hashable {
    var id: Booking.ID { booking.id }
    var booking: Booking
    var score: Int
    var level: RiskLevel
    var reasons: [String]
}

struct DemandSegment: Identifiable, Hashable {
    var id: String { label }
    var label: String
    var bookingCount: Int
    var revenue: Double
}

struct ServicePerformance: Identifiable, Hashable {
    var id: Service.ID { service.id }
    var service: Service
    var bookingCount: Int
    var revenue: Double
}

struct WorkloadDay: Identifiable, Hashable {
    var id: Date { date }
    var date: Date
    var bookingCount: Int
    var bookedMinutes: Int
    var capacityMinutes: Int
    var expectedRevenue: Double

    var utilizationRate: Double {
        guard capacityMinutes > 0 else { return 0 }
        return min(Double(bookedMinutes) / Double(capacityMinutes), 1)
    }
}

extension Service {
    static let samples: [Service] = [
        Service(name: "Taglio uomo", durationMinutes: 30, price: 25, professionalType: .hairdresser),
        Service(name: "Taglio donna", durationMinutes: 45, price: 38, professionalType: .hairdresser),
        Service(name: "Taglio bambino", durationMinutes: 25, price: 18, professionalType: .hairdresser),
        Service(name: "Piega", durationMinutes: 35, price: 28, professionalType: .hairdresser),
        Service(name: "Taglio e piega", durationMinutes: 60, price: 55, professionalType: .hairdresser),
        Service(name: "Colore ricrescita", durationMinutes: 75, price: 58, professionalType: .hairdresser),
        Service(name: "Colore completo e piega", durationMinutes: 105, price: 88, professionalType: .hairdresser),
        Service(name: "Balayage", durationMinutes: 150, price: 140, professionalType: .hairdresser),
        Service(name: "Meches", durationMinutes: 135, price: 120, professionalType: .hairdresser),
        Service(name: "Tonalizzante", durationMinutes: 45, price: 35, professionalType: .hairdresser),
        Service(name: "Trattamento ristrutturante", durationMinutes: 40, price: 42, professionalType: .hairdresser),
        Service(name: "Barba", durationMinutes: 25, price: 18, professionalType: .hairdresser),
        Service(name: "Taglio uomo e barba", durationMinutes: 50, price: 40, professionalType: .hairdresser),
        Service(name: "Consulenza tattoo", durationMinutes: 30, price: 0, professionalType: .tattooArtist),
        Service(name: "Flash tattoo", durationMinutes: 60, price: 90, professionalType: .tattooArtist),
        Service(name: "Sessione tattoo", durationMinutes: 180, price: 220, professionalType: .tattooArtist),
        Service(name: "Ritocco tattoo", durationMinutes: 60, price: 70, professionalType: .tattooArtist)
    ]
}

extension Client {
    static let samples: [Client] = [
        Client(name: "Giulia Rossi", phone: "+39 333 123 4567", email: "giulia@example.com", notes: "Preferisce appuntamenti al mattino"),
        Client(name: "Marco Bianchi", phone: "+39 347 987 6543", email: "marco@example.com", notes: "Allergia al lattice"),
        Client(name: "Sara Conti", phone: "+39 340 222 7788", email: "sara@example.com", notes: "Interessata a balayage naturale")
    ]
}

extension StaffMember {
    static let samples: [StaffMember] = [
        StaffMember(name: "Vincenzo", role: .owner, specialties: [.hairdresser], colorName: "teal", isActive: true),
        StaffMember(name: "Alessia", role: .manager, specialties: [.hairdresser], colorName: "indigo", isActive: true),
        StaffMember(name: "Nico", role: .operatorRole, specialties: [.tattooArtist], colorName: "orange", isActive: true)
    ]
}

extension AvailabilityDay {
    static let standardWeek: [AvailabilityDay] = [
        AvailabilityDay(weekday: 2, isOpen: true, startHour: 9, endHour: 19, breakStartHour: 13, breakEndHour: 14),
        AvailabilityDay(weekday: 3, isOpen: true, startHour: 9, endHour: 19, breakStartHour: 13, breakEndHour: 14),
        AvailabilityDay(weekday: 4, isOpen: true, startHour: 9, endHour: 19, breakStartHour: 13, breakEndHour: 14),
        AvailabilityDay(weekday: 5, isOpen: true, startHour: 9, endHour: 19, breakStartHour: 13, breakEndHour: 14),
        AvailabilityDay(weekday: 6, isOpen: true, startHour: 9, endHour: 18, breakStartHour: 13, breakEndHour: 14),
        AvailabilityDay(weekday: 7, isOpen: true, startHour: 9, endHour: 14, breakStartHour: 13, breakEndHour: 13),
        AvailabilityDay(weekday: 1, isOpen: false, startHour: 9, endHour: 13, breakStartHour: 13, breakEndHour: 13)
    ]
}

extension StudioSettings {
    static let sample = StudioSettings(
        studioName: "HairBooking Studio",
        tagline: "Beauty, tattoo e appuntamenti gestiti bene",
        phone: "+39 070 000 000",
        email: "studio@example.com",
        syncEnabled: false,
        automaticBackupEnabled: true
    )
}
