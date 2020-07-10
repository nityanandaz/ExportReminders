import EventKit

final class RemindersSource {
    private var calendars: [EKCalendar]
    private let store: EKEventStore
    
    init(store: EKEventStore = .init()) {
        self.store = store
        self.calendars = []
        
        let semaphore = DispatchSemaphore(value: 0)
        
        self.store.requestAccess(to: .reminder) { (accessPermitted, _) in
            if accessPermitted {
                self.calendars = store.calendars(for: .reminder)
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 3.0)
    }
    
    func getNames() -> [String] {
        calendars.map(\.title)
    }
    
    func getReminders(named name: String, includeCompleted: Bool) throws -> [[CustomStringConvertible]] {
        guard let calendar = calendars.first(where: { $0.title == name }) else {
            throw Exception.didNotFindList
        }
        
        let predicate = includeCompleted
            ? store.predicateForReminders(in: [calendar])
            : store.predicateForIncompleteReminders(withDueDateStarting: nil,
                                                    ending: nil,
                                                    calendars: [calendar])
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var fields: [[CustomStringConvertible]] = []
        store.fetchReminders(matching: predicate) { (reminders) in
            fields = reminders?.map({ (reminder) in
                return [
                    reminder.title!,
                    reminder.isCompleted,
                    reminder.completionDate ?? "nil"
                ]
            }) ?? []
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 3.0)
        return fields
    }
}
