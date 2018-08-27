import XCTest
@testable import CalcLang

final class InterpreterTests: XCTestCase {

    func testIntegerLiteral() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "99")
        XCTAssertEqual(output, "99")
    }

    func testFloatLiteral() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "99.99")
        XCTAssertEqual(output, "99.99")
    }

    func testIntegerLiteralWithTrailingZeros() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "100")
        XCTAssertEqual(output, "100")
    }

    func testFloatLiteralWithTrailingZeros() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "99.900")
        XCTAssertEqual(output, "99.9")
    }

    func testFloatLiteralWithAllTrailingZeros() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "100.00")
        XCTAssertEqual(output, "100")
    }

    func testBinaryExpr() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1 + 2")
        XCTAssertEqual(output, "3")
    }

    func testBinaryExprWithUnaryOperands() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "+1 + -2")
        XCTAssertEqual(output, "-1")
    }

    func testAdditionMultiplicationPrecedence() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1 + 2 * 3")
        XCTAssertEqual(output, "7")
    }

    func testMultiplicationAdditionPrecedence() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1 * 2 + 3")
        XCTAssertEqual(output, "5")
    }

    func testGrouping() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "(1 + 2) * 3")
        XCTAssertEqual(output, "9")
    }

    func testZeroOutput() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1 - 1")
        XCTAssertEqual(output, "0")
    }

    func testNegativeOutput() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1 - 2")
        XCTAssertEqual(output, "-1")
    }

    func testRoundedOutputVeryCloseToZero() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "0.1 + 0.1 + 0.1 - 0.3")
        XCTAssertEqual(output, "0")
    }

    func testPiConstant() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "pi")
        XCTAssertEqual(output, "3.141592654")
    }

    func testEulerConstant() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "e")
        XCTAssertEqual(output, "2.718281828")
    }

    func testAssignment() {
        let interpreter = Interpreter()
        var output = try! interpreter.interpret(source: "foo = 101")
        XCTAssertEqual(output, "")
        output = try! interpreter.interpret(source: "foo")
        XCTAssertEqual(output, "101")
    }

    func testUndefinedVariableError() {
        let interpreter = Interpreter()
        XCTAssertThrowsError(
            try interpreter.interpret(source: "foo")) { error in
                guard case Err.undefinedVariable = error else {
                    return XCTFail()
                }
            }
    }

    func testDivByZeroError() {
        let interpreter = Interpreter()
        XCTAssertThrowsError(
            try interpreter.interpret(source: "1 / 0")) { error in
                guard case Err.divByZero = error else {
                    return XCTFail()
                }
            }
    }

    func testAddition() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1.50 + 9")
        XCTAssertEqual(output, "10.5")
    }

    func testSubtraction() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1.50 - 9")
        XCTAssertEqual(output, "-7.5")
    }

    func testMultiplication() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "1.50 * 2")
        XCTAssertEqual(output, "3")
    }

    func testDivision() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "3 / 2")
        XCTAssertEqual(output, "1.5")
    }

    func testIntegerModulo() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "3 % 2")
        XCTAssertEqual(output, "1")
    }

    func testFloatModulo() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "5 % 1.5")
        XCTAssertEqual(output, "0.5")
    }

    func testIntegerPower() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "2 ^ 3")
        XCTAssertEqual(output, "8")
    }

    func testMultiplicationPowerPrecedence() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "4 * 2 ^ 3")
        XCTAssertEqual(output, "32")
    }

    func testPowerMultiplicationPrecedence() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "2 ^ 3 * 4")
        XCTAssertEqual(output, "32")
    }

    func testFractionalPower() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "9 ^ 0.5")
        XCTAssertEqual(output, "3")
    }

    func testFloatPower() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "9 ^ 1.5")
        XCTAssertEqual(output, "27")
    }

}
