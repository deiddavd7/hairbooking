import XCTest
@testable import HairBooking

@MainActor
final class BookingStoreTests: XCTestCase {
    private func makeStore() -> BookingStore {
        let store = BookingStore()
        store.services = Service.samples
        store.clients = Client.samples
        store.staff = StaffMember.samples
        store.references = []
        store.availability = AvailabilityDay.standardWeek
        store.settings = StudioSettings.sample
        store.bookings = []
        return store
    }

    private func nextOpenDate(from date: Date = Date()) -> Date {
        let calendar = Calendar.current
        return (1...7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: date) }
            .first { candidate in
                let weekday = calendar.component(.weekday, from: candidate)
                return AvailabilityDay.standardWeek.first { $0.weekday == weekday }?.isOpen == true
            } ?? date
    }

    func testConflictingBookingDetectsOverlappingAppointmentForSameProfessional() {
        let store = makeStore()
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        let client = store.clients[0]
        let service = store.services[4]
        let professional = store.staff[0]

        XCTAssertNotNil(store.addBooking(client: client, service: service, professional: professional, startDate: start, status: .confirmed, notes: "", deposit: 0, paidAmount: 0, referenceTitle: ""))

        let overlappingStart = calendar.date(byAdding: .minute, value: 30, to: start)!
        XCTAssertNotNil(store.conflictingBooking(service: service, professional: professional, startDate: overlappingStart))
    }

    func testConflictingBookingAllowsSameTimeForDifferentProfessional() {
        let store = makeStore()
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        let client = store.clients[0]
        let service = store.services[0]

        XCTAssertNotNil(store.addBooking(client: client, service: service, professional: store.staff[0], startDate: start, status: .confirmed, notes: "", deposit: 0, paidAmount: 0, referenceTitle: ""))

        XCTAssertNil(store.conflictingBooking(service: service, professional: store.staff[1], startDate: start))
    }

    func testSuggestedSlotsRespectProfessionalSpecialty() {
        let store = makeStore()
        let tattooService = store.services.first { $0.professionalType == .tattooArtist }!
        let slots = store.suggestedSlots(for: tattooService, on: nextOpenDate(), limit: 10)

        XCTAssertFalse(slots.isEmpty)
        XCTAssertTrue(slots.allSatisfy { $0.professional.specialties.contains(.tattooArtist) })
    }

    func testServiceInUseCannotBeDeleted() {
        let store = makeStore()
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        let service = store.services[0]

        XCTAssertNotNil(store.addBooking(client: store.clients[0], service: service, professional: store.staff[0], startDate: start, status: .confirmed, notes: "", deposit: 0, paidAmount: 0, referenceTitle: ""))

        XCTAssertFalse(store.deleteService(service))
        XCTAssertTrue(store.services.contains { $0.id == service.id })
    }

    func testReportMetricsIgnoreCancelledBookings() {
        let store = makeStore()
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!
        let completedService = store.services[0]
        let cancelledService = store.services[1]

        _ = store.addBooking(client: store.clients[0], service: completedService, professional: store.staff[0], startDate: start, status: .completed, notes: "", deposit: 0, paidAmount: completedService.price, referenceTitle: "")
        _ = store.addBooking(client: store.clients[1], service: cancelledService, professional: store.staff[1], startDate: start, status: .cancelled, notes: "", deposit: 0, paidAmount: 0, referenceTitle: "")

        XCTAssertEqual(store.activeBookingsCount, 1)
        XCTAssertEqual(store.cancelledBookingsCount, 1)
        XCTAssertEqual(store.averageTicket, completedService.price, accuracy: 0.01)
        XCTAssertEqual(store.completionRate, 1, accuracy: 0.01)
    }

    func testNoShowRiskIncreasesForWaitingBookingWithoutDeposit() {
        let store = makeStore()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let start = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow)!
        let service = store.services.first { $0.durationMinutes >= 120 }!
        let professional = store.staff.first { $0.specialties.contains(service.professionalType) }!

        _ = store.addBooking(client: store.clients[0], service: service, professional: professional, startDate: start, status: .waiting, notes: "", deposit: 0, paidAmount: 0, referenceTitle: "")

        let risk = store.noShowRisks.first
        XCTAssertEqual(risk?.level, .high)
        XCTAssertTrue(risk?.reasons.contains("prenotazione non confermata") == true)
    }
}
