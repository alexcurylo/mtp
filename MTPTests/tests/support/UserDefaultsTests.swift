// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UserDefaultsTests: XCTestCase {

    func testCodable() throws {
        // given
        let defaults = UserDefaults()
        let expected = Checked()

        // when
        defaults.set(nil, forKey: #function)
        let empty = try defaults.get(objectType: Checked.self, forKey: #function)
        try defaults.set(object: expected, forKey: #function)
        let actual = try defaults.get(objectType: Checked.self, forKey: #function)

        // then
        XCTAssertNil(empty)
        XCTAssertEqual(expected, actual)
   }

    func testInfoDictionary() throws {
        // given
        let plist = try unwrap(Bundle.main.infoDictionary)
        let expectedVersion = try unwrap(plist["CFBundleShortVersionString"])
        let expectedBuild = try unwrap(plist["CFBundleVersion"])

        // when
        StringKey.configureSettingsDisplay()
        let plistVersion = try unwrap(StringKey.appVersion.infoString)
        let plistBuild = try unwrap(StringKey.appBuild.infoString)
        let defaultsVersion = try unwrap(StringKey.appVersion.string)
        let defaultsBuild = try unwrap(StringKey.appBuild.string)

        // then
        plistVersion.assert(equal: expectedVersion)
        plistBuild.assert(equal: expectedBuild)
        defaultsVersion.assert(equal: expectedVersion)
        defaultsBuild.assert(equal: expectedBuild)
    }

    func testRegisterDefaults() throws {
        // given
        let stringKey = StringKey("test.string")
        let expectedString = "expected"
        let colorKey = StringKey("test.color")
        let expectedColor = UIColor.white
        let defaults = [stringKey: expectedString,
                        colorKey: expectedColor] as [StringKey: Any]

        // when
        UserDefaults.standard.register(defaults: defaults)

        // then
        let string = try unwrap(stringKey.string)
        string.assert(equal: expectedString)
        let color: UIColor = try unwrap(UserDefaults.standard[colorKey])
        XCTAssertEqual(color, expectedColor)
    }

    func testSubscripts() {
        // given
        let defaults = UserDefaults()
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
        defaults[boolKey] = boolValue
        defaults[intKey] = intValue
        defaults[doubleKey] = doubleValue
        defaults[floatKey] = floatValue
        defaults[cgFloatKey] = cgFloatValue
        defaults[urlKey] = urlValue
        defaults[dateKey] = dateValue
        defaults[stringKey] = stringValue
        defaults[colorKey] = noColor
        defaults[colorKey] = colorValue

        // then
        XCTAssertEqual(boolValue, defaults[boolKey])
        XCTAssertEqual(intValue, defaults[intKey])
        XCTAssertEqual(doubleValue, defaults[doubleKey])
        XCTAssertEqual(floatValue, defaults[floatKey])
        XCTAssertEqual(cgFloatValue, defaults[cgFloatKey])
        XCTAssertEqual(urlValue, defaults[urlKey])
        XCTAssertEqual(dateValue, defaults[dateKey])
        XCTAssertEqual(stringValue, defaults[stringKey])
        XCTAssertEqual(colorValue, defaults[colorKey])
    }
}
