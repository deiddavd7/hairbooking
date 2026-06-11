import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: BookingStore

    var body: some View {
        Group {
            if !store.isAuthenticated {
                LoginView()
            } else if !store.hasCompletedOnboarding {
                OnboardingView()
            } else {
                StudioShellView()
            }
        }
        .tint(StudioTheme.accent)
    }
}

private struct LoginView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var email = "studio@example.com"
    @State private var password = "demo"
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .frame(width: 64, height: 64)
                    .background(StudioTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(StudioTheme.accent)
                VStack(alignment: .leading, spacing: 8) {
                    Text("HairBooking Studio Pro")
                        .font(.largeTitle.weight(.bold))
                    Text("Gestionale premium per saloni, tattoo studio e team multi-operatore.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                PremiumPanel(title: "Accesso staff", icon: "person.badge.key") {
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
                    Button {
                        showError = !store.login(email: email, password: password)
                    } label: {
                        Label("Entra nello studio", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(StudioTheme.accent, in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.white)
                    }
                }
                Text("Demo locale: inserisci una email e almeno 4 caratteri di password.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(24)
            .background(StudioTheme.background.ignoresSafeArea())
            .alert("Credenziali incomplete", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

private struct OnboardingView: View {
    @EnvironmentObject private var store: BookingStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    StudioHeader(title: "Configura lo studio", subtitle: "Abbiamo preparato servizi, staff, orari, report e Smart desk.", icon: "wand.and.stars")
                    PremiumPanel(title: "Incluso nella versione premium", icon: "checkmark.seal") {
                        FeatureRow(icon: "person.3", title: "Multi-operatore", subtitle: "Ruoli staff e agenda per singolo professionista")
                        FeatureRow(icon: "calendar.badge.clock", title: "Calendario settimanale", subtitle: "Vista gestionale per giorno e operatore")
                        FeatureRow(icon: "creditcard", title: "Acconti e saldi", subtitle: "Traccia pagamenti, caparre e residui")
                        FeatureRow(icon: "photo.on.rectangle", title: "Reference cliente", subtitle: "Mood, tattoo, colore e note tecniche")
                        FeatureRow(icon: "icloud", title: "Cloud e backup", subtitle: "Sync simulata e backup JSON esportabile")
                    }
                    Button {
                        store.completeOnboarding()
                    } label: {
                        Text("Inizia")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(StudioTheme.accent, in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.white)
                    }
                }
                .padding(20)
            }
            .background(StudioTheme.background.ignoresSafeArea())
        }
    }
}

private struct StudioShellView: View {
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Agenda", systemImage: "calendar") }
            WeeklyCalendarView().tabItem { Label("Settimana", systemImage: "calendar.day.timeline.left") }
            NewBookingView().tabItem { Label("Prenota", systemImage: "plus.circle.fill") }
            ClientsView().tabItem { Label("Clienti", systemImage: "person.2") }
            SmartView().tabItem { Label("Smart", systemImage: "wand.and.stars") }
            ReportView().tabItem { Label("Report", systemImage: "chart.bar") }
            SettingsView().tabItem { Label("Studio", systemImage: "gearshape") }
        }
    }
}

