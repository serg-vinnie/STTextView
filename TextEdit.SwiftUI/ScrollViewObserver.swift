
import Foundation
import AsyncNinja
import STTextViewUI
import AppKit
import Cocoa

//@ninjaModel
class ScrollViewObserver : ExecutionContext, ReleasePoolOwner, ObservableObject {
    public let executor    = Executor.init(queue: DispatchQueue.main)
    public let releasePool = ReleasePool()
    
    private let allEvents = AsyncNinja.Producer<Void,Void>()
    
    init() {
        allEvents
            .throttle(interval: 0.1)
            .onUpdate(context: self) { me, _ in
                NotificationCenter.default.post(Notification(name: .STTextViewRedraw))
            }
    }
    
    func subscribe(to scrollView: NSScrollView) {
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(collectionViewDidScroll(notification:)),
                                               name: NSView.boundsDidChangeNotification,
                                               object: scrollView.contentView)
    }
    
    @objc func collectionViewDidScroll(notification: Notification) {
        allEvents.update(())
    }
}
