EESchema Schematic File Version 5
LIBS:Stylish-Belt-Synth - Full-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 2
Title "\"Stylish\" Trucker Belt Stylus Synthesizer"
Date "2019-05-16"
Rev "0.31"
Comp "SoftEgg"
Comment1 "V0.1 T.B. Trzepacz 2018/2/19"
Comment2 "V0.2 T.B. Trzepacz 2018/10/14 USB and headphone added. Diodes for buttons and power."
Comment3 "V0.3 T.B. Trzepacz 2019/5/7 Amp volume control and power switch"
Comment4 "V0.3.1 T.B. Trzepacz 2019/5/16 Amp volume control change again."
$EndDescr
$Comp
L conn:Conn_01x01_Male J28
U 1 1 5A85684E
P 10300 675
F 0 "J28" H 10200 675 50  0000 C CNN
F 1 "PATCH SELECT" H 10125 675 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 10300 675 50  0001 C CNN
F 3 "" H 10300 675 50  0001 C CNN
	1    10300 675 
	-1   0    0    1   
$EndComp
$Comp
L conn:Conn_01x01_Male J27
U 1 1 5A856A96
P 10300 1025
F 0 "J27" H 10200 1025 50  0000 C CNN
F 1 "PARAM SELECT" H 10125 1025 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 10300 1025 50  0001 C CNN
F 3 "" H 10300 1025 50  0001 C CNN
	1    10300 1025
	-1   0    0    1   
$EndComp
$Comp
L conn:Conn_01x01_Male J26
U 1 1 5A856E54
P 10300 850
F 0 "J26" H 10200 850 50  0000 C CNN
F 1 "WRITE PATCH" H 10125 850 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 10300 850 50  0001 C CNN
F 3 "" H 10300 850 50  0001 C CNN
	1    10300 850 
	-1   0    0    1   
$EndComp
$Comp
L stm32f103c8t6-module-china:stm32f103c8t6-module-china U1
U 1 1 5A857583
P 5250 3400
F 0 "U1" H 5250 4750 60  0000 C CNN
F 1 "stm32f103c8t6-module-china" V 5250 3400 60  0000 C CNN
F 2 "SoftEggKiCAD:stm32f103c8t6-module-china-smd" H 5250 1700 60  0001 C CNN
F 3 "" H 4850 3650 60  0000 C CNN
	1    5250 3400
	1    0    0    -1  
$EndComp
$Comp
L conn:Conn_01x01_Male J29
U 1 1 5A859BB2
P 10300 1350
F 0 "J29" H 10200 1350 50  0000 C CNN
F 1 "MODE" H 10125 1350 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 10300 1350 50  0001 C CNN
F 3 "" H 10300 1350 50  0001 C CNN
	1    10300 1350
	-1   0    0    1   
$EndComp
$Comp
L conn:Conn_01x01_Male J30
U 1 1 5A85A696
P 7125 2000
F 0 "J30" H 7225 2075 50  0000 C CNN
F 1 "STYLUS" H 7225 1850 50  0000 C CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 7125 2000 50  0001 C CNN
F 3 "" H 7125 2000 50  0001 C CNN
	1    7125 2000
	-1   0    0    1   
$EndComp
$Comp
L device:C_Small C1
U 1 1 5A8BA68B
P 8825 4000
F 0 "C1" V 8725 3975 50  0000 L CNN
F 1 "1μF" H 8835 3920 50  0000 L CNN
F 2 "SoftEggKiCAD:C_Disc_D5.0mm_W2.5mm_P5.00mm+SMD" H 8825 4000 50  0001 C CNN
F 3 "" H 8825 4000 50  0001 C CNN
	1    8825 4000
	1    0    0    -1  
$EndComp
$Comp
L device:R R1
U 1 1 5A8BA742
P 8600 3800
F 0 "R1" V 8680 3800 50  0000 C CNN
F 1 "8Ω" V 8600 3800 50  0000 C CNN
F 2 "SoftEggKiCAD:R_Axial_DIN0204_L3.6mm_D1.6mm_P7.62mm_Horizontal+SMD804" V 8530 3800 50  0001 C CNN
F 3 "" H 8600 3800 50  0001 C CNN
	1    8600 3800
	0    1    1    0   
