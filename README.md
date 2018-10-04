x# Stylish-Trucker-Belt-Synthesizer
A stylus-based music synthesizer you can wear as a belt! 

Conceived as a piece of premium swag for the MAGwest convention, "Stylish!" investigates how cheaply one can make a real, useful monophonic, digital (virtual analog) music synthesizer! Borrowing the stylus-based keyboard from the venerable Stylophone, and adding complete synthesis features like multiple oscillators, filters, envelopes, vibrato, etc. that are fully adjustable so that you can make your own sounds! It may even end up with a step sequencer and drum loop! 
Let's bring real music synthesis to the masses, stylishly!

Project is based around the "Blue Pill" STM32F103C8T6 microcontroller board that can be obtained from AliExpress for less than $2.
Code is written using Arduino IDE and STM32Duino.
Audio output is via PWM (10k resistor + 1uF capacitor) using the Mozzi library. CC4.0 Share Alike Non-commercial license applies.
LEDs are WS2812B, and the project PCB includes a header to use a standard 16 LED ring.
Amplifier is XH-M125 based on the XPT8871, which you an also buy cheaply from AliExpress. Headers are included to simply mount this board on the unit if you don't want to solder all of those parts.
Speaker is 40-50mm 0.5W 8 Ohm
