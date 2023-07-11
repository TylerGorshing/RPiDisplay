/* RPi Display by Tyler Gorshing
 This project uses the SwiftyGPIO library and a Raspberry Pi
 to display "Hello World!" on a 1602 LED display modual
 
 Raspberry Pi - https://raspberrypi.org
 SwiftyGPIO - https://github.com/uraimo/SwiftyGPIO
 1602 LED Display Moduel - https://www.openhacks.com/uploadsproductos/eone-1602a1.pdf
 
 */

import SwiftyGPIO
import ArgumentParser

var bus: [GPIOName] = [.P12,
                   .P7,
                   .P8,
                   .P25,
                   .P24,
                   .P23,
                   .P18,
                   .P15]

let display = LED1602Display(RS: .P21, RW: .P20, E: .P16, bus: bus )

struct Display: ParsableCommand {
	@Argument(default: "") var topLine: String
	@Argument(default: "") var bottomLine: String

	func run() {
		display.displayOnTop (topLine)
		display.displayOnBottom(bottomLine)
	}
	
}

Display.main()