$EndComp
$Comp
L device:Speaker LS1
U 1 1 5A8BCD0B
P 10750 5275
F 0 "LS1" H 10800 5075 50  0000 R CNN
F 1 "Speaker" H 10875 5475 50  0000 R CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 10750 5075 50  0001 C CNN
F 3 "" H 10740 5225 50  0001 C CNN
	1    10750 5275
	1    0    0    -1  
$EndComp
Text Notes 9775 4075 0    60   ~ 0
R/C Circuit to convert \nPWM pulses to waveform
Wire Notes Line
	11075 4450 8325 4450
Wire Notes Line
	8350 575  11075 600 
Wire Notes Line
	11075 600  11075 1625
Wire Notes Line
	11075 1625 8350 1600
Wire Notes Line
	8350 1600 8350 575 
Text Notes 8375 800  0    60   ~ 0
PCB UI Pads\nfor Stylus
Text Notes 4825 1825 0    60   ~ 0
STM32F103C8T6\n"Blue Pill" board
Wire Wire Line
	8450 3800 8425 3800
Text Label 8425 3800 1    50   ~ 0
AUDIO_OUT
Text Label 4050 4250 2    50   ~ 0
AUDIO_OUT
Wire Wire Line
	4200 4250 4050 4250
$Sheet
S 5000 5925 625  525 
U 5B9633CF
F0 "WS2812B-16-LED-RING" 50
F1 "WS2812B-16-LED-RING.sch" 50
F2 "DIN" I L 5000 6050 50 
F3 "VIN" I L 5000 6150 50 
F4 "DOUT" I L 5000 6350 50 
F5 "GND" I L 5000 6250 50 
$EndSheet
Wire Wire Line
	5000 6050 4925 6050
Wire Wire Line
	4800 6250 5000 6250
$Comp
L SoftEggKicadLib:StylusKeyboardA KB1
U 1 1 5BA18F70
P 1400 1000
F 0 "KB1" H 1106 1225 50  0000 C CNN
F 1 "StylusKeyboardA" H 1106 1134 50  0000 C CNN
F 2 "SoftEggKiCAD:MAGWestSynthContactKeybed" H 1200 450 50  0001 C CNN
F 3 "" H 1200 450 50  0001 C CNN
	1    1400 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 2000 6300 2150
Connection ~ 6300 2000
Wire Wire Line
	5500 4700 5500 2000
Wire Wire Line
	5500 2000 6300 2000
Wire Wire Line
	4200 4700 5500 4700
Wire Notes Line
	8325 3100 11075 3100
Wire Notes Line
	11075 3100 11075 4450
