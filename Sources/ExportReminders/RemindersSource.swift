import EventKit

final class RemindersSource {
    private var calendars: [EKCalendar]
    private let store: EKEventStore
    
    init(store: EKEventStore = .init()) throws {
        self.store = store
        self.calendars = []
        
        var failure: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        self.store.requestAccess(to: .reminder) { (accessPermitted, error) in
            if let error = error {
                failure = error
                return
            }
            
            if accessPermitted {
                self.calendars = store.calendars(for: .reminder)
            } else {
                failure = Exception.accessIsNotPermitted
            }
            
            semaphore.signal()
        }
        semaphore.wait()
        
        if let failure = failure {
            throw failure
        }
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
        semaphore.wait()
        
        return fields
    }
}
