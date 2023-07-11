import Foundation
import SwiftyGPIO


internal class LED1602Display {
    
    var RS: GPIO                    // Register select pin
    var RW: GPIO                    // Read write pin
    var E: GPIO                     // Enable pin
    var dataBus: [GPIO] = []        // 8 pins for data
    var allPins: [GPIO] = []        // RS, RW, E, and data pins in that order
    
    
    // Maybe figure out a way to that this method take Int type as parameter instead of GPIOName type
    init (RS: GPIOName, RW: GPIOName, E: GPIOName, bus: [GPIOName] ) {
        /* Set up the display interface.
         
         Initializes SwiftyGPIO, sets the GPIO pins on the Pi
         and prepares the display
         
         Parameters:
            Each paramenter is a SwiftyGPIO GPIOName type.
            Any GPIO pin on the Pi can be used.*/

        // Set pins and assign to instance properties
        let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)
        self.RS = gpios[RS]!
        self.RW = gpios[RW]!
        self.E = gpios[E]!
        
        for pin in 0...7 { dataBus.append(gpios[bus[pin]]!) }
        allPins = [self.RS, self.RW, self.E] + dataBus
        
        // Set each pin to output and turn each pin off
        for pin in allPins {
            pin.direction = .OUT
        }
        clearPins()
        
        // Initilize the display
        waitForBusyFlag()
        initDisplay()
        reset()
        
    }
    
    func initDisplay () {
        send(instruction: 0x38)  // Display function set
        send(instruction: 0x0a)  // Display entry mode
        send(instruction: 0x0c)  // Set cursor flass and
    }
    
    // Maybe make bus it's own object that can deal with all this stuff
    // When I have Shift rigister, I can have a shift register bus object as well
    func loadBus(data: UInt8) {
        var bitValue: UInt8
        for bit in 0...7 {
            
            /* Peel off the value of a single bit by:
             Step 1) Shift data to the right
             Step 2) AND with 1 */
            bitValue = ( data >> bit ) & 0x01
            
            // load bit onto buss
            dataBus[bit].value = Int.init(bitValue)
        }
    }
    
    func enablePulse() {
        /* Sends an enable pulse to the display.
         According to the documentation for the display,
         the enable pulse must be high for at least 40us,
         and after the pulse goes low, the data should
         be held for another 10us
         */
        
        E.value = 1
        usleep(100) // Needs to be AT LEAST 40us
        E.value = 0
        usleep(20) // Needs to be AT LEAST 10 us
    }
    
    func clearPins () {
        for pin in allPins {
            pin.value = 0
        }
    }
    
    func waitForBusyFlag() {
        let busyFlag = dataBus[7]
        busyFlag.direction = .IN
        busyFlag.pull = .up
        
        while busyFlag.value == 0 {
            usleep(50)
        }
        
        busyFlag.direction = .OUT
    }
    
    func send(data: UInt8) {
        RS.value = 1            // RS HIGH for data register
        RW.value = 0            // RW LOW for wright
        loadBus(data: data)     // Load data to bus
        
        usleep(50)              // Give display time to access register
        
        enablePulse()
        clearPins()
        waitForBusyFlag()
        
    }
    
    func send(instruction: UInt8) {
        RS.value = 0            // RS LOW for instruction register
        RW.value = 0            // RW LOW for wright
        loadBus(data: instruction)     // Load data to bus
        
        usleep(50)              // Give display time to access register
        
        
        enablePulse()
        clearPins()
        waitForBusyFlag()
        
    }
    
    func reset () {
        send(instruction: 0x01) // Clear the Display
        send(instruction: 0x03) // Retun cursor to begining of display
    }
    
    func displayOnTop (_ message: String) {
        send(instruction: 0x80) // Set cursor begining of top row
        for char in message {
            send(data: char.asciiValue!)
        }
    }
    
    func displayOnBottom (_ message: String) {
        send(instruction: 0xc0) // Set cursor begining of bottom row
        for char in message {
            send(data: char.asciiValue!)
        }
    }
    
}