Text Label 1400 1100 0    50   ~ 0
C#0
Text Label 1400 1200 0    50   ~ 0
D0
Text Label 1400 1300 0    50   ~ 0
D#0
Text Label 1400 1400 0    50   ~ 0
E0
Text Label 1400 1500 0    50   ~ 0
F0
Text Label 1400 1600 0    50   ~ 0
F#0
Text Label 1400 1700 0    50   ~ 0
G0
Text Label 1400 1800 0    50   ~ 0
G#0
Text Label 1400 1900 0    50   ~ 0
A0
Text Label 1400 2000 0    50   ~ 0
A#0
Text Label 1400 2100 0    50   ~ 0
B0
Text Label 1400 2200 0    50   ~ 0
C1
Text Label 1400 2300 0    50   ~ 0
C#1
Text Label 1400 2400 0    50   ~ 0
D1
Text Label 1400 2500 0    50   ~ 0
D#1
Text Label 1400 2600 0    50   ~ 0
E1
Text Label 1400 2700 0    50   ~ 0
F1
Text Label 1400 2800 0    50   ~ 0
F#1
Text Label 1400 2900 0    50   ~ 0
G1
Text Label 1400 3000 0    50   ~ 0
G#1
Text Label 1400 3100 0    50   ~ 0
A1
Text Label 1400 3200 0    50   ~ 0
A#1
Text Label 1400 3300 0    50   ~ 0
B1
Text Label 1400 3400 0    50   ~ 0
C2
Text Label 4200 2300 2    50   ~ 0
D0
Text Label 4200 2600 2    50   ~ 0
E0
Text Label 4200 2750 2    50   ~ 0
F0
Text Label 4200 2900 2    50   ~ 0
F#0
Text Label 6300 3350 0    50   ~ 0
G0
Text Label 6300 2600 0    50   ~ 0
G#0
Text Label 4200 3350 2    50   ~ 0
A0
Text Label 4200 3500 2    50   ~ 0
A#0
Text Label 4200 3650 2    50   ~ 0
B0
Text Label 4200 3800 2    50   ~ 0
C1
Text Label 4200 3950 2    50   ~ 0
C#1
Text Label 4200 4100 2    50   ~ 0
D1
Text Label 4200 2450 2    50   ~ 0
D#0
Text Label 4200 2150 2    50   ~ 0
C#0
Text Label 4200 4400 2    50   ~ 0
D#1
Text Label 6300 4700 0    50   ~ 0
E1
Text Label 6300 4550 0    50   ~ 0
F1
Text Label 6300 4400 0    50   ~ 0
F#1
Text Label 6300 4250 0    50   ~ 0
G1
Text Label 6300 4100 0    50   ~ 0
G#1
Text Label 6300 3950 0    50   ~ 0
A1
Text Label 6300 3800 0    50   ~ 0
A#1
Text Label 6300 3650 0    50   ~ 0
B1
Text Label 6300 3500 0    50   ~ 0
C2
Text Label 6300 2750 0    50   ~ 0
PATCH
Text Label 6300 3050 0    50   ~ 0
PARAM
Text Label 6300 2900 0    50   ~ 0
WRITE
Text Label 9250 850  2    50   ~ 0
WRITE
Text Label 9250 1025 2    50   ~ 0
PARAM
Text Label 9250 675  2    50   ~ 0
PATCH
Text Label 6300 3200 0    50   ~ 0
LED_DIN
Text Label 4925 6050 2    50   ~ 0
LED_DIN
Text Label 4200 6150 2    50   ~ 0
+3.3V
Text Label 9075 6300 2    50   ~ 0
+5V
Text Label 10875 2875 0    50   ~ 0
+5V
Text Label 4200 4550 2    50   ~ 0
+5V
$Comp
L power:GND #PWR0101
U 1 1 5BAC8FEF
P 3650 4700
F 0 "#PWR0101" H 3650 4450 50  0001 C CNN
F 1 "GND" H 3655 4527 50  0000 C CNN
F 2 "" H 3650 4700 50  0001 C CNN
F 3 "" H 3650 4700 50  0001 C CNN
	1    3650 4700
	1    0    0    -1  
$EndComp
Wire Wire Line
	4200 4700 3650 4700
Connection ~ 4200 4700
$Comp
L power:GND #PWR0102
U 1 1 5BACA4F7
P 8225 2475
F 0 "#PWR0102" H 8225 2225 50  0001 C CNN
F 1 "GND" H 8230 2302 50  0000 C CNN
F 2 "" H 8225 2475 50  0001 C CNN
F 3 "" H 8225 2475 50  0001 C CNN
	1    8225 2475
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 5BACC962
P 4800 6250
F 0 "#PWR0103" H 4800 6000 50  0001 C CNN
F 1 "GND" H 4805 6077 50  0000 C CNN
F 2 "" H 4800 6250 50  0001 C CNN
F 3 "" H 4800 6250 50  0001 C CNN
	1    4800 6250
	1    0    0    -1  
$EndComp
Text Label 6925 2000 2    50   ~ 0
STYLUS
Wire Wire Line
	6300 2150 6925 2150
Connection ~ 6300 2150
$Comp
L power:GND #PWR0104
U 1 1 5BAD0D73
P 6925 2150
F 0 "#PWR0104" H 6925 1900 50  0001 C CNN
F 1 "GND" H 6930 1977 50  0000 C CNN
F 2 "" H 6925 2150 50  0001 C CNN
F 3 "" H 6925 2150 50  0001 C CNN
	1    6925 2150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0105
U 1 1 5BAD4895
P 8250 6250
F 0 "#PWR0105" H 8250 6000 50  0001 C CNN
F 1 "GND" H 8255 6077 50  0000 C CNN
F 2 "" H 8250 6250 50  0001 C CNN
F 3 "" H 8250 6250 50  0001 C CNN
	1    8250 6250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0106
U 1 1 5BAD51F5
P 8825 4175
F 0 "#PWR0106" H 8825 3925 50  0001 C CNN
F 1 "GND" H 8830 4002 50  0000 C CNN
F 2 "" H 8825 4175 50  0001 C CNN
F 3 "" H 8825 4175 50  0001 C CNN
	1    8825 4175
	1    0    0    -1  
