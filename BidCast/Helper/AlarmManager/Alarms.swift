


import Foundation

class Alarms: Codable {
    private var alarms: [Alarm]
    
    enum CodingKeys: CodingKey {
        case alarms
    }
    
    init() {
        self.alarms = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.alarms = try container.decode([Alarm].self, forKey: .alarms)
    }
    
    // Example method to process and save alarms
    func processAndSaveAlarms() {
        // Iterate through the alarms and apply any necessary processing
        for alarm in alarms {
            // Placeholder for processing logic
            print("Processing alarm with UUID: \(alarm.uuid)")
        }

        // Save the current state of alarms
        Store.shared.save(self, notifying: nil, userInfo: [
            Alarm.changeReasonKey: "processed",
            Alarm.newValueKey: alarms.count
        ])
    }

    func getAlarm(ByUUIDStr uuidString: String) -> Alarm? {
        return alarms.first { $0.uuid.uuidString == uuidString }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarms, forKey: .alarms)
    }

//    func add(_ alarm: Alarm) {
//        alarms.append(alarm)
//        let newIndex = alarms.count - 1
//        Store.shared.save(self, notifying: alarm, userInfo: [
//            Alarm.changeReasonKey: Alarm.added,
//            Alarm.newValueKey: newIndex
//        ])
//    }
    func add(_ alarm: Alarm) {
        // Check for duplicates based on alarmId or UUID
        if !alarms.contains(where: { $0.alarmId == alarm.alarmId || $0.uuid == alarm.uuid }) {
            alarms.append(alarm)
            let newIndex = alarms.count - 1
            Store.shared.save(self, notifying: alarm, userInfo: [
                Alarm.changeReasonKey: Alarm.added,
                Alarm.newValueKey: newIndex
            ])
        } else {
            removeAllAlarms()
            sleep(1)
            alarms.append(alarm)
            let newIndex = alarms.count - 1
            Store.shared.save(self, notifying: alarm, userInfo: [
                Alarm.changeReasonKey: Alarm.added,
                Alarm.newValueKey: newIndex
            ])
            print("Alarm with id \(alarm.alarmId) already exists.")
        }
    }

    func remove(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.uuid == alarm.uuid }) else { return }
        remove(at: index)
    }

    func removeAllAlarms() {
        alarms.removeAll()
        Store.shared.save(self, notifying: nil, userInfo: [
            Alarm.changeReasonKey: Alarm.removed
        ])
    }

    func remove(at index: Int) {
        guard alarms.indices.contains(index) else { return }
        let alarm = alarms[index]
        let uuidStr = alarm.uuid.uuidString
        alarms.remove(at: index)
        Store.shared.save(self, notifying: nil, userInfo: [
            Alarm.changeReasonKey: Alarm.removed,
            Alarm.oldValueKey: index,
            Alarm.newValueKey: uuidStr
        ])
    }

    func update(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.uuid == alarm.uuid }) else { return }
        alarms[index] = alarm // Update the alarm
        Store.shared.save(self, notifying: alarm, userInfo: [
            Alarm.changeReasonKey: Alarm.updated,
            Alarm.oldValueKey: index,
            Alarm.newValueKey: index
        ])
    }

    var count: Int {
        return alarms.count
    }

    var uuids: Set<String> {
        return Set(alarms.map { $0.uuid.uuidString })
    }
    
    subscript(index: Int) -> Alarm {
        return alarms[index]
    }
}

extension Alarms {
    var allAlarms: [Alarm] {
        return alarms
    }
}