private struct DashboardView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var selectedDate = Date()
    @State private var editingBooking: Booking?
    private var selectedBookings: [Booking] { store.bookings(on: selectedDate) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    StudioHeader(title: store.settings.studioName, subtitle: store.settings.tagline, icon: "sparkles")
                    HStack(spacing: 12) {
                        MetricTile(title: "Oggi", value: "\(store.todayBookings.count)", caption: "appuntamenti", icon: "calendar.badge.clock", color: StudioTheme.accent)
                        MetricTile(title: "Mese", value: currency(store.monthlyRevenue), caption: "incasso", icon: "eurosign.circle", color: .indigo)
                    }
                    HStack(spacing: 12) {
                        MetricTile(title: "Acconti", value: currency(store.depositsTotal), caption: "incassati", icon: "creditcard", color: .green)
                        MetricTile(title: "Da saldare", value: currency(store.balanceDueTotal), caption: "aperto", icon: "exclamationmark.circle", color: .orange)
                    }
                    if let insight = store.smartInsights.first { SmartInsightCard(insight: insight) }
                    PremiumPanel(title: "Calendario", icon: "calendar") {
                        DatePicker("Giorno", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                    }
                    PremiumPanel(title: selectedDate.formatted(date: .complete, time: .omitted), icon: "clock") {
                        if selectedBookings.isEmpty {
                            EmptyState(title: "Nessuna prenotazione", subtitle: "La giornata e libera.", icon: "calendar.badge.plus")
                        } else {
                            ForEach(selectedBookings) { booking in
                                Button { editingBooking = booking } label: { BookingCard(booking: booking) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(StudioTheme.background.ignoresSafeArea())
            .navigationTitle("Agenda")
            .sheet(item: $editingBooking) { EditBookingView(booking: $0) }
        }
    }
}

private struct WeeklyCalendarView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var selectedProfessionalID: StaffMember.ID?
    @State private var weekAnchor = Date()

    private var selectedProfessional: StaffMember {
        store.staff.first { $0.id == selectedProfessionalID } ?? store.staff[0]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    StudioHeader(title: "Settimana", subtitle: "Vista gestionale per operatore e disponibilita", icon: "calendar.day.timeline.left")
                    PremiumPanel(title: "Operatore", icon: "person.crop.circle") {
                        Picker("Operatore", selection: $selectedProfessionalID) {
                            ForEach(store.staff.filter(\.isActive)) { member in
                                Text("\(member.name) - \(member.role.rawValue)").tag(StaffMember.ID?.some(member.id))
                            }
                        }
                    }
                    ForEach(store.weekDates(containing: weekAnchor), id: \.self) { day in
                        PremiumPanel(title: day.formatted(date: .complete, time: .omitted), icon: availabilityIcon(for: day)) {
                            let bookings = store.bookings(for: selectedProfessional, on: day)
                            if let rule = store.availabilityRule(for: day), rule.isOpen {
                                Text("\(rule.startHour):00-\(rule.endHour):00  Pausa \(rule.breakStartHour):00-\(rule.breakEndHour):00")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Chiuso o ferie")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if bookings.isEmpty {
                                Text("Nessun appuntamento")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(bookings) { BookingCard(booking: $0) }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(StudioTheme.background.ignoresSafeArea())
            .navigationTitle("Settimana")
            .toolbar {
                Button { weekAnchor = Calendar.current.date(byAdding: .day, value: 7, to: weekAnchor) ?? weekAnchor } label: { Image(systemName: "chevron.right") }
                Button { weekAnchor = Calendar.current.date(byAdding: .day, value: -7, to: weekAnchor) ?? weekAnchor } label: { Image(systemName: "chevron.left") }
            }
            .onAppear { selectedProfessionalID = selectedProfessionalID ?? store.staff.first?.id }
        }
    }

    private func availabilityIcon(for day: Date) -> String {
        store.availabilityRule(for: day)?.isOpen == true ? "checkmark.circle" : "moon"
    }
}

private struct NewBookingView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var selectedClientID: Client.ID?
    @State private var selectedServiceID: Service.ID?
    @State private var selectedStaffID: StaffMember.ID?
    @State private var date = Date()
    @State private var status: BookingStatus = .confirmed
    @State private var notes = ""
    @State private var deposit = 0.0
    @State private var paidAmount = 0.0
    @State private var referenceTitle = ""
    @State private var conflict: Booking?

    private var selectedClient: Client? { store.clients.first { $0.id == selectedClientID } }
    private var selectedService: Service? { store.services.first { $0.id == selectedServiceID } }
    private var selectedStaff: StaffMember? { store.staff.first { $0.id == selectedStaffID } }

    var body: some View {
        NavigationStack {
            BookingForm(
                title: "Nuova prenotazione",
                selectedClientID: $selectedClientID,
                selectedServiceID: $selectedServiceID,
                selectedStaffID: $selectedStaffID,
                date: $date,
                status: $status,
                notes: $notes,
                deposit: $deposit,
                paidAmount: $paidAmount,
                referenceTitle: $referenceTitle,
                actionTitle: "Salva prenotazione"
            ) { save() }
            .alert("Orario occupato", isPresented: conflictAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let conflict { Text("Conflitto con \(conflict.client.name), \(conflict.startDate.formatted(date: .abbreviated, time: .shortened)).") }
            }
            .onAppear {
                selectedClientID = selectedClientID ?? store.clients.first?.id
                selectedServiceID = selectedServiceID ?? store.services.first?.id
                selectedStaffID = selectedStaffID ?? store.staff.first?.id
            }
        }
    }

    private func save() {
        guard let selectedClient, let selectedService, let selectedStaff else { return }
        if store.addBooking(client: selectedClient, service: selectedService, professional: selectedStaff, startDate: date, status: status, notes: notes, deposit: deposit, paidAmount: paidAmount, referenceTitle: referenceTitle) == nil {
            conflict = store.conflictingBooking(service: selectedService, professional: selectedStaff, startDate: date)
        } else {
            notes = ""
            deposit = 0
            paidAmount = 0
            referenceTitle = ""
        }
    }

    private var conflictAlert: Binding<Bool> { Binding(get: { conflict != nil }, set: { if !$0 { conflict = nil } }) }
}

private struct EditBookingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BookingStore
    let booking: Booking
    @State private var selectedClientID: Client.ID?
    @State private var selectedServiceID: Service.ID?
    @State private var selectedStaffID: StaffMember.ID?
    @State private var date: Date
    @State private var status: BookingStatus
    @State private var notes: String
    @State private var deposit: Double
    @State private var paidAmount: Double
    @State private var referenceTitle: String

    init(booking: Booking) {
        self.booking = booking
        _selectedClientID = State(initialValue: booking.client.id)
        _selectedServiceID = State(initialValue: booking.service.id)
        _selectedStaffID = State(initialValue: booking.professional.id)
        _date = State(initialValue: booking.startDate)
        _status = State(initialValue: booking.status)
        _notes = State(initialValue: booking.notes)
        _deposit = State(initialValue: booking.deposit)
        _paidAmount = State(initialValue: booking.paidAmount)
        _referenceTitle = State(initialValue: booking.referenceTitle)
    }

    var body: some View {
        NavigationStack {
            BookingForm(
                title: "Modifica prenotazione",
                selectedClientID: $selectedClientID,
                selectedServiceID: $selectedServiceID,
                selectedStaffID: $selectedStaffID,
                date: $date,
                status: $status,
                notes: $notes,
                deposit: $deposit,
                paidAmount: $paidAmount,
                referenceTitle: $referenceTitle,
                actionTitle: "Salva"
            ) { save() }
        }
    }

    private func save() {
        guard
            let client = store.clients.first(where: { $0.id == selectedClientID }),
            let service = store.services.first(where: { $0.id == selectedServiceID }),
            let member = store.staff.first(where: { $0.id == selectedStaffID })
        else { return }
        if store.updateBooking(booking, client: client, service: service, professional: member, startDate: date, status: status, notes: notes, deposit: deposit, paidAmount: paidAmount, referenceTitle: referenceTitle) {
            dismiss()
        }
    }
}

private struct BookingForm: View {
    @EnvironmentObject private var store: BookingStore
    var title: String
    @Binding var selectedClientID: Client.ID?
    @Binding var selectedServiceID: Service.ID?
    @Binding var selectedStaffID: StaffMember.ID?
    @Binding var date: Date
    @Binding var status: BookingStatus
    @Binding var notes: String
    @Binding var deposit: Double
    @Binding var paidAmount: Double
    @Binding var referenceTitle: String
    var actionTitle: String
    var action: () -> Void

    private var selectedService: Service? {
        store.services.first { $0.id == selectedServiceID }
    }

    private var eligibleStaff: [StaffMember] {
        guard let selectedService else { return store.staff.filter(\.isActive) }
        return store.staff.filter { $0.isActive && $0.specialties.contains(selectedService.professionalType) }
    }

    private var canSave: Bool {
        selectedClientID != nil &&
        selectedServiceID != nil &&
        selectedStaffID != nil &&
        deposit >= 0 &&
        paidAmount >= 0 &&
        paymentTotal <= (selectedService?.price ?? 0)
    }

    private var paymentTotal: Double {
        deposit + paidAmount
    }

    private var validationMessage: String? {
        if eligibleStaff.isEmpty { return "Nessun operatore attivo copre questo servizio." }
        if deposit < 0 || paidAmount < 0 { return "Gli importi non possono essere negativi." }
        if let selectedService, paymentTotal > selectedService.price {
            return "Acconto e saldo non possono superare il prezzo del servizio."
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                StudioHeader(title: title, subtitle: "Cliente, operatore, acconto, saldo e reference in un unico flusso", icon: "plus.circle")
                PremiumPanel(title: "Dettagli", icon: "person.text.rectangle") {
                    Picker("Cliente", selection: $selectedClientID) {
                        ForEach(store.clients) { Text($0.name).tag(Client.ID?.some($0.id)) }
                    }
                    Picker("Servizio", selection: $selectedServiceID) {
                        ForEach(store.services) { Text("\($0.name) - \($0.durationMinutes) min").tag(Service.ID?.some($0.id)) }
                    }
                    Picker("Operatore", selection: $selectedStaffID) {
                        ForEach(eligibleStaff) { Text($0.name).tag(StaffMember.ID?.some($0.id)) }
                    }
                    DatePicker("Data e ora", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Stato", selection: $status) {
                        ForEach(BookingStatus.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                PremiumPanel(title: "Pagamenti", icon: "creditcard") {
                    TextField("Acconto", value: $deposit, format: .currency(code: "EUR"))
                    TextField("Pagato extra/saldo", value: $paidAmount, format: .currency(code: "EUR"))
                    if let validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                PremiumPanel(title: "Reference e note", icon: "photo.on.rectangle") {
                    TextField("Reference foto/colore/tattoo", text: $referenceTitle)
                    TextField("Note interne", text: $notes, axis: .vertical).lineLimit(4, reservesSpace: true)
                }
                Button(action: action) {
                    Label(actionTitle, systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? StudioTheme.accent : .gray, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.white)
                }
                .disabled(!canSave)
            }
            .padding(20)
        }
        .background(StudioTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .onChange(of: selectedServiceID) { _, _ in
            guard !eligibleStaff.contains(where: { $0.id == selectedStaffID }) else { return }
            selectedStaffID = eligibleStaff.first?.id
        }
    }
}

private struct ClientsView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var editingClient: Client?
    @State private var selectedClient: Client?
    @State private var searchText = ""

    private var filteredClients: [Client] {
        searchText.isEmpty ? store.clients : store.clients.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredClients) { client in
                    Button { selectedClient = client } label: { ClientRow(client: client) }
                        .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(StudioTheme.background)
            .navigationTitle("Clienti")
            .searchable(text: $searchText, prompt: "Cerca cliente")
            .toolbar {
                Button { editingClient = Client(name: "", phone: "", email: "", notes: "") } label: { Image(systemName: "plus.circle.fill") }
            }
            .sheet(item: $editingClient) { client in
                AddClientView(client: client.name.isEmpty ? nil : client) { saved in
                    if store.clients.contains(where: { $0.id == saved.id }) { store.updateClient(saved) } else { store.clients.append(saved) }
                }
            }
            .sheet(item: $selectedClient) { ClientDetailView(client: $0) }
        }
    }
}

private struct ClientDetailView: View {
    @EnvironmentObject private var store: BookingStore
    let client: Client
    @State private var showingReference = false
    @State private var editingClient: Client?

    private var displayedClient: Client {
        store.clients.first { $0.id == client.id } ?? client
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    StudioHeader(title: displayedClient.name, subtitle: displayedClient.phone, icon: "person.crop.circle")
                    PremiumPanel(title: "Comunicazioni", icon: "message") {
                        Link("SMS", destination: URL(string: "sms:\(displayedClient.phone)")!)
                        Link("WhatsApp", destination: URL(string: "https://wa.me/\(digits(displayedClient.phone))")!)
                        Link("Email", destination: URL(string: "mailto:\(displayedClient.email)")!)
                    }
                    PremiumPanel(title: "Storico cliente", icon: "clock.arrow.circlepath") {
                        let history = store.clientHistory(for: displayedClient)
                        if history.isEmpty { Text("Nessuno storico").foregroundStyle(.secondary) }
                        ForEach(history) { BookingCard(booking: $0) }
                    }
                    PremiumPanel(title: "Foto e reference", icon: "photo.on.rectangle") {
                        Button { showingReference = true } label: { Label("Aggiungi reference", systemImage: "plus.circle.fill") }
                        ForEach(store.references(for: displayedClient)) { reference in
                            ReferenceCard(reference: reference)
                        }
                    }
                }
                .padding(20)
            }
            .background(StudioTheme.background.ignoresSafeArea())
            .navigationTitle("Scheda cliente")
            .toolbar {
                Button { editingClient = displayedClient } label: { Image(systemName: "pencil") }
            }
            .sheet(isPresented: $showingReference) { AddReferenceView(client: displayedClient) }
            .sheet(item: $editingClient) { client in
                AddClientView(client: client) { saved in
                    store.updateClient(saved)
                }
            }
        }
    }
}

private struct SmartView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var selectedServiceID: Service.ID?
    @State private var selectedStaffID: StaffMember.ID?
    @State private var selectedDate = Date()
    private var service: Service? { store.services.first { $0.id == selectedServiceID } ?? store.services.first }
    private var member: StaffMember? { store.staff.first { $0.id == selectedStaffID } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    StudioHeader(title: "Smart desk", subtitle: "Insight, slot, clienti premium e saldi aperti", icon: "wand.and.stars")
                    PremiumPanel(title: "Insight operativi", icon: "lightbulb") {
                        ForEach(store.smartInsights) { SmartInsightCard(insight: $0) }
                    }
                    PremiumPanel(title: "Slot consigliati", icon: "clock.badge.checkmark") {
                        Picker("Servizio", selection: $selectedServiceID) { ForEach(store.services) { Text($0.name).tag(Service.ID?.some($0.id)) } }
                        Picker("Operatore", selection: $selectedStaffID) {
                            Text("Qualsiasi").tag(StaffMember.ID?.none)
                            ForEach(store.staff) { Text($0.name).tag(StaffMember.ID?.some($0.id)) }
                        }
                        DatePicker("Giorno", selection: $selectedDate, displayedComponents: .date)
                        ForEach(store.suggestedSlots(for: service, professional: member, on: selectedDate)) { slot in
                            SuggestedSlotRow(slot: slot) { }
                        }
                    }
                    PremiumPanel(title: "Rischio no-show", icon: "exclamationmark.shield") {
                        ForEach(store.noShowRisks.prefix(5)) { risk in
                            NoShowRiskRow(risk: risk)
                        }
                    }
                    PremiumPanel(title: "Domanda per fascia", icon: "chart.bar.xaxis") {
                        ForEach(store.demandSegments) { segment in
                            DemandSegmentRow(segment: segment)
                        }
                    }
                    PremiumPanel(title: "Clienti da ricontattare", icon: "person.crop.circle.badge.exclamationmark") {
                        let inactive = store.inactiveClients(limit: 5)
                        if inactive.isEmpty {
                            EmptyState(title: "Tutti attivi", subtitle: "Nessun cliente da recuperare al momento.", icon: "checkmark.circle")
                        } else {
                            ForEach(inactive) { client in
                                FollowUpClientRow(client: client)
                            }
                        }
                    }
                    PremiumPanel(title: "Clienti premium", icon: "crown") {
                        ForEach(Array(store.bestClients.prefix(5).enumerated()), id: \.element.0.id) { item in
                            ValueClientRow(rank: item.offset + 1, client: item.element.0, value: item.element.1)
                        }
                    }
                }
                .padding(20)
            }
            .background(StudioTheme.background.ignoresSafeArea())
            .navigationTitle("Smart")
            .onAppear { selectedServiceID = selectedServiceID ?? store.services.first?.id }
        }
    }
}

