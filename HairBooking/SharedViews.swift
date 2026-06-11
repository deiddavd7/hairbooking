import SwiftUI

struct StudioHeader: View {
    var title: String
    var subtitle: String
    var icon: String
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon).font(.title2.weight(.semibold)).frame(width: 48, height: 48).background(StudioTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10)).foregroundStyle(StudioTheme.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.largeTitle.weight(.bold))
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

struct PremiumPanel<Content: View>: View {
    var title: String
    var icon: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon).font(.headline)
            content
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct FeatureRow: View {
    var icon: String
    var title: String
    var subtitle: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 34, height: 34).background(StudioTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8)).foregroundStyle(StudioTheme.accent)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct MetricTile: View {
    var title: String
    var value: String
    var caption: String
    var icon: String
    var color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.title3.weight(.bold)).minimumScaleFactor(0.7)
            Text(title).font(.caption.weight(.semibold))
            Text(caption).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct MetricStrip: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(color)
            Text(title).font(.headline)
            Spacer()
            Text(value).font(.headline.monospacedDigit())
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct BookingCard: View {
    var booking: Booking
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(booking.startDate.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                Spacer()
                StatusBadge(status: booking.status)
            }
            Text("\(booking.client.name) - \(booking.service.name)").font(.subheadline)
            Text("Operatore: \(booking.professional.name)").font(.caption).foregroundStyle(.secondary)
            HStack {
                Label(currency(booking.deposit), systemImage: "creditcard")
                Label("Saldo \(currency(booking.balanceDue))", systemImage: "eurosign.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if !booking.referenceTitle.isEmpty { Label(booking.referenceTitle, systemImage: "photo") .font(.caption) }
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct ClientRow: View {
    var client: Client
    var body: some View {
        HStack(spacing: 12) {
            InitialBadge(text: client.name, color: StudioTheme.accent)
            VStack(alignment: .leading) {
                Text(client.name).font(.headline)
                Text(client.phone).font(.subheadline).foregroundStyle(.secondary)
                Text(client.email).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct ServiceRow: View {
    var service: Service
    var body: some View {
        HStack {
            Image(systemName: service.professionalType == .hairdresser ? "scissors" : "paintbrush.pointed").foregroundStyle(StudioTheme.accent)
            VStack(alignment: .leading) {
                Text(service.name).font(.headline)
                Text("\(service.durationMinutes) min").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(currency(service.price)).font(.headline)
        }
    }
}

struct StaffRow: View {
    var member: StaffMember
    var body: some View {
        HStack {
            InitialBadge(text: member.name, color: color(named: member.colorName))
            VStack(alignment: .leading) {
                Text(member.name).font(.headline)
                Text(member.role.rawValue).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(member.isActive ? "Attivo" : "Pausa").font(.caption.weight(.semibold))
        }
    }
}

struct SmartInsightCard: View {
    var insight: SmartInsight
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.icon).frame(width: 40, height: 40).background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 8)).foregroundStyle(color)
            VStack(alignment: .leading) {
                Text(insight.title).font(.headline)
                Text(insight.message).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
    private var color: Color {
        switch insight.priority {
        case .info: StudioTheme.accent
        case .opportunity: .indigo
        case .warning: .orange
        }
    }
}

struct SuggestedSlotRow: View {
    var slot: SuggestedSlot
    var action: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(slot.startDate.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                Text("\(slot.professional.name) - \(slot.durationMinutes) min").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "plus.circle.fill").foregroundStyle(StudioTheme.accent)
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct ValueClientRow: View {
    var rank: Int
    var client: Client
    var value: Double
    var body: some View {
        HStack {
            Text("\(rank)").font(.headline.monospacedDigit()).frame(width: 34, height: 34).background(.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 8)).foregroundStyle(.indigo)
            Text(client.name).font(.headline)
            Spacer()
            Text(currency(value)).font(.headline)
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct NoShowRiskRow: View {
    var risk: NoShowRisk
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(risk.booking.client.name).font(.headline)
                    Text("\(risk.booking.service.name) - \(risk.booking.startDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(risk.score)%")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(color)
            }
            Text(risk.level.rawValue)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(color.opacity(0.14), in: Capsule())
                .foregroundStyle(color)
            Text(risk.reasons.joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }

    private var color: Color {
        switch risk.level {
        case .low: .green
        case .medium: .orange
        case .high: .red
        }
    }
}

struct DemandSegmentRow: View {
    var segment: DemandSegment
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 38, height: 38)
                .background(StudioTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(StudioTheme.accent)
            VStack(alignment: .leading) {
                Text(segment.label).font(.headline)
                Text("\(segment.bookingCount) prenotazioni").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(currency(segment.revenue)).font(.headline)
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }

    private var icon: String {
        switch segment.label {
        case "Mattina": "sunrise"
        case "Pomeriggio": "sun.max"
        default: "moon.stars"
        }
    }
}

struct ServicePerformanceRow: View {
    var performance: ServicePerformance
    var body: some View {
        HStack {
            Image(systemName: performance.service.professionalType == .hairdresser ? "scissors" : "paintbrush.pointed")
                .frame(width: 38, height: 38)
                .background(.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.indigo)
            VStack(alignment: .leading) {
                Text(performance.service.name).font(.headline)
                Text("\(performance.bookingCount) prenotazioni").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(currency(performance.revenue)).font(.headline)
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct WorkloadDayRow: View {
    var day: WorkloadDay
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(day.date.formatted(date: .abbreviated, time: .omitted)).font(.headline)
                    Text(capacityText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(currency(day.expectedRevenue)).font(.headline)
            }
            ProgressView(value: day.utilizationRate)
                .tint(utilizationColor)
            Text("Saturazione \(percent(day.utilizationRate))")
                .font(.caption.weight(.semibold))
                .foregroundStyle(utilizationColor)
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }

    private var capacityText: String {
        if day.capacityMinutes == 0 {
            return "\(day.bookingCount) appuntamenti - studio chiuso"
        }
        return "\(day.bookingCount) appuntamenti - \(day.bookedMinutes)/\(day.capacityMinutes) min"
    }

    private var utilizationColor: Color {
        switch day.utilizationRate {
        case 0..<0.45: return StudioTheme.accent
        case 0.45..<0.8: return .orange
        default: return .red
        }
    }
}

struct FollowUpClientRow: View {
    var client: Client
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                InitialBadge(text: client.name, color: .orange)
                VStack(alignment: .leading) {
                    Text(client.name).font(.headline)
                    Text(client.phone).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 12) {
                Link(destination: URL(string: "sms:\(client.phone)")!) {
                    Label("SMS", systemImage: "message")
                }
                Link(destination: URL(string: "https://wa.me/\(digits(client.phone))")!) {
                    Label("WhatsApp", systemImage: "phone")
                }
                Link(destination: URL(string: "mailto:\(client.email)")!) {
                    Label("Email", systemImage: "envelope")
                }
            }
            .font(.caption.weight(.semibold))
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct ReferenceCard: View {
    var reference: ClientReference
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle").frame(width: 42, height: 42).background(StudioTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8)).foregroundStyle(StudioTheme.accent)
            VStack(alignment: .leading) {
                Text(reference.title).font(.headline)
                Text(reference.note).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(StudioTheme.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct StatusBadge: View {
    var status: BookingStatus
    var body: some View {
        Text(status.rawValue).font(.caption2.weight(.bold)).padding(.horizontal, 8).padding(.vertical, 5).background(color.opacity(0.15), in: Capsule()).foregroundStyle(color)
    }
    private var color: Color {
        switch status {
        case .confirmed: StudioTheme.accent
        case .waiting: .orange
        case .completed: .green
        case .cancelled: .red
        }
    }
}

struct EmptyState: View {
    var title: String
    var subtitle: String
    var icon: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(StudioTheme.accent)
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct InitialBadge: View {
    var text: String
    var color: Color
    var body: some View {
        Text(String(text.prefix(1)).uppercased()).font(.headline).frame(width: 42, height: 42).background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8)).foregroundStyle(color)
    }
}

enum StudioTheme {
    static let accent = Color(red: 0.04, green: 0.43, blue: 0.39)
    static let background = Color(red: 0.95, green: 0.96, blue: 0.95)
    static let surface = Color(red: 0.99, green: 0.99, blue: 0.98)
}

func currency(_ value: Double) -> String {
    value.formatted(.currency(code: "EUR"))
}

func percent(_ value: Double) -> String {
    value.formatted(.percent.precision(.fractionLength(0)))
}

func digits(_ text: String) -> String {
    text.filter(\.isNumber)
}

func weekdayName(_ weekday: Int) -> String {
    Calendar.current.weekdaySymbols[max(0, min(weekday - 1, 6))]
}

func color(named name: String) -> Color {
    switch name {
    case "indigo": .indigo
    case "orange": .orange
    default: StudioTheme.accent
    }
}
