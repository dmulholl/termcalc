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
                guard case CalcLangError.undefinedVariable = error else {
                    return XCTFail()
                }
            }
    }

    func testDivByZeroError() {
        let interpreter = Interpreter()
        XCTAssertThrowsError(
            try interpreter.interpret(source: "1 / 0")) { error in
                guard case CalcLangError.divByZero = error else {
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

    func testPlusEqualsAssignment() {
        let interpreter = Interpreter()
        _ = try! interpreter.interpret(source: "foo = 1")
        _ = try! interpreter.interpret(source: "foo += 1")
        let output = try! interpreter.interpret(source: "foo")
        XCTAssertEqual(output, "2")
    }

    func testMinusEqualsAssignment() {
        let interpreter = Interpreter()
        _ = try! interpreter.interpret(source: "foo = 1")
        _ = try! interpreter.interpret(source: "foo -= 1")
        let output = try! interpreter.interpret(source: "foo")
        XCTAssertEqual(output, "0")
    }

    func testStarEqualsAssignment() {
        let interpreter = Interpreter()
        _ = try! interpreter.interpret(source: "foo = 2")
        _ = try! interpreter.interpret(source: "foo *= 3")
        let output = try! interpreter.interpret(source: "foo")
        XCTAssertEqual(output, "6")
    }

    func testSlashEqualsAssignment() {
        let interpreter = Interpreter()
        _ = try! interpreter.interpret(source: "foo = 5")
        _ = try! interpreter.interpret(source: "foo /= 2")
        let output = try! interpreter.interpret(source: "foo")
        XCTAssertEqual(output, "2.5")
    }

    func testModuloEqualsAssignment() {
        let interpreter = Interpreter()
        _ = try! interpreter.interpret(source: "foo = 10")
        _ = try! interpreter.interpret(source: "foo %= 3")
        let output = try! interpreter.interpret(source: "foo")
        XCTAssertEqual(output, "1")
    }

    func testCaretEqualsAssignment() {
        let interpreter = Interpreter()
        _ = try! interpreter.interpret(source: "foo = 2")
        _ = try! interpreter.interpret(source: "foo ^= 3")
        let output = try! interpreter.interpret(source: "foo")
        XCTAssertEqual(output, "8")
    }

    func testDegFunc() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "deg(pi)")
        XCTAssertEqual(output, "180")
    }

    func testRadFunc() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "rad(180)")
        XCTAssertEqual(output, "3.141592654")
    }

    func testDegFuncArityErrorWithNoArgs() {
        let interpreter = Interpreter()
        XCTAssertThrowsError(
            try interpreter.interpret(source: "deg()")) { error in
                guard case CalcLangError.arityError = error else {
                    return XCTFail()
                }
            }
    }

    func testDegFuncArityErrorWithTwoArgs() {
        let interpreter = Interpreter()
        XCTAssertThrowsError(
            try interpreter.interpret(source: "deg(1, 2)")) { error in
                guard case CalcLangError.arityError = error else {
                    return XCTFail()
                }
            }
    }

    func testCos_0() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cos(0)")
        XCTAssertEqual(output, "1")
    }

    func testCos_90() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cos(pi/2)")
        XCTAssertEqual(output, "0")
    }

    func testCos_180() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cos(pi)")
        XCTAssertEqual(output, "-1")
    }

    func testCos_270() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cos(3 * pi / 2)")
        XCTAssertEqual(output, "0")
    }

    func testCos_360() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cos(2 * pi)")
        XCTAssertEqual(output, "1")
    }

    func testSin_0() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sin(0)")
        XCTAssertEqual(output, "0")
    }

    func testSin_90() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sin(pi/2)")
        XCTAssertEqual(output, "1")
    }

    func testSin_180() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sin(pi)")
        XCTAssertEqual(output, "0")
    }

    func testSin_270() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sin(3 * pi / 2)")
        XCTAssertEqual(output, "-1")
    }

    func testSin_360() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sin(2 * pi)")
        XCTAssertEqual(output, "0")
    }

    func testTan_0() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tan(0)")
        XCTAssertEqual(output, "0")
    }

    func testTan_45() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tan(pi/4)")
        XCTAssertEqual(output, "1")
    }

    func testTan_135() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tan(3 * pi / 4)")
        XCTAssertEqual(output, "-1")
    }

    func testTan_180() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tan(pi)")
        XCTAssertEqual(output, "0")
    }

    func testCosd_0() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cosd(0)")
        XCTAssertEqual(output, "1")
    }

    func testCosd_90() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cosd(90)")
        XCTAssertEqual(output, "0")
    }

    func testCosd_180() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cosd(180)")
        XCTAssertEqual(output, "-1")
    }

    func testCosd_270() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cosd(270)")
        XCTAssertEqual(output, "0")
    }

    func testCosd_360() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "cosd(360)")
        XCTAssertEqual(output, "1")
    }

    func testSind_0() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sind(0)")
        XCTAssertEqual(output, "0")
    }

    func testSind_90() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sind(90)")
        XCTAssertEqual(output, "1")
    }

    func testSind_180() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sind(180)")
        XCTAssertEqual(output, "0")
    }

    func testSind_270() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sind(270)")
        XCTAssertEqual(output, "-1")
    }

    func testSind_360() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "sind(360)")
        XCTAssertEqual(output, "0")
    }

    func testTand_0() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tand(0)")
        XCTAssertEqual(output, "0")
    }

    func testTand_45() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tand(45)")
        XCTAssertEqual(output, "1")
    }

    func testTand_135() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tand(135)")
        XCTAssertEqual(output, "-1")
    }

    func testTand_180() {
        let interpreter = Interpreter()
        let output = try! interpreter.interpret(source: "tand(180)")
        XCTAssertEqual(output, "0")
    }


}
