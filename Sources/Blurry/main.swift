
import AppKit
import CommandLineKit

let app = NSApplication.shared
let wm = BlurryWindowManager()
let cli = CommandLineKit.CommandLine()

let width = DoubleOption(shortFlag: "w", longFlag: "width",
  helpMessage: "Width of the window.")
let height = DoubleOption(shortFlag: "h", longFlag: "height",
  helpMessage: "Height of the window.")

let top = DoubleOption(shortFlag: "t", longFlag: "top",
  helpMessage: "Gap between the window and the top screen edge.")
let right = DoubleOption(shortFlag: "r", longFlag: "right",
  helpMessage: "Gap between the window and the right screen edge.")
let bottom = DoubleOption(shortFlag: "b", longFlag: "bottom",
  helpMessage: "Gap between the window and the bottom screen edge.")
let left = DoubleOption(shortFlag: "l", longFlag: "left",
  helpMessage: "Gap between the window and the left screen edge.")
let radius = DoubleOption(shortFlag: "c", longFlag: "cornerRadius",
  helpMessage: "Radius of the window corners.")
let shadow = BoolOption(shortFlag: "s", longFlag: "shadow",
  helpMessage: "Wheter or not to draw a window shadow")
let material = IntOption(shortFlag: "m", longFlag: "material",
  helpMessage: "Window material, this must be an integer between 1-9.")
let display = IntOption(shortFlag: "d", longFlag: "display",
    helpMessage: "Display Identifier, this is an Unsigned Integer e.g. 458659626")


cli.addOptions(width, height, top, right, bottom, left, radius, shadow, material, display)

do {
  try cli.parse()
} catch {
  cli.printUsage(error)
  exit(EX_USAGE)
}

wm.left     = left.value != nil ? CGFloat(left.value!) : nil
wm.right    = right.value != nil ? CGFloat(right.value!) : nil
wm.top      = top.value != nil ? CGFloat(top.value!) : nil
wm.bottom   = bottom.value != nil ? CGFloat(bottom.value!) : nil
wm.height   = height.value != nil ? CGFloat(height.value!) : nil
wm.width    = width.value != nil ? CGFloat(width.value!) : nil
wm.radius   = radius.value != nil ? CGFloat(radius.value!) : wm.radius
wm.shadow   = shadow.value
wm.material = material.value != nil ? material.value! : wm.material
wm.display  = display.value != nil ? UInt(display.value!) : nil

wm.run()
app.run()
