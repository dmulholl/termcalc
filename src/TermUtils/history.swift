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
        stash = nil
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

    func save(toFile path: String) throws {
        let content = items.joined(separator: "\n")
        try content.write(toFile: path, atomically: true, encoding: .utf8)
    }

    func load(fromFile path: String) throws {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        content.split(separator: "\n").forEach { add(String($0)) }
    }
}