$EndComp
Text Label 10625 3775 0    50   ~ 0
PWM_OUT
Wire Notes Line
	8325 3100 8325 4450
Wire Wire Line
	6300 2000 6925 2000
Text Label 1400 1000 0    50   ~ 0
C0
Text Label 4200 2000 2    50   ~ 0
C0
$Comp
L diode:1N4148 D1
U 1 1 5BBC38EE
P 9425 1200
F 0 "D1" V 9475 1350 50  0000 R CNN
F 1 "1N4148" V 9375 1550 50  0000 R CNN
F 2 "SoftEggKiCAD:D_DO-35_SOD27_P7.62mm_Horizontal+SMD" H 9425 1025 50  0001 C CNN
F 3 "http://www.nxp.com/documents/data_sheet/1N4148_1N4448.pdf" H 9425 1200 50  0001 C CNN
	1    9425 1200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10100 850  9425 850 
Wire Wire Line
	9425 850  9425 1050
Wire Wire Line
	9425 850  9250 850 
Connection ~ 9425 850 
Wire Wire Line
	10100 675  9250 675 
$Comp
L diode:1N4148 D2
U 1 1 5BBE6FB8
P 9900 1200
F 0 "D2" V 9946 1121 50  0000 R CNN
F 1 "1N4148" V 9850 1125 50  0000 R CNN
F 2 "SoftEggKiCAD:D_DO-35_SOD27_P7.62mm_Horizontal+SMD" H 9900 1025 50  0001 C CNN
F 3 "http://www.nxp.com/documents/data_sheet/1N4148_1N4448.pdf" H 9900 1200 50  0001 C CNN
	1    9900 1200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9900 1050 9900 1025
Connection ~ 9900 1025
Wire Wire Line
	9900 1025 9250 1025
Connection ~ 9900 1350
$Comp
L conn:USB_B J0
U 1 1 5BBEB964
P 2725 3150
F 0 "J0" H 2495 3048 50  0000 R CNN
F 1 "USB_B" H 2495 3139 50  0000 R CNN
F 2 "Connectors:USB_B" H 2875 3100 50  0001 C CNN
F 3 "" H 2875 3100 50  0001 C CNN
	1    2725 3150
	1    0    0    1   
$EndComp
Wire Wire Line
	4200 3050 3025 3050
Wire Wire Line
	4200 3200 3025 3200
Wire Wire Line
	3025 3200 3025 3150
Wire Wire Line
	2725 2750 3275 2750
$Comp
L power:GND #PWR0107
U 1 1 5BBEFFF4
P 3275 2750
F 0 "#PWR0107" H 3275 2500 50  0001 C CNN
F 1 "GND" H 3280 2577 50  0000 C CNN
F 2 "" H 3275 2750 50  0001 C CNN
F 3 "" H 3275 2750 50  0001 C CNN
	1    3275 2750
	1    0    0    -1  
$EndComp
$Comp
L conn:Audio-Jack-3_2Switches J1
U 1 1 5BC093A8
P 10075 5300
F 0 "J1" H 9788 5370 50  0000 R CNN
F 1 "Headphone" H 10375 5025 50  0000 R CNN
F 2 "Connectors:Stereo_Jack_3.5mm_Switch_Ledino_KB3SPRS" H 10325 5400 50  0001 C CNN
F 3 "~" H 10325 5400 50  0001 C CNN
	1    10075 5300
	-1   0    0    -1  
$EndComp
Wire Wire Line
	9875 5200 9850 5200
Wire Wire Line
	9850 5200 9850 5300
Connection ~ 9850 5300
Wire Wire Line
	9850 5300 9875 5300
Wire Wire Line
	10275 5500 10550 5500
Wire Wire Line
	10550 5500 10550 5375
Connection ~ 10275 5500
Wire Wire Line
	9875 5100 9875 5000
Wire Wire Line
	9875 5000 10550 5000
Wire Wire Line
	10550 5000 10550 5275
Wire Wire Line
	9875 5400 9800 5400
Wire Wire Line
	9800 5400 9800 5000
Wire Wire Line
	9800 5000 9875 5000
Connection ~ 9875 5000
Wire Wire Line
	9425 1350 9900 1350
Wire Wire Line
	9900 1350 10100 1350
Wire Wire Line
	9900 1025 10100 1025
