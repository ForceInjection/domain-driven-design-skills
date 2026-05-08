---
description: Visualize graphics output from unit tests to verify visual correctness of shapes, paths, and rendering
---

# Graphics Test Visualizer

Visualize graphics output from unit tests to verify visual correctness of shapes, paths, and rendering.

## Capabilities

1. **Test Visualization**
   - Render graphics paths to image files
   - Generate visual snapshots from tests
   - Create side-by-side comparisons
   - Export test output as PNG/PDF

2. **Snapshot Testing**
   - Capture baseline images
   - Compare against reference images
   - Detect visual regressions
   - Generate diff images showing changes

3. **Interactive Previews**
   - Generate HTML preview galleries
   - Create test result dashboards
   - Show multiple test cases together
   - Annotate images with test metadata

4. **Debugging Visualization**
   - Highlight path construction steps
   - Show geometry calculations visually
   - Overlay debug information
   - Animate path drawing

5. **Documentation Generation**
   - Create visual API documentation
   - Generate example galleries
   - Build shape catalogs
   - Export graphics samples

## Workflow

When invoked, this skill will:

1. **Scan**: Find graphics test files
2. **Extract**: Identify path creation code
3. **Render**: Generate visual output
4. **Compare**: Check against baselines (if exist)
5. **Report**: Create HTML gallery or test report

## Usage Instructions

When the user invokes this skill:

1. Ask what to visualize:
   - All graphics tests
   - Specific test class/method
   - Failed tests only
   - New tests without baselines

2. Choose output format:
   - HTML gallery
   - Individual PNG files
   - PDF catalog
   - Snapshot test files

3. Run tests and capture graphics
4. Generate visualizations
5. Create report

## Project-Specific Context

Your graphics test files:
- `GraphicPetalTests.swift`
- `GraphicCircleTests.swift`
- `GraphicKiteTests.swift`
- `GraphicHistogramTests.swift`
- `GraphicLineTests.swift`
- `ArrowHeadTests.swift`

## Test Visualization Patterns

### 1. Render NSBezierPath to Image

```swift
extension NSBezierPath {
    func renderToImage(
        size: CGSize = CGSize(width: 400, height: 400),
        strokeColor: NSColor = .black,
        fillColor: NSColor? = nil,
        lineWidth: CGFloat = 1.0,
        backgroundColor: NSColor = .white
    ) -> NSImage {
        let image = NSImage(size: size)

        image.lockFocus()

        // Draw background
        backgroundColor.setFill()
        NSRect(origin: .zero, size: size).fill()

        // Draw path
        self.lineWidth = lineWidth
        strokeColor.setStroke()
        if let fillColor = fillColor {
            fillColor.setFill()
            self.fill()
        }
        self.stroke()

        image.unlockFocus()

        return image
    }

    func saveToPNG(at url: URL, size: CGSize = CGSize(width: 400, height: 400)) {
        let image = renderToImage(size: size)
        if let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapImage.representation(
               using: .png,
               properties: [:]
           ) {
            try? pngData.write(to: url)
        }
    }
}
```

### 2. Enhanced Test with Visualization

```swift
final class GraphicPetalTests: XCTestCase {

    func testPetalShape() throws {
        // Create test geometry controller
        let controller = MockGeometryController()

        // Create petal
        let petal = GraphicPetal(
            controller: controller,
            forIncrement: 0,
            forValue: NSNumber(value: 50.0)
        )

        // Get the path
        let path = try XCTUnwrap(petal?.drawingPath)

        // Verify path properties
        XCTAssertFalse(path.isEmpty)

        // Visualize for debugging
        #if DEBUG
        visualizeTest(
            path: path,
            testName: "testPetalShape",
            fillColor: .systemBlue
        )
        #endif
    }

    private func visualizeTest(
        path: NSBezierPath,
        testName: String,
        strokeColor: NSColor = .black,
        fillColor: NSColor? = nil
    ) {
        let outputURL = testOutputDirectory()
            .appendingPathComponent("\(testName).png")

        path.renderToImage(
            strokeColor: strokeColor,
            fillColor: fillColor
        ).saveToPNG(at: outputURL)

        print("📊 Test visualization saved: \(outputURL.path)")
    }

    private func testOutputDirectory() -> URL {
        let baseURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("PaleoRoseTestOutput", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: baseURL,
            withIntermediateDirectories: true
        )

        return baseURL
    }
}
```

### 3. Snapshot Testing

