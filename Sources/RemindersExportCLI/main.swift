import EventKit
import ArgumentParser

final class ProgramState {
    enum State {
        case unauthorized
        case calendars([EKCalendar])
    }
    
    static let shared = ProgramState(store: EKEventStore())
    
    var state: State
    
    private let store: EKEventStore
    
    private init(store: EKEventStore) {
        self.store = store
        self.state = .unauthorized
        
        if EKEventStore.authorizationStatus(for: .reminder) == .authorized {
            self.fetchCalendars()
        } else {
            self.store.requestAccess(to: .reminder) { (bool, _) in
                if bool {
                    self.fetchCalendars()
                }
            }
        }
    }
    
    private func fetchCalendars() {
        let calendars = store.calendars(for: .reminder)
        self.state = .calendars(calendars)
    }
}

struct RemindersExport: ParsableCommand {
    
    enum Exception: Error {
        case couldNotReadReminders
        case didNotFindList
    }
    
    @Flag()
    var includeCompleted: Bool
    
    @Option(name: .shortAndLong, help: "The name of the list to export.")
    var listName: String?
    
    func run() throws {
        guard case let .calendars(calendars) = ProgramState.shared.state else {
            throw Exception.couldNotReadReminders
        }
        
        guard let name = listName else {
            // Write CSV Head
            print("list-names")
            
            calendars.forEach { (calendar) in
                print(calendar.title)
            }
            return
        }
        
        guard let calendar = calendars.first(where: { $0.title == name }) else {
            throw Exception.didNotFindList
        }
        
        let store = EKEventStore()
        let predicate = includeCompleted
            ? store.predicateForReminders(in: [calendar])
            : store.predicateForIncompleteReminders(withDueDateStarting: nil,
                                                    ending: nil,
                                                    calendars: [calendar])
        // Write CSV Head
        print("title;completed;date")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        store.fetchReminders(matching: predicate) { (reminders) in
            reminders?.forEach({ (reminder) in
                let fields: [CustomStringConvertible] = [
                    reminder.title!,
                    reminder.isCompleted,
                    reminder.completionDate ?? "nil"
                ]
                
                print(fields.map(\.description).joined(separator: ";"))
            })
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
}

RemindersExport.main()
