
import PrivateCG

func getTime() -> String
{
    let date = Date()
    let calendar = Calendar.current
    let hours = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)

    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

class BlurryWindowManager
{
    var spaceWindowList: [NSNumber: NSWindow] = [:]

    var height: CGFloat?
    var width: CGFloat?

    var top: CGFloat?
    var left: CGFloat?
    var right: CGFloat?
    var bottom: CGFloat?

    var radius: CGFloat = 0
    var material: Int   = 1
    var shadow: Bool    = false

    func run() {
        self.manageWindows()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.manageWindows), userInfo: nil, repeats: true)
    }

    @objc private func manageWindows() {

        // create windows
        for scr in NSScreen.screens {

            let size = self.getWindowDimensionsforScreen(scr)
            let currentScreenSpaces = PrivateCG.getSpacesforScreen(scr)

            for space in currentScreenSpaces! {
                if self.spaceWindowList[space] == nil {
                    let w = self.createBlurryWindow(screen: scr, contentRect: size, material: self.material, cornerRadius: self.radius, shadow: self.shadow)
                    let windowID = NSNumber.init(value: w.windowNumber)

                    // @TODO this may fail if the space was created just now -> fix this by waiting some time
                    PrivateCG.moveWindow(windowID, toSpace: space)
                    self.spaceWindowList[space] = w

                    // debuginfo
                    let displayNr = scr.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]!
                    print(getTime(), " Display: ", displayNr, "\t Space: ", space, "\t created Window (", windowID , ")", separator: "")
                }
            }
        }

        let currentSpaces = PrivateCG.getAllSpaces()
        for (space, window) in self.spaceWindowList {
            let windowID = NSNumber.init(value: window.windowNumber)

            // fixes bug that window is not visible on newly creates spaces
            // even if the windowlevel is correct
            window.orderFrontRegardless()

            // check for deleted spaces and close the corresponding windows
            if !(currentSpaces?.contains(space))! {
                window.close()
                self.spaceWindowList.removeValue(forKey: space)

                // debuginfo
                let displayNr = window.screen?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]!
                if displayNr != nil {
                    print(getTime(), " Display: ", displayNr!, "\t Space: ", space, "\t closed Window (", windowID , ")", separator: "")
                }
            }
        }
    }

    private func createBlurryWindow(screen: NSScreen?, contentRect: NSRect, material: Int, cornerRadius: CGFloat, shadow: Bool) -> NSWindow {
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: [.fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        // needed to render behind übersicht
        window.level = .init(Int(CGWindowLevelForKey(CGWindowLevelKey.desktopWindow))-1)
        window.orderFrontRegardless()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert([.fullSizeContentView, .borderless])
        window.collectionBehavior = [.ignoresCycle, .stationary]
        window.displaysWhenScreenProfileChanges = true
        window.hasShadow = shadow
        window.isMovable = false
        // @TODO, fixes weird segfault, maybe change this in the future
        window.isReleasedWhenClosed = false
        window.orderFrontRegardless()

        let effect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        window.contentView = effect
        effect.wantsLayer = false
        effect.blendingMode = .behindWindow
        effect.material = NSVisualEffectView.Material(rawValue: material)!
        effect.state = NSVisualEffectView.State.active
        if cornerRadius > 0.0 {
            effect.maskImage = self.maskImage(cornerRadius: cornerRadius)
        }

        return window
    }

    private func maskImage(cornerRadius: CGFloat) -> NSImage {
        let edgeLength = 2.0 * cornerRadius + 1.0
        let maskImage = NSImage(size: NSSize(width: edgeLength, height: edgeLength), flipped: false) { rect in
            let bezierPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            NSColor.black.set()
            bezierPath.fill()
            return true
        }
        maskImage.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        maskImage.resizingMode = .stretch
        return maskImage
    }

    /*
     When top and bottom is provided, height will be ignored,
     when left and right is provided width will be ignored
    */
    private func getWindowDimensionsforScreen(_ screen: NSScreen) -> CGRect {
        let scrHeight = screen.frame.height
        let scrWidth = screen.frame.width

        var windowHeight: CGFloat = 0
        var windowWidth: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0

        // determine dimensions
        if self.left != nil && self.right != nil {
            windowWidth = scrWidth - self.left! - self.right!
            x = self.left!
        }
        else if self.left != nil  && self.right == nil {
            windowWidth = self.width!
            x = self.left!
        }
        else if self.left == nil && self.right != nil {
            windowWidth = self.width!
            x = scrWidth - windowWidth - self.right!
        }
        else {
            windowWidth = self.width ?? CGFloat(scrWidth)
        }

        if self.top != nil && self.bottom != nil {
            windowHeight = scrHeight - self.top! - self.bottom!
            y = self.bottom!
        }
        else if self.top != nil  && self.bottom == nil {
            windowHeight = self.height!
            y = scrHeight - windowHeight - self.top!
        }
        else if self.top == nil && self.bottom != nil {
            windowHeight = self.height!
            y = self.bottom!
        }
        else {
            windowHeight = self.height ?? CGFloat(scrHeight)
        }

        return CGRect(x: x, y: y, width: windowWidth, height: windowHeight)
    }
}