```swift
import XCTest

final class GraphicSnapshotTests: XCTestCase {

    func testPetalSnapshot() throws {
        let controller = MockGeometryController()
        let petal = try XCTUnwrap(
            GraphicPetal(
                controller: controller,
                forIncrement: 0,
                forValue: NSNumber(value: 50.0)
            )
        )

        let path = try XCTUnwrap(petal.drawingPath)
        let image = path.renderToImage(fillColor: .systemBlue)

        // Compare against baseline
        try assertImageMatches(
            image,
            named: "petal-increment0-value50",
            testName: testName
        )
    }

    private func assertImageMatches(
        _ image: NSImage,
        named: String,
        testName: String,
        tolerance: CGFloat = 0.02  // 2% difference allowed
    ) throws {
        let baselineURL = snapshotsDirectory()
            .appendingPathComponent("\(named).png")

        // If baseline doesn't exist, create it
        if !FileManager.default.fileExists(atPath: baselineURL.path) {
            print("📸 Creating baseline snapshot: \(named)")
            image.saveToPNG(at: baselineURL)
            return
        }

        // Load baseline
        guard let baselineImage = NSImage(contentsOf: baselineURL) else {
            XCTFail("Failed to load baseline image: \(named)")
            return
        }

        // Compare images
        let difference = compareImages(image, baselineImage)

        if difference > tolerance {
            // Save failure artifacts
            let failureURL = failuresDirectory()
                .appendingPathComponent("\(named)-actual.png")
            let diffURL = failuresDirectory()
                .appendingPathComponent("\(named)-diff.png")

            image.saveToPNG(at: failureURL)
            createDiffImage(image, baselineImage).saveToPNG(at: diffURL)

            XCTFail(
                """
                Snapshot mismatch for '\(named)'
                Difference: \(difference * 100)% (tolerance: \(tolerance * 100)%)
                Actual: \(failureURL.path)
                Diff: \(diffURL.path)
                """
            )
        }
    }

    private func compareImages(
        _ image1: NSImage,
        _ image2: NSImage
    ) -> CGFloat {
        // Pixel-by-pixel comparison
        // Return percentage difference (0.0 = identical, 1.0 = completely different)
        guard let data1 = image1.tiffRepresentation,
              let data2 = image2.tiffRepresentation,
              let rep1 = NSBitmapImageRep(data: data1),
              let rep2 = NSBitmapImageRep(data: data2),
              rep1.size == rep2.size else {
            return 1.0  // Treat incomparable images as completely different
        }

        var differentPixels = 0
        let totalPixels = rep1.pixelsWide * rep1.pixelsHigh

        for y in 0..<rep1.pixelsHigh {
            for x in 0..<rep1.pixelsWide {
                let color1 = rep1.colorAt(x: x, y: y)
                let color2 = rep2.colorAt(x: x, y: y)

                if !colorsAreEqual(color1, color2) {
                    differentPixels += 1
                }
            }
        }

        return CGFloat(differentPixels) / CGFloat(totalPixels)
    }

    private func colorsAreEqual(
        _ color1: NSColor?,
        _ color2: NSColor?,
        tolerance: CGFloat = 0.01
    ) -> Bool {
        guard let c1 = color1?.usingColorSpace(.deviceRGB),
              let c2 = color2?.usingColorSpace(.deviceRGB) else {
            return false
        }

        let rDiff = abs(c1.redComponent - c2.redComponent)
        let gDiff = abs(c1.greenComponent - c2.greenComponent)
        let bDiff = abs(c1.blueComponent - c2.blueComponent)
        let aDiff = abs(c1.alphaComponent - c2.alphaComponent)

        return rDiff < tolerance && gDiff < tolerance &&
               bDiff < tolerance && aDiff < tolerance
    }

    private func createDiffImage(
        _ actual: NSImage,
        _ baseline: NSImage
    ) -> NSImage {
        let size = actual.size
        let diffImage = NSImage(size: size)

        diffImage.lockFocus()

        // Draw side-by-side comparison
        let rect1 = NSRect(x: 0, y: 0, width: size.width / 2, height: size.height)
        let rect2 = NSRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height)

        baseline.draw(in: rect1)
        actual.draw(in: rect2)

        // Draw dividing line
        NSColor.red.setStroke()
        NSBezierPath.strokeLine(
            from: NSPoint(x: size.width / 2, y: 0),
            to: NSPoint(x: size.width / 2, y: size.height)
        )

        diffImage.unlockFocus()

        return diffImage
    }

    private func snapshotsDirectory() -> URL {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
    }

    private func failuresDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("SnapshotFailures", isDirectory: true)
    }
}
```

## HTML Gallery Generation

### Test Results Gallery

```swift
struct TestResultsGallery {
    let testResults: [GraphicTestResult]

    func generateHTML() -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Graphics Test Results - PaleoRose</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                    margin: 0;
                    padding: 20px;
                    background: #f5f5f5;
                }
                .header {
                    background: white;
                    padding: 20px;
                    margin-bottom: 20px;
                    border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }
                .test-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                    gap: 20px;
                }
                .test-card {
                    background: white;
                    border-radius: 8px;
                    padding: 15px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }
                .test-card.passed {
                    border-left: 4px solid #34c759;
                }
                .test-card.failed {
                    border-left: 4px solid #ff3b30;
                }
                .test-image {
                    width: 100%;
                    height: auto;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                }
                .test-name {
                    font-weight: 600;
                    margin: 10px 0 5px 0;
                }
                .test-status {
                    font-size: 12px;
                    color: #666;
                }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>🎨 PaleoRose Graphics Test Results</h1>
                <p>Generated: \(Date())</p>
                <p>Total Tests: \(testResults.count) | Passed: \(passedCount) | Failed: \(failedCount)</p>
            </div>
            <div class="test-grid">
                \(testResults.map(testCardHTML).joined())
            </div>
        </body>
        </html>
        """
    }

    private func testCardHTML(_ result: GraphicTestResult) -> String {
        """
        <div class="test-card \(result.passed ? "passed" : "failed")">
            <img src="\(result.imageURL.path)" class="test-image" alt="\(result.testName)">
            <div class="test-name">\(result.testName)</div>
            <div class="test-status">\(result.status)</div>
        </div>
        """
    }

    private var passedCount: Int {
        testResults.filter(\.passed).count
    }

    private var failedCount: Int {
        testResults.filter { !$0.passed }.count
    }
}

struct GraphicTestResult {
    let testName: String
    let imageURL: URL
    let passed: Bool
    let status: String
}
```