$Comp
L device:D_Schottky D3
U 1 1 5BC7018F
P 9350 2425
F 0 "D3" H 9350 2209 50  0000 C CNN
F 1 "1N5822" H 9350 2300 50  0000 C CNN
F 2 "SoftEggKiCAD:D_DO-35_SOD27_P7.62mm_Horizontal+SMD" H 9350 2425 50  0001 C CNN
F 3 "~" H 9350 2425 50  0001 C CNN
	1    9350 2425
	-1   0    0    1   
$EndComp
$Comp
L device:D_Schottky D4
U 1 1 5BC81B93
P 3250 3350
F 0 "D4" H 3375 3425 50  0000 C CNN
F 1 "1N5822" H 3250 3525 50  0000 C CNN
F 2 "SoftEggKiCAD:D_DO-35_SOD27_P7.62mm_Horizontal+SMD" H 3250 3350 50  0001 C CNN
F 3 "~" H 3250 3350 50  0001 C CNN
	1    3250 3350
	-1   0    0    1   
$EndComp
$Comp
L SoftEggKicadLib:XPT8871 U?
U 1 1 5CD1D131
P 9175 5400
AR Path="/5B8EAE51/5CD1D131" Ref="U?"  Part="1" 
AR Path="/5CD1D131" Ref="U2"  Part="1" 
F 0 "U2" H 9125 5850 60  0000 C CNN
F 1 "XPT8871" H 9175 5600 60  0000 C CNN
F 2 "SMD_Packages:SOIC-8-N" H 9175 5300 60  0001 C CNN
F 3 "" H 9175 5300 60  0001 C CNN
	1    9175 5400
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small CA?
U 1 1 5CD1D13D
P 8450 5925
AR Path="/5B8EAE51/5CD1D13D" Ref="CA?"  Part="1" 
AR Path="/5CD1D13D" Ref="CA1"  Part="1" 
F 0 "CA1" V 8375 5750 50  0000 L CNN
F 1 "470μF" V 8375 5975 50  0000 L CNN
F 2 "SoftEggKiCAD:C_Disc_D5.0mm_W2.5mm_P5.00mm+SMD" H 8450 5925 50  0001 C CNN
F 3 "" H 8450 5925 50  0001 C CNN
	1    8450 5925
	0    1    1    0   
$EndComp
$Comp
L device:C_Small CA?
U 1 1 5CD1D14C
P 8125 5100
AR Path="/5B8EAE51/5CD1D14C" Ref="CA?"  Part="1" 
AR Path="/5CD1D14C" Ref="CA4"  Part="1" 
F 0 "CA4" V 8025 5050 50  0000 L CNN
F 1 "0.39μF" V 8225 5000 50  0000 L CNN
F 2 "SoftEggKiCAD:C_Disc_D5.0mm_W2.5mm_P5.00mm+SMD" H 8125 5100 50  0001 C CNN
F 3 "" H 8125 5100 50  0001 C CNN
	1    8125 5100
	0    1    1    0   
$EndComp
$Comp
L device:C_Small CA?
U 1 1 5CD1D154
P 8350 5500
AR Path="/5B8EAE51/5CD1D154" Ref="CA?"  Part="1" 
AR Path="/5CD1D154" Ref="CA3"  Part="1" 
F 0 "CA3" V 8450 5450 50  0000 L CNN
F 1 "1μF" V 8250 5450 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_Tantal_D4.5mm_P2.50mm" H 8350 5500 50  0001 C CNN
F 3 "" H 8350 5500 50  0001 C CNN
	1    8350 5500
	0    1    1    0   
$EndComp
Wire Wire Line
	8575 5300 8250 5300
Wire Wire Line
	8250 5300 8250 5500
Wire Wire Line
	8575 5700 8250 5700
Wire Wire Line
	8250 5700 8250 5500
Wire Wire Line
	8250 5700 8250 6000
Wire Wire Line
	8250 6200 9375 6200
Wire Wire Line
	9375 6200 9375 6000
Connection ~ 8250 5700
$Comp
L device:C_Small CA?
U 1 1 5CD1D137
P 8450 6100
AR Path="/5B8EAE51/5CD1D137" Ref="CA?"  Part="1" 
AR Path="/5CD1D137" Ref="CA2"  Part="1" 
F 0 "CA2" V 8500 5925 50  0000 L CNN
F 1 "1μF" V 8500 6150 50  0000 L CNN
F 2 "SoftEggKiCAD:C_Disc_D5.0mm_W2.5mm_P5.00mm+SMD" H 8450 6100 50  0001 C CNN
F 3 "" H 8450 6100 50  0001 C CNN
	1    8450 6100
	0    1    1    0   
