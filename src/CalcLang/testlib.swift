
public func testlib() {
    print("hello world!")
    let token = Token(type: .leftparen, lexeme: "FooBar", offset: 99)
    print(token)

    let scanner = Scanner(source: "foobar")
    print(scanner)

    let token2 = Token(type: .leftparen, lexeme: "FooBar", offset: 99)

    print(token == token2)

}
