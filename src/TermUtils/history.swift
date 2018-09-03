
class History {

    private var items = [String]()
    private var index = 0

    var max: UInt? = nil {
        didSet {
            if max != nil && items.count > max! {
                items.removeFirst(items.count - Int(max!))
            }
        }
    }

    var isAtEnd: Bool {
        return index == items.count
    }

    func add(_ item: String) {

        // Don't add a duplicate of the last item.
        if let last = items.last {
            if last == item {
                return
            }
        }

        // If we're at maximum capacity remove the oldest entry.
        if max != nil && items.count >= max! {
            _ = items.removeFirst()
        }

        items.append(item)
        index = items.count
    }

    func previous() -> String? {
        if items.count == 0 {
            return nil
        }
        index -= 1
        if index < 0 {
            index = 0
            return nil
        }
        return items[index]
    }

    func next() -> String? {
        if items.count == 0 {
            return nil
        }
        index += 1
        if index >= items.count {
            index = items.count
            return nil
        }
        return items[index]
    }
}