$EndComp
Wire Wire Line
	8350 5925 8350 6000
Wire Wire Line
	8550 6100 8550 6000
Connection ~ 8550 6000
Wire Wire Line
	8550 6000 8550 5925
Wire Wire Line
	8350 6000 8250 6000
Connection ~ 8350 6000
Wire Wire Line
	8350 6000 8350 6100
Connection ~ 8250 6000
Wire Wire Line
	8250 6000 8250 6200
Wire Wire Line
	9075 6000 9075 6300
Wire Wire Line
	8250 6200 8250 6250
Connection ~ 8250 6200
$Comp
L SoftEggKicadLib:Switch_Pot RV1
U 1 1 5CE33B0D
P 9750 3325
F 0 "RV1" H 10000 3375 50  0000 C CNN
F 1 "Volume" H 9941 3265 50  0000 C CNN
F 2 "SoftEggKiCAD:Wheel_Pot_W_Switch_RV12_B103_FUSTAR" H 9750 3325 50  0001 C CNN
F 3 "~" H 9750 3325 50  0001 C CNN
	1    9750 3325
	0    -1   1    0   
$EndComp
Connection ~ 9075 6000
Wire Wire Line
	8550 6000 9075 6000
Wire Wire Line
	8450 5500 8575 5500
Connection ~ 8250 5500
Wire Wire Line
	7825 5100 8025 5100
Wire Wire Line
	8750 3800 8825 3800
Wire Wire Line
	8825 4100 8825 4175
Wire Wire Line
	8550 2425 8225 2425
Wire Wire Line
	8225 2425 8225 2475
Wire Wire Line
	3025 3350 3100 3350
Text Label 3400 3350 0    50   ~ 0
VUSB
Text Label 9575 1950 2    50   ~ 0
VUSB
Wire Wire Line
	9575 2425 9500 2425
Wire Notes Line
	7450 4650 10925 4650
Wire Notes Line
	10925 4650 10925 6475
Wire Notes Line
	10925 6475 7450 6475
Wire Notes Line
	7450 6475 7450 4650
Text Notes 8225 4800 0    79   ~ 0
Amplifier Stage
Text Notes 8350 3250 0    79   ~ 0
PWM Output Filter
Wire Notes Line
	8100 1775 8100 3075
Wire Notes Line
	8100 3075 11075 3075
Wire Notes Line
	11075 3075 11075 1775
Wire Notes Line
	11075 1775 8100 1775
Text Notes 8175 1925 0    79   ~ 0
Power Input
$Comp
L device:CP C3
U 1 1 5CF40A6F
P 10175 2600
F 0 "C3" H 10275 2675 50  0000 L CNN
F 1 "470μF" H 10275 2575 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D10.0mm_P5.00mm" H 10213 2450 50  0001 C CNN
F 3 "~" H 10175 2600 50  0001 C CNN
	1    10175 2600
	-1   0    0    1   
$EndComp
$Comp
L device:CP C2
U 1 1 5CF41901
P 10425 2600
F 0 "C2" H 10225 2675 50  0000 L CNN
F 1 "1000μF" H 10050 2575 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_D10.0mm_P5.00mm" H 10463 2450 50  0001 C CNN
F 3 "~" H 10425 2600 50  0001 C CNN
	1    10425 2600
	-1   0    0    1   
$EndComp
Wire Wire Line
	10425 2750 10300 2750
Wire Wire Line
	10425 2450 10300 2450
Wire Wire Line
	10300 2450 10300 2350
Connection ~ 10300 2450
Wire Wire Line
	10300 2450 10175 2450
$Comp
L power:GND #PWR0125
U 1 1 5CF49FDE
P 10300 2350
F 0 "#PWR0125" H 10300 2100 50  0001 C CNN
F 1 "GND" H 10305 2177 50  0000 C CNN
F 2 "" H 10300 2350 50  0001 C CNN
F 3 "" H 10300 2350 50  0001 C CNN
	1    10300 2350
	-1   0    0    1   
$EndComp
Wire Wire Line
	10300 2875 10300 2750
