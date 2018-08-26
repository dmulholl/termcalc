import XCTest
@testable import CalcLang

final class ParserTests: XCTestCase {

    func testEmptyString() {
        let scanner = Scanner("")
        let tokens = try! scanner.scan()
        let parser = Parser(tokens)
        XCTAssertThrowsError(try parser.parse())
    }

    func testSingleLiteral() {
        let scanner = Scanner("1")
        let tokens = try! scanner.scan()
        let parser = Parser(tokens)
        let expr = try! parser.parse()
        let string = ExprPrinter().stringify(expr)
        XCTAssertEqual(string, "1.0")
    }

    func testBinaryExpr() {
        let scanner = Scanner("1 + 2")
        let tokens = try! scanner.scan()
        let parser = Parser(tokens)
        let expr = try! parser.parse()
        let string = ExprPrinter().stringify(expr)
        XCTAssertEqual(string, "(+ 1.0 2.0)")
    }

    func testBinaryExprWithUnaryOperands() {
        let scanner = Scanner("+1 + -2")
        let tokens = try! scanner.scan()
        let parser = Parser(tokens)
        let expr = try! parser.parse()
        let string = ExprPrinter().stringify(expr)
        XCTAssertEqual(string, "(+ (+ 1.0) (- 2.0))")
    }

    func testLeftAssociativity() {
        let scanner = Scanner("1 + 2 + 3")
        let tokens = try! scanner.scan()
        let parser = Parser(tokens)
        let expr = try! parser.parse()
        let string = ExprPrinter().stringify(expr)
        XCTAssertEqual(string, "(+ (+ 1.0 2.0) 3.0)")
    }

    func testPrecedence() {
        let scanner = Scanner("1 + 2 * 3")
        let tokens = try! scanner.scan()
        let parser = Parser(tokens)
        let expr = try! parser.parse()
        let string = ExprPrinter().stringify(expr)
        XCTAssertEqual(string, "(+ 1.0 (* 2.0 3.0))")
    }

    func testGrouping() {
        let scanner = Scanner("(1 + 2) * 3")
        let tokens = try! scanner.scan()
        let parser = Parser(tokens)
        let expr = try! parser.parse()
        let string = ExprPrinter().stringify(expr)
        XCTAssertEqual(string, "(* (+ 1.0 2.0) 3.0)")
    }




}