## Debug Visualization

### Step-by-Step Path Construction

```swift
extension NSBezierPath {
    func renderConstructionSteps(
        size: CGSize = CGSize(width: 400, height: 400),
        outputDirectory: URL
    ) {
        var stepPaths: [NSBezierPath] = []
        let currentPath = NSBezierPath()

        // Extract all path elements
        var elementIndex = 0
        for i in 0..<elementCount {
            let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
            defer { points.deallocate() }

            let elementType = element(at: i, associatedPoints: points)

            // Add element to current path
            switch elementType {
            case .moveTo:
                currentPath.move(to: points[0])
            case .lineTo:
                currentPath.line(to: points[0])
            case .curveTo:
                currentPath.curve(
                    to: points[2],
                    controlPoint1: points[0],
                    controlPoint2: points[1]
                )
            case .closePath:
                currentPath.close()
            @unknown default:
                break
            }

            // Save snapshot
            let snapshot = currentPath.copy() as! NSBezierPath
            stepPaths.append(snapshot)
        }

        // Render each step
        for (index, path) in stepPaths.enumerated() {
            let url = outputDirectory
                .appendingPathComponent("step_\(String(format: "%03d", index)).png")
            path.saveToPNG(at: url, size: size)
        }
    }
}
```

### Annotated Geometry Visualization

```swift
func renderAnnotatedPetal(
    petal: GraphicPetal,
    controller: GraphicGeometrySource
) -> NSImage {
    let size = CGSize(width: 500, height: 500)
    let image = NSImage(size: size)

    image.lockFocus()

    // Background
    NSColor.white.setFill()
    NSRect(origin: .zero, size: size).fill()

    // Draw petal
    petal.drawingPath?.stroke()

    // Annotate key points
    let center = CGPoint(x: 250, y: 250)

    // Draw center point
    drawPoint(center, color: .red, label: "Center")

    // Draw radius lines
    NSColor.systemBlue.withAlphaComponent(0.3).setStroke()
    let radiusLine = NSBezierPath()
    radiusLine.lineWidth = 0.5
    radiusLine.setLineDash([5, 3], count: 2, phase: 0)
    // ... draw radius

    // Add text annotations
    drawLabel(
        "Max Radius: \(controller.maxRadius)",
        at: CGPoint(x: 10, y: 470)
    )

    image.unlockFocus()
    return image
}

func drawPoint(_ point: CGPoint, color: NSColor, label: String) {
    color.setFill()
    let rect = NSRect(
        x: point.x - 3,
        y: point.y - 3,
        width: 6,
        height: 6
    )
    NSBezierPath(ovalIn: rect).fill()

    drawLabel(label, at: CGPoint(x: point.x + 5, y: point.y + 5))
}

func drawLabel(_ text: String, at point: CGPoint) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 10),
        .foregroundColor: NSColor.black
    ]
    (text as NSString).draw(at: point, withAttributes: attributes)
}
```

## Integration with XCTest

### Custom Assertion

```swift
func XCTAssertPathMatches(
    _ path: NSBezierPath,
    named: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    let image = path.renderToImage()
    // Snapshot comparison logic
}

func XCTAssertImageMatches(
    _ image: NSImage,
    named: String,
    tolerance: CGFloat = 0.02,
    file: StaticString = #file,
    line: UInt = #line
) {
    // Image comparison logic
}
```

## Command Line Tools

### Generate Test Gallery

```bash
#!/bin/bash
# generate-test-gallery.sh

swift test --enable-code-coverage 2>&1 | tee test-output.txt

# Run visualization generator
swift run GraphicsTestVisualizer \
    --output ./TestResults/gallery.html \
    --snapshots ./Tests/__Snapshots__ \
    --format html

open ./TestResults/gallery.html
```

## Configuration

Store visualization settings in `.graphics-test-visualizer.json`:
```json
{
  "outputDirectory": "./TestResults",
  "imageFormat": "png",
  "imageSize": {
    "width": 400,
    "height": 400
  },
  "backgroundColor": "#FFFFFF",
  "generateHTML": true,
  "snapshotTolerance": 0.02,
  "saveFailureArtifacts": true,
  "annotateImages": true
}
```