Connection ~ 10300 2750
Wire Wire Line
	10300 2750 10175 2750
Text Notes 11000 2172 2    47   ~ 0
Power filtering\ncapacitors might\nbe optional.
Text Notes 8175 2150 0    47   ~ 0
Next revision we try\nmounting battery clips to the PCB.\n
Text Notes 10000 3050 0    47   ~ 0
Switch is ganged with \nwheel potentiometer.
Text Notes 9800 5950 0    47   ~ 0
Headphone jack \ndetaches speaker.\nJumper 1,2,5,4 \nif no headphone jack.
Text Notes 6825 1775 0    47   ~ 0
Stylus is\nattached via\nbanana plug.
Text Notes 3025 3850 0    47   ~ 0
Diode isolates \nUSB power \nfrom battery power.
Text Notes 8375 1525 0    47   ~ 0
Diodes create 4th button input\nas 2nd and 3rd button simultaneous press.
Text Notes 800  3650 0    47   ~ 0
Keyboard is pattern \non front of PCB.
Wire Wire Line
	9575 2875 9600 2875
Wire Wire Line
	9900 2875 10300 2875
Connection ~ 10300 2875
Wire Wire Line
	10300 2875 10875 2875
$Comp
L device:R RA1
U 1 1 5CD977FA
P 8400 5100
F 0 "RA1" V 8300 5100 50  0000 C CNN
F 1 "100Ω" V 8400 5100 50  0000 C CNN
F 2 "SoftEggKiCAD:R_Axial_DIN0204_L3.6mm_D1.6mm_P7.62mm_Horizontal+SMD804" V 8330 5100 50  0001 C CNN
F 3 "~" H 8400 5100 50  0001 C CNN
	1    8400 5100
	0    1    1    0   
$EndComp
Wire Wire Line
	8250 5100 8225 5100
Wire Wire Line
	8575 5100 8550 5100
Wire Wire Line
	8825 3800 8825 3900
Wire Wire Line
	9575 1950 9575 2425
Connection ~ 9575 2425
Wire Wire Line
	9575 2425 9575 2875
Wire Wire Line
	9750 3475 9750 3775
Wire Wire Line
	9750 3775 10625 3775
Wire Wire Line
	9900 3325 10175 3325
Wire Wire Line
	10175 3325 10175 3525
$Comp
L power:GND #PWR0126
U 1 1 5CE41E87
P 10175 3525
F 0 "#PWR0126" H 10175 3275 50  0001 C CNN
F 1 "GND" H 10180 3352 50  0000 C CNN
F 2 "" H 10175 3525 50  0001 C CNN
F 3 "" H 10175 3525 50  0001 C CNN
	1    10175 3525
	1    0    0    -1  
$EndComp
Text Label 7825 5100 2    50   ~ 0
PWM_OUT
Wire Wire Line
	9775 5300 9850 5300
Wire Wire Line
	9775 5500 10275 5500
$Comp
L device:R R2
U 1 1 5CE2A35E
P 8825 3550
F 0 "R2" H 8700 3700 50  0000 L CNN
F 1 "47Ω" V 8825 3475 50  0000 L CNN
F 2 "SoftEggKiCAD:R_Axial_DIN0204_L3.6mm_D1.6mm_P7.62mm_Horizontal+SMD804" V 8755 3550 50  0001 C CNN
F 3 "~" H 8825 3550 50  0001 C CNN
	1    8825 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	8825 3325 8825 3400
Wire Wire Line
	8825 3700 8825 3800
Connection ~ 8825 3800
Wire Wire Line
	8825 3800 8975 3800
Text Label 6300 2300 0    50   ~ 0
+3.3V
$Comp
L device:R R3
U 1 1 5CE50512
P 4450 6150
F 0 "R3" V 4350 6150 50  0000 C CNN
F 1 "120Ω" V 4450 6150 50  0000 C CNN
F 2 "SoftEggKiCAD:R_Axial_DIN0204_L3.6mm_D1.6mm_P7.62mm_Horizontal+SMD804" V 4380 6150 50  0001 C CNN
F 3 "~" H 4450 6150 50  0001 C CNN
	1    4450 6150
	0    1    1    0   
$EndComp
Wire Wire Line
	4200 6150 4300 6150
Wire Wire Line
	4600 6150 5000 6150
