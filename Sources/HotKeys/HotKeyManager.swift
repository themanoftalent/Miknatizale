import Cocoa
import Carbon

private func globalHotKeyHandler(nextHandler: EventHandlerCallRef?, theEvent: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    guard let theEvent = theEvent else { return OSStatus(eventNotHandledErr) }

    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        theEvent,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    if status == noErr {
        DispatchQueue.main.async {
            HotKeyManager.shared.dispatch(hotKeyId: hotKeyID.id)
        }
        return noErr
    }

    return OSStatus(eventNotHandledErr)
}

public class HotKeyManager {
    public static let shared = HotKeyManager()

    private var registeredHotKeys: [UInt32: EventHotKeyRef] = [:]
    private var actionIndexMap: [UInt32: SnapAction] = [:]
    private var eventHandlerRef: EventHandlerRef?
    private let signature = OSType(0x4D41474E) // 'MAGN'

    private init() {
        setupEventHandler()
    }

    private func setupEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            globalHotKeyHandler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }

    public func registerAll() {
        unregisterAll()

        let allActions = SnapAction.allCases
        for (index, action) in allActions.enumerated() {
            let id = UInt32(index + 1)
            let combo = UserSettings.shared.keyCombination(for: action)

            var hotKeyRef: EventHotKeyRef?
            let hotKeyID = EventHotKeyID(signature: signature, id: id)

            let err = RegisterEventHotKey(
                combo.keyCode,
                combo.carbonModifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )

            if err == noErr, let ref = hotKeyRef {
                registeredHotKeys[id] = ref
                actionIndexMap[id] = action
            }
        }
    }

    public func unregisterAll() {
        for (_, ref) in registeredHotKeys {
            UnregisterEventHotKey(ref)
        }
        registeredHotKeys.removeAll()
        actionIndexMap.removeAll()
    }

    public func dispatch(hotKeyId: UInt32) {
        guard let action = actionIndexMap[hotKeyId] else { return }
        WindowManager.shared.snapActiveWindow(to: action)
    }
}
