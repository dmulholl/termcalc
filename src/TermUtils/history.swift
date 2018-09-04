
class History {

    private var items = [String]()
    private var index = 0
    private var stash: String? = nil

    var max: UInt? = nil {
        didSet {
            if max != nil && items.count > max! {
                items.removeFirst(items.count - Int(max!))
            }
        }
    }

    func add(_ item: String) {
        if let last = items.last {
            if last == item {
                return
            }
        }

        if max != nil && items.count >= max! {
            _ = items.removeFirst()
        }

        items.append(item)
        index = items.count
    }

    func previous(current: String) -> String? {
        if items.count == 0 {
            return nil
        }
        if index == items.count {
            stash = current
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
            if let item = stash {
                stash = nil
                return item
            }
            return nil
        }
        return items[index]
    }
}