$Comp
L SoftEggKicadLib:SW_DPDT SW1
U 1 1 5CE36C2E
P 9300 3750
F 0 "SW1" H 9225 3825 50  0000 R CNN
F 1 "OVERDRIVE" H 9500 3350 50  0000 R CNN
F 2 "SoftEggKiCAD:MSS22D18+THT" H 9300 3750 50  0001 C CNN
F 3 "" H 9300 3750 50  0001 C CNN
	1    9300 3750
	1    0    0    -1  
$EndComp
Wire Wire Line
	8975 3800 8975 3550
Wire Wire Line
	8975 3550 9100 3550
Wire Wire Line
	8825 3325 9550 3325
Wire Wire Line
	9500 3450 9550 3450
Wire Wire Line
	9550 3450 9550 3325
Connection ~ 9550 3325
Wire Wire Line
	9550 3325 9600 3325
Wire Wire Line
	9500 3800 9550 3800
Wire Wire Line
	9550 3800 9550 3450
Connection ~ 9550 3450
Wire Wire Line
	8975 3800 8975 3900
Wire Wire Line
	8975 3900 9100 3900
Connection ~ 8975 3800
$Comp
L conn:Conn_01x01 BTN1
U 1 1 5CE9AA2C
P 8550 2625
F 0 "BTN1" H 8625 2625 50  0000 L CNN
F 1 "-" V 8565 2590 50  0000 L CNN
F 2 "SoftEggKiCAD:AA_Battery_-_Terminal" H 8550 2625 50  0001 C CNN
F 3 "~" H 8550 2625 50  0001 C CNN
	1    8550 2625
	0    1    1    0   
$EndComp
$Comp
L conn:Conn_01x01 BTP2
U 1 1 5CE9D615
P 8700 2625
F 0 "BTP2" H 8775 2625 50  0000 L CNN
F 1 "+" V 8715 2590 50  0000 L CNN
F 2 "SoftEggKiCAD:AA_Battery_+_Terminal" H 8700 2625 50  0001 C CNN
F 3 "~" H 8700 2625 50  0001 C CNN
	1    8700 2625
	0    1    1    0   
$EndComp
$Comp
L conn:Conn_01x01 BTN3
U 1 1 5CEA0422
P 8900 2625
F 0 "BTN3" H 8975 2625 50  0000 L CNN
F 1 "-" V 8915 2590 50  0000 L CNN
F 2 "SoftEggKiCAD:AA_Battery_-_Terminal" H 8900 2625 50  0001 C CNN
F 3 "~" H 8900 2625 50  0001 C CNN
	1    8900 2625
	0    1    1    0   
$EndComp
$Comp
L conn:Conn_01x01 BTP4
U 1 1 5CEA042C
P 9050 2625
F 0 "BTP4" H 9125 2625 50  0000 L CNN
F 1 "+" V 9065 2590 50  0000 L CNN
F 2 "SoftEggKiCAD:AA_Battery_+_Terminal" H 9050 2625 50  0001 C CNN
F 3 "~" H 9050 2625 50  0001 C CNN
	1    9050 2625
	0    1    1    0   
$EndComp
Wire Wire Line
	8675 2425 8700 2425
$Comp
L SoftEggKicadLib:AABatteryEnd BT12
U 1 1 5CEBA2C6
P 8575 2950
F 0 "BT12" V 8575 3225 50  0000 R CNN
F 1 "~" V 8530 2770 50  0000 R CNN
F 2 "SoftEggKiCAD:AA_Battery_Dual_Terminal" H 8575 2950 50  0001 C CNN
F 3 "~" H 8575 2950 50  0001 C CNN
	1    8575 2950
	0    -1   -1   0   
$EndComp
Connection ~ 8700 2425
Wire Wire Line
	8700 2425 8900 2425
Wire Wire Line
	9050 2425 9200 2425
$Comp
L SoftEggKicadLib:AABatteryEnd BT34
U 1 1 5CED58FA
P 8925 2950
F 0 "BT34" V 8925 2775 50  0000 R CNN
F 1 "~" V 8880 2770 50  0000 R CNN
F 2 "SoftEggKiCAD:AA_Battery_Dual_Terminal" H 8925 2950 50  0001 C CNN
F 3 "~" H 8925 2950 50  0001 C CNN
	1    8925 2950
	0    -1   -1   0   
$EndComp
$EndSCHEMATC
