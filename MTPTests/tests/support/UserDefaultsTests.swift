// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UserDefaultsTests: TestCase {

    func testCodable() throws {
        // given
        struct Test: Codable, Equatable {
            let a: Int
            let b: String
        }
        let expected = Test(a: 1, b: "test")
        let sut = UserDefaults()

        // when
        try sut.set(object: expected,
                    forKey: #function)
        let actual = try sut.get(objectType: Test.self,
                                 forKey: #function)
        let missing = try? sut.get(objectType: Test.self,
                                   forKey: "missing")

        // then
        XCTAssertEqual(expected, actual)
        XCTAssertNil(missing)
    }

    func testInfoDictionary() throws {
        // given
        let plist = try XCTUnwrap(Bundle.main.infoDictionary)
        let expectedVersion = try XCTUnwrap(plist["CFBundleShortVersionString"])
        let expectedBuild = try XCTUnwrap(plist["CFBundleVersion"])

        // when
        StringKey.configureSettingsDisplay()
        let plistVersion = try XCTUnwrap(StringKey.appVersion.infoString)
        let plistBuild = try XCTUnwrap(StringKey.appBuild.infoString)
        let defaultsVersion = try XCTUnwrap(StringKey.appVersion.string)
        let defaultsBuild = try XCTUnwrap(StringKey.appBuild.string)

        // then
        plistVersion.assert(equal: expectedVersion)
        plistBuild.assert(equal: expectedBuild)
        defaultsVersion.assert(equal: expectedVersion)
        defaultsBuild.assert(equal: expectedBuild)
    }

    func testRegisterDefaults() throws {
        // given
        let sut = UserDefaults()
        let stringKey = StringKey("test.string")
        let expectedString = "expected"
        let colorKey = StringKey("test.color")
        let expectedColor = UIColor.white
        let defaults = [stringKey: expectedString,
                        colorKey: expectedColor] as [StringKey: Any]

        // when
        sut.register(defaults: defaults)

        // then
        let string = try XCTUnwrap(stringKey.string)
        string.assert(equal: expectedString)
        let color: UIColor = try XCTUnwrap(sut[colorKey])
        XCTAssertEqual(color, expectedColor)
    }

    func testSubscripts() {
        // given
        let sut = UserDefaults()
        let boolKey = StringKey(rawValue: "bool")
        let boolValue = true
        let intKey: StringKey = "int"
        let intValue = 5
        let doubleKey = StringKey("double")
        let doubleValue = Double(5)
        let floatKey = StringKey("float")
        let floatValue = Float(5)
        let cgFloatKey = StringKey("cgFloat")
        let cgFloatValue = CGFloat(5)
        let urlKey = StringKey("url")
        let urlValue = URL(string: "http://mtp.travel")
        let dateKey = StringKey("date")
        let dateValue = Date()
        let stringKey = StringKey("string")
        let stringValue = "value"
        let colorKey = StringKey("color")
        let colorValue = UIColor.white
        let noColor: UIColor? = nil

        // when
        sut[boolKey] = boolValue
        sut[intKey] = intValue
        sut[doubleKey] = doubleValue
        sut[floatKey] = floatValue
        sut[cgFloatKey] = cgFloatValue
        sut[urlKey] = urlValue
        sut[dateKey] = dateValue
        sut[stringKey] = stringValue
        sut[colorKey] = noColor
        sut[colorKey] = colorValue

        // then
        XCTAssertEqual(boolValue, sut[boolKey])
        XCTAssertEqual(intValue, sut[intKey])
        XCTAssertEqual(doubleValue, sut[doubleKey])
        XCTAssertEqual(floatValue, sut[floatKey])
        XCTAssertEqual(cgFloatValue, sut[cgFloatKey])
        XCTAssertEqual(urlValue, sut[urlKey])
        XCTAssertEqual(dateValue, sut[dateKey])
        XCTAssertEqual(stringValue, sut[stringKey])
        XCTAssertEqual(colorValue, sut[colorKey])
    }
}
