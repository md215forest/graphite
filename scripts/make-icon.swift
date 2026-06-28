#!/usr/bin/env swift
// Generates Graphite's app icon from the in-app brand mark: the graphite
// hexagon (Theme.Hexagon, Silver accent gradient) on the dark window surface,
// inside a rounded macOS app tile. Renders a full .iconset and packs an .icns.
//
// Usage: swift scripts/make-icon.swift  ->  dist/AppIcon.icns
// build-app.sh runs this automatically; run it directly to refresh the icon.

import AppKit

func color(_ rgb: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(
        red: CGFloat((rgb >> 16) & 0xFF) / 255,
        green: CGFloat((rgb >> 8) & 0xFF) / 255,
        blue: CGFloat(rgb & 0xFF) / 255,
        alpha: a
    )
}

// Hexagon matching Theme.Hexagon: polygon(50% 0,100% 25%,100% 75%,50% 100%,0 75%,0 25%).
func hexagonPath(in rect: CGRect) -> CGPath {
    let w = rect.width, h = rect.height, x = rect.minX, y = rect.minY
    let p = CGMutablePath()
    p.move(to: CGPoint(x: x + 0.5 * w, y: y))
    p.addLine(to: CGPoint(x: x + w, y: y + 0.25 * h))
    p.addLine(to: CGPoint(x: x + w, y: y + 0.75 * h))
    p.addLine(to: CGPoint(x: x + 0.5 * w, y: y + h))
    p.addLine(to: CGPoint(x: x, y: y + 0.75 * h))
    p.addLine(to: CGPoint(x: x, y: y + 0.25 * h))
    p.closeSubpath()
    return p
}

func drawIcon(size: CGFloat) -> CGImage {
    let s = Int(size)
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(
        data: nil, width: s, height: s, bitsPerComponent: 8, bytesPerRow: 0,
        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!

    // Rounded app tile, inset slightly so it reads as a macOS icon.
    let margin = size * 0.085
    let tile = CGRect(x: margin, y: margin, width: size - 2 * margin, height: size - 2 * margin)
    let radius = tile.width * 0.2237
    let tilePath = CGPath(roundedRect: tile, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Dark window surface (Theme.windowGradient): 0x232427 -> 0x191A1D, radial.
    ctx.saveGState()
    ctx.addPath(tilePath)
    ctx.clip()
    let bg = CGGradient(
        colorsSpace: cs,
        colors: [color(0x282A2E), color(0x191A1D)] as CFArray,
        locations: [0, 1]
    )!
    let bgCenter = CGPoint(x: tile.midX, y: tile.maxY - tile.height * 0.12)
    ctx.drawRadialGradient(
        bg, startCenter: bgCenter, startRadius: 0,
        endCenter: bgCenter, endRadius: tile.width * 0.85,
        options: [.drawsAfterEndLocation]
    )
    // Subtle inner top highlight.
    ctx.setStrokeColor(color(0xFFFFFF, 0.06))
    ctx.setLineWidth(size * 0.006)
    ctx.addPath(tilePath)
    ctx.strokePath()
    ctx.restoreGState()

    // Hexagon brand mark, Silver accent gradient (0xB9BEC8 -> 0x36383E),
    // top-leading to bottom-trailing. Keeps the 17:19 aspect of the in-app mark.
    let hexH = size * 0.50
    let hexW = hexH * (17.0 / 19.0)
    let hexRect = CGRect(x: (size - hexW) / 2, y: (size - hexH) / 2, width: hexW, height: hexH)
    let hex = hexagonPath(in: hexRect)

    ctx.saveGState()
    ctx.addPath(hex)
    ctx.clip()
    let hexGrad = CGGradient(
        colorsSpace: cs,
        colors: [color(0xC7CCD6), color(0x34363C)] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(
        hexGrad,
        start: CGPoint(x: hexRect.minX, y: hexRect.maxY),
        end: CGPoint(x: hexRect.maxX, y: hexRect.minY),
        options: []
    )
    ctx.restoreGState()

    // White edge stroke (the in-app .overlay stroke, opacity 0.3).
    ctx.addPath(hex)
    ctx.setStrokeColor(color(0xFFFFFF, 0.30))
    ctx.setLineWidth(max(1, size * 0.008))
    ctx.strokePath()

    return ctx.makeImage()!
}

func writePNG(_ image: CGImage, to url: URL) {
    let rep = NSBitmapImageRep(cgImage: image)
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: url)
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let dist = root.appendingPathComponent("dist")
let iconset = dist.appendingPathComponent("AppIcon.iconset")
try? FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

// (base point size, scale) -> standard iconset filenames.
let variants: [(Int, Int)] = [(16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2), (256, 1), (256, 2), (512, 1), (512, 2)]
for (base, scale) in variants {
    let px = base * scale
    let img = drawIcon(size: CGFloat(px))
    let name = scale == 1 ? "icon_\(base)x\(base).png" : "icon_\(base)x\(base)@2x.png"
    writePNG(img, to: iconset.appendingPathComponent(name))
}

let proc = Process()
proc.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
proc.arguments = ["-c", "icns", iconset.path, "-o", dist.appendingPathComponent("AppIcon.icns").path]
try! proc.run()
proc.waitUntilExit()
print("==> Wrote \(dist.appendingPathComponent("AppIcon.icns").path)")