private struct ReportView: View {
    @EnvironmentObject private var store: BookingStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    StudioHeader(title: "Report", subtitle: "Indicatori economici, performance servizi e qualita operativa", icon: "chart.bar")
                    HStack(spacing: 12) {
                        MetricTile(title: "Ticket medio", value: currency(store.averageTicket), caption: "per prenotazione", icon: "chart.line.uptrend.xyaxis", color: .indigo)
                        MetricTile(title: "Completamento", value: percent(store.completionRate), caption: "prenotazioni concluse", icon: "checkmark.seal", color: .green)
                    }
                    HStack(spacing: 12) {
                        MetricTile(title: "Attive", value: "\(store.activeBookingsCount)", caption: "non annullate", icon: "calendar", color: StudioTheme.accent)
                        MetricTile(title: "Annullate", value: "\(store.cancelledBookingsCount)", caption: "da monitorare", icon: "xmark.circle", color: .red)
                    }
                    PremiumPanel(title: "Previsione 7 giorni", icon: "calendar.badge.clock") {
                        MetricStrip(title: "Ricavi attesi", value: currency(store.nextSevenDaysRevenue), icon: "eurosign.circle", color: .green)
                        ForEach(store.weeklyWorkload) { day in
                            WorkloadDayRow(day: day)
                        }
                    }
                    PremiumPanel(title: "Performance servizi", icon: "scissors") {
                        if store.servicePerformance.isEmpty {
                            EmptyState(title: "Nessun dato", subtitle: "Le performance appariranno dopo le prime prenotazioni.", icon: "chart.bar.doc.horizontal")
                        } else {
                            ForEach(store.servicePerformance.prefix(6)) { performance in
                                ServicePerformanceRow(performance: performance)
                            }
                        }
                    }
                    PremiumPanel(title: "Domanda per fascia", icon: "chart.bar.xaxis") {
                        ForEach(store.demandSegments) { segment in
                            DemandSegmentRow(segment: segment)
                        }
                    }
                }
                .padding(20)
            }
            .background(StudioTheme.background.ignoresSafeArea())
            .navigationTitle("Report")
        }
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var backup = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    StudioHeader(title: "Studio", subtitle: "Branding, staff, ruoli, orari, cloud e backup", icon: "gearshape")
                    PremiumPanel(title: "Branding", icon: "paintpalette") {
                        TextField("Nome studio", text: $store.settings.studioName)
                        TextField("Tagline", text: $store.settings.tagline)
                        TextField("Telefono", text: $store.settings.phone)
                        TextField("Email", text: $store.settings.email)
                    }
                    PremiumPanel(title: "Staff e ruoli", icon: "person.3") {
                        ForEach(store.staff) { member in StaffRow(member: member) }
                        NavigationLink {
                            StaffManagementView()
                        } label: {
                            Label("Gestisci team", systemImage: "person.crop.circle.badge.gearshape")
                        }
                    }
                    PremiumPanel(title: "Catalogo servizi", icon: "scissors") {
                        NavigationLink {
                            ServicesView()
                        } label: {
                            Label("Gestisci servizi e prezzi", systemImage: "list.bullet.rectangle")
                        }
                    }
                    PremiumPanel(title: "Orari, pause, ferie", icon: "calendar.badge.clock") {
                        ForEach($store.availability) { $rule in
                            Toggle(weekdayName(rule.weekday), isOn: $rule.isOpen)
                            Stepper("Apertura \(rule.startHour):00", value: $rule.startHour, in: 6...14)
                            Stepper("Chiusura \(rule.endHour):00", value: $rule.endHour, in: 13...23)
                        }
                    }
                    PremiumPanel(title: "Cloud e backup", icon: "icloud") {
                        Toggle("Sincronizzazione cloud", isOn: $store.settings.syncEnabled)
                        Toggle("Backup automatico", isOn: $store.settings.automaticBackupEnabled)
                        Button("Simula sync cloud") { store.performCloudSync() }
                        Button("Genera backup JSON") { backup = store.backupText() }
                        if !backup.isEmpty {
                            TextEditor(text: $backup).frame(minHeight: 180)
                        }
                    }
                    Button("Logout") { store.logout() }
                        .foregroundStyle(.red)
                }
                .padding(20)
            }
            .background(StudioTheme.background.ignoresSafeArea())
            .navigationTitle("Studio")
        }
    }
}

private struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var notes = ""
    private var client: Client?
    var onSave: (Client) -> Void

    init(client: Client? = nil, onSave: @escaping (Client) -> Void) {
        self.client = client
        self.onSave = onSave
        _name = State(initialValue: client?.name ?? "")
        _phone = State(initialValue: client?.phone ?? "")
        _email = State(initialValue: client?.email ?? "")
        _notes = State(initialValue: client?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome", text: $name)
                TextField("Telefono", text: $phone)
                TextField("Email", text: $email)
                TextField("Note", text: $notes, axis: .vertical)
            }
            .navigationTitle(client == nil ? "Nuovo cliente" : "Modifica cliente")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annulla") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave(Client(id: client?.id ?? UUID(), name: name, phone: phone, email: email, notes: notes))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

private struct AddReferenceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BookingStore
    let client: Client
    @State private var title = ""
    @State private var kind: ProfessionalType = .hairdresser
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Reference foto") {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                    TextField("Titolo reference", text: $title)
                    Picker("Tipo", selection: $kind) { ForEach(ProfessionalType.allCases) { Text($0.rawValue).tag($0) } }
                    TextField("Note tecniche", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("Nuova reference")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annulla") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        store.addReference(client: client, title: title, kind: kind, note: note)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

private struct ServicesView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var editingService: Service?
    @State private var showingNewService = false
    @State private var showDeleteError = false

    var body: some View {
        List {
            ForEach(ProfessionalType.allCases) { type in
                Section(type.rawValue) {
                    ForEach(store.services.filter { $0.professionalType == type }) { service in
                        Button { editingService = service } label: {
                            ServiceRow(service: service)
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                showDeleteError = !store.deleteService(service)
                            } label: {
                                Label("Elimina", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Servizi")
        .toolbar {
            Button { showingNewService = true } label: { Image(systemName: "plus.circle.fill") }
        }
        .sheet(item: $editingService) { service in
            ServiceEditorView(service: service) { saved in
                store.updateService(saved)
            }
        }
        .sheet(isPresented: $showingNewService) {
            ServiceEditorView { service in
                store.services.append(service)
            }
        }
        .alert("Servizio in uso", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Non puoi eliminare un servizio gia presente nello storico prenotazioni.")
        }
    }
}

private struct ServiceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var durationMinutes: Int
    @State private var price: Double
    @State private var professionalType: ProfessionalType
    private var service: Service?
    var onSave: (Service) -> Void

    init(service: Service? = nil, onSave: @escaping (Service) -> Void) {
        self.service = service
        self.onSave = onSave
        _name = State(initialValue: service?.name ?? "")
        _durationMinutes = State(initialValue: service?.durationMinutes ?? 30)
        _price = State(initialValue: service?.price ?? 0)
        _professionalType = State(initialValue: service?.professionalType ?? .hairdresser)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome servizio", text: $name)
                Stepper("Durata \(durationMinutes) min", value: $durationMinutes, in: 15...300, step: 15)
                TextField("Prezzo", value: $price, format: .currency(code: "EUR"))
                Picker("Categoria", selection: $professionalType) {
                    ForEach(ProfessionalType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            .navigationTitle(service == nil ? "Nuovo servizio" : "Modifica servizio")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annulla") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave(Service(id: service?.id ?? UUID(), name: name, durationMinutes: durationMinutes, price: price, professionalType: professionalType))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

private struct StaffManagementView: View {
    @EnvironmentObject private var store: BookingStore
    @State private var editingMember: StaffMember?
    @State private var showingNewMember = false
    @State private var showDeleteError = false

    var body: some View {
        List {
            Section("Team") {
                ForEach(store.staff) { member in
                    Button { editingMember = member } label: {
                        StaffRow(member: member)
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            showDeleteError = !store.deleteStaff(member)
                        } label: {
                            Label("Elimina", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Team")
        .toolbar {
            Button { showingNewMember = true } label: { Image(systemName: "plus.circle.fill") }
        }
        .sheet(item: $editingMember) { member in
            StaffEditorView(member: member) { saved in
                store.updateStaff(saved)
            }
        }
        .sheet(isPresented: $showingNewMember) {
            StaffEditorView { member in
                store.staff.append(member)
            }
        }
        .alert("Operatore non eliminabile", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Non puoi eliminare l'unico operatore o un operatore gia presente nello storico prenotazioni.")
        }
    }
}

private struct StaffEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var role: StaffRole
    @State private var specialties: Set<ProfessionalType>
    @State private var colorName: String
    @State private var isActive: Bool
    private var member: StaffMember?
    var onSave: (StaffMember) -> Void

    init(member: StaffMember? = nil, onSave: @escaping (StaffMember) -> Void) {
        self.member = member
        self.onSave = onSave
        _name = State(initialValue: member?.name ?? "")
        _role = State(initialValue: member?.role ?? .operatorRole)
        _specialties = State(initialValue: Set(member?.specialties ?? [.hairdresser]))
        _colorName = State(initialValue: member?.colorName ?? "teal")
        _isActive = State(initialValue: member?.isActive ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome", text: $name)
                Picker("Ruolo", selection: $role) {
                    ForEach(StaffRole.allCases) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                Section("Specialita") {
                    ForEach(ProfessionalType.allCases) { type in
                        Toggle(type.rawValue, isOn: specialtyBinding(for: type))
                    }
                }
                Picker("Colore", selection: $colorName) {
                    Text("Teal").tag("teal")
                    Text("Indigo").tag("indigo")
                    Text("Orange").tag("orange")
                }
                Toggle("Attivo", isOn: $isActive)
            }
            .navigationTitle(member == nil ? "Nuovo operatore" : "Modifica operatore")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annulla") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave(StaffMember(id: member?.id ?? UUID(), name: name, role: role, specialties: Array(specialties), colorName: colorName, isActive: isActive))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || specialties.isEmpty)
                }
            }
        }
    }

    private func specialtyBinding(for type: ProfessionalType) -> Binding<Bool> {
        Binding(
            get: { specialties.contains(type) },
            set: { enabled in
                if enabled {
                    specialties.insert(type)
                } else {
                    specialties.remove(type)
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BookingStore())
    }
}
