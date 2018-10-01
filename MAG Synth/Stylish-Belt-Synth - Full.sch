EESchema Schematic File Version 4
LIBS:Stylish-Belt-Synth - Full-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 3
Title "\"Stylish\" Trucker Belt Stylus Synthesizer"
Date "2018-02-19"
Rev "0.1"
Comp "SoftEgg"
Comment1 "V0.1 T.B. Trzepacz 2018/2/19"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L conn:Conn_01x01_Male J28
U 1 1 5A85684E
P 9075 3200
F 0 "J28" H 8975 3200 50  0000 C CNN
F 1 "PATCH SELECT" H 8900 3200 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 9075 3200 50  0001 C CNN
F 3 "" H 9075 3200 50  0001 C CNN
	1    9075 3200
	-1   0    0    1   
$EndComp
$Comp
L conn:Conn_01x01_Male J27
U 1 1 5A856A96
P 9075 3050
F 0 "J27" H 8975 3050 50  0000 C CNN
F 1 "PARAM SELECT" H 8900 3050 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 9075 3050 50  0001 C CNN
F 3 "" H 9075 3050 50  0001 C CNN
	1    9075 3050
	-1   0    0    1   
$EndComp
$Comp
L conn:Conn_01x01_Male J26
U 1 1 5A856E54
P 9075 2900
F 0 "J26" H 8975 2900 50  0000 C CNN
F 1 "WRITE PATCH" H 8900 2900 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 9075 2900 50  0001 C CNN
F 3 "" H 9075 2900 50  0001 C CNN
	1    9075 2900
	-1   0    0    1   
$EndComp
$Comp
L stm32f103c8t6-module-china:stm32f103c8t6-module-china U1
U 1 1 5A857583
P 5250 3400
F 0 "U1" H 5250 4750 60  0000 C CNN
F 1 "stm32f103c8t6-module-china" V 5250 3400 60  0000 C CNN
F 2 "myelin-kicad:stm32f103c8t6-module-china" H 5250 1700 60  0001 C CNN
F 3 "" H 4850 3650 60  0000 C CNN
	1    5250 3400
	1    0    0    -1  
$EndComp
$Comp
L conn:Conn_01x01_Male J29
U 1 1 5A859BB2
P 9075 3350
F 0 "J29" H 8975 3350 50  0000 C CNN
F 1 "MODE" H 8900 3350 50  0000 R CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 9075 3350 50  0001 C CNN
F 3 "" H 9075 3350 50  0001 C CNN
	1    9075 3350
	-1   0    0    1   
$EndComp
$Comp
L conn:Conn_01x01_Male J30
U 1 1 5A85A696
P 7900 1400
F 0 "J30" H 8000 1475 50  0000 C CNN
F 1 "STYLUS" H 8000 1250 50  0000 C CNN
F 2 "SoftEggKiCAD:LargeRoundTouchPad" H 7900 1400 50  0001 C CNN
F 3 "" H 7900 1400 50  0001 C CNN
	1    7900 1400
	-1   0    0    1   
$EndComp
$Comp
L device:Battery BT1
U 1 1 5A85ADEB
P 1800 5875
F 0 "BT1" H 1900 5925 50  0000 L CNN
F 1 "4 x 1.5V" H 1900 5800 50  0000 L CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x02_Pitch2.54mm" V 1800 5935 50  0001 C CNN
F 3 "" V 1800 5935 50  0001 C CNN
	1    1800 5875
	1    0    0    -1  
$EndComp
$Comp
L device:R R2
U 1 1 5A8BA562
P 8850 5925
F 0 "R2" V 8930 5925 50  0000 C CNN
F 1 "1k" V 8850 5925 50  0000 C CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" V 8780 5925 50  0001 C CNN
F 3 "" H 8850 5925 50  0001 C CNN
	1    8850 5925
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C1
U 1 1 5A8BA68B
P 8450 5875
F 0 "C1" V 8550 5775 50  0000 L CNN
F 1 "1uF" H 8460 5795 50  0001 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 8450 5875 50  0001 C CNN
F 3 "" H 8450 5875 50  0001 C CNN
	1    8450 5875
	1    0    0    -1  
$EndComp
$Comp
L device:R R1
U 1 1 5A8BA742
P 8200 6075
F 0 "R1" V 8280 6075 50  0000 C CNN
F 1 "10k" V 8200 6075 50  0000 C CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" V 8130 6075 50  0001 C CNN
F 3 "" H 8200 6075 50  0001 C CNN
	1    8200 6075
	0    1    1    0   
$EndComp
Text Label 7575 5650 0    60   ~ 0
PWM_Audio_Out
Wire Wire Line
	8700 5625 8850 5625
Wire Wire Line
	8350 6075 8450 6075
Connection ~ 8450 6075
$Comp
L device:Speaker LS1
U 1 1 5A8BCD0B
P 9950 4900
F 0 "LS1" H 10000 5125 50  0000 R CNN
F 1 "Speaker" H 10000 5050 50  0000 R CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x02_Pitch1.27mm" H 9950 4700 50  0001 C CNN
F 3 "" H 9940 4850 50  0001 C CNN
	1    9950 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8450 6075 8450 5975
Wire Wire Line
	7975 5775 8450 5775
Wire Wire Line
	8850 5775 8850 5625
$Comp
L switches:SW_SPST SW1
U 1 1 5A8C1199
P 2175 5675
F 0 "SW1" H 2050 5750 50  0000 C CNN
F 1 "Power" H 2175 5575 50  0000 C CNN
F 2 "Buttons_Switches_SMD:SW_SPST_EVQP0" H 2175 5675 50  0001 C CNN
F 3 "" H 2175 5675 50  0001 C CNN
	1    2175 5675
	1    0    0    -1  
$EndComp
Wire Wire Line
	2550 5675 2375 5675
Text Notes 9150 6125 0    60   ~ 0
R/C Circuit to convert \nPWM pulses to waveform
Wire Notes Line
	10650 6200 7525 6200
Wire Notes Line
	8525 2800 9850 2800
Wire Notes Line
	9850 2800 9850 3625
Wire Notes Line
	9850 3625 8525 3625
Wire Notes Line
	8525 3625 8525 2800
Text Notes 8875 3600 0    60   ~ 0
PCB UI Pads\nfor Stylus
Text Notes 4150 5200 0    60   ~ 0
Battery clip glued\n to back of board
Text Notes 4825 1825 0    60   ~ 0
STM32F103C8T6\n"Blue Pill" board
Wire Wire Line
	1800 5675 1975 5675
Wire Wire Line
	8450 6075 8850 6075
Wire Wire Line
	8050 6075 8000 6075
Text Label 8000 6075 2    50   ~ 0
AUDIO_OUT
Text Label 4050 4250 2    50   ~ 0
AUDIO_OUT
Wire Wire Line
	4200 4250 4050 4250
$Sheet
S 8550 4800 600  400 
U 5B8EAE51
F0 "XH-M125-amp-board" 50
F1 "XH-M125-amp-board.sch" 50
F2 "VCC" I R 9150 5100 50 
F3 "GND" I L 8550 4900 50 
F4 "IN-" I L 8550 5000 50 
F5 "IN+" I L 8550 5100 50 
F6 "OUT-" I R 9150 5000 50 
F7 "OUT+" I R 9150 4900 50 
$EndSheet
Wire Wire Line
	9750 4900 9150 4900
Wire Wire Line
	9150 5000 9750 5000
Wire Wire Line
	8450 5100 8550 5100
Wire Wire Line
	8550 5000 8350 5000
Wire Wire Line
	8550 4900 8350 4900
$Sheet
S 8050 3800 625  525 
U 5B9633CF
F0 "WS2812B-16-LED-RING" 50
F1 "WS2812B-16-LED-RING.sch" 50
F2 "DIN" I L 8050 3925 50 
F3 "5V" I L 8050 4025 50 
F4 "DOUT" I L 8050 4225 50 
F5 "GND" I L 8050 4125 50 
$EndSheet
Wire Wire Line
	8050 3925 7725 3925
Wire Wire Line
	7725 4025 8050 4025
Wire Wire Line
	7850 4125 8050 4125
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
$Comp
L conn:Conn_01x02 BT2
U 1 1 5B9344BC
P 1450 5925
F 0 "BT2" H 1370 5692 50  0000 C CNN
F 1 "Conn_01x02" H 1370 5691 50  0001 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x02_Pitch2.54mm" H 1450 5925 50  0001 C CNN
F 3 "~" H 1450 5925 50  0001 C CNN
	1    1450 5925
	-1   0    0    1   
$EndComp
Wire Wire Line
	1650 5925 1650 6075
Wire Wire Line
	1650 6075 1800 6075
Wire Wire Line
	1650 5825 1650 5675
Wire Wire Line
	1650 5675 1800 5675
Connection ~ 1800 5675
$Comp
L device:R R4
U 1 1 5B95BBFA
P 8200 5950
F 0 "R4" V 8280 5950 50  0000 C CNN
F 1 "10k" V 8200 5950 50  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 8130 5950 50  0001 C CNN
F 3 "" H 8200 5950 50  0001 C CNN
	1    8200 5950
	0    1    1    0   
$EndComp
Wire Notes Line
	7525 5525 10650 5525
Wire Notes Line
	10650 5525 10650 6200
$Comp
L device:C_Small C2
U 1 1 5B9899BC
P 8600 5875
F 0 "C2" V 8700 5775 50  0000 L CNN
F 1 "1uF" H 8610 5795 50  0001 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D5.0mm_W2.5mm_P5.00mm" H 8600 5875 50  0001 C CNN
F 3 "" H 8600 5875 50  0001 C CNN
	1    8600 5875
	1    0    0    -1  
$EndComp
$Comp
L device:R R5
U 1 1 5B989A42
P 9025 5925
F 0 "R5" V 9105 5925 50  0000 C CNN
F 1 "1k" V 9025 5925 50  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 8955 5925 50  0001 C CNN
F 3 "" H 9025 5925 50  0001 C CNN
	1    9025 5925
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 5950 8050 6075
Connection ~ 8050 6075
Wire Wire Line
	8350 5950 8350 6075
Connection ~ 8350 6075
Wire Wire Line
	8600 5975 8450 5975
Connection ~ 8450 5975
Wire Wire Line
	8600 5775 8450 5775
Connection ~ 8450 5775
Wire Wire Line
	9025 5775 8850 5775
Connection ~ 8850 5775
Wire Wire Line
	9025 6075 8850 6075
Connection ~ 8850 6075
Text Notes 9150 5825 0    50   ~ 0
Doubled parts for thru-hole vs SMD
Text Notes 9150 5900 0    50   ~ 0
Use only one set of parts
Wire Wire Line
	9200 5100 9150 5100
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
Text Label 4200 3050 2    50   ~ 0
G0
Text Label 4200 3200 2    50   ~ 0
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
Text Label 6300 3350 0    50   ~ 0
MODE
Text Label 6300 2750 0    50   ~ 0
PATCH
Text Label 6300 3050 0    50   ~ 0
PARAM
Text Label 6300 2900 0    50   ~ 0
WRITE
Text Label 8875 2900 2    50   ~ 0
WRITE
Text Label 8875 3050 2    50   ~ 0
PARAM
Text Label 8875 3200 2    50   ~ 0
PATCH
Text Label 8875 3350 2    50   ~ 0
MODE
Text Label 6300 3200 0    50   ~ 0
LED_DIN
Text Label 7725 3925 2    50   ~ 0
LED_DIN
Text Label 7725 4025 2    50   ~ 0
+5V
Text Label 9200 5100 0    50   ~ 0
+5V
Text Label 2550 5675 0    50   ~ 0
+5V
Text Label 4200 4550 2    50   ~ 0
+5V
$Comp
L power:GND #PWR0101
U 1 1 5BAC8FEF
P 3950 4700
F 0 "#PWR0101" H 3950 4450 50  0001 C CNN
F 1 "GND" H 3955 4527 50  0000 C CNN
F 2 "" H 3950 4700 50  0001 C CNN
F 3 "" H 3950 4700 50  0001 C CNN
	1    3950 4700
	1    0    0    -1  
$EndComp
Wire Wire Line
	4200 4700 3950 4700
Connection ~ 4200 4700
Wire Wire Line
	1800 6075 2575 6075
Connection ~ 1800 6075
$Comp
L power:GND #PWR0102
U 1 1 5BACA4F7
P 2575 6075
F 0 "#PWR0102" H 2575 5825 50  0001 C CNN
F 1 "GND" H 2580 5902 50  0000 C CNN
F 2 "" H 2575 6075 50  0001 C CNN
F 3 "" H 2575 6075 50  0001 C CNN
	1    2575 6075
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 5BACC962
P 7850 4125
F 0 "#PWR0103" H 7850 3875 50  0001 C CNN
F 1 "GND" H 7855 3952 50  0000 C CNN
F 2 "" H 7850 4125 50  0001 C CNN
F 3 "" H 7850 4125 50  0001 C CNN
	1    7850 4125
	1    0    0    -1  
$EndComp
Text Label 7700 1400 2    50   ~ 0
STYLUS
Text Label 6925 2000 0    50   ~ 0
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
P 7925 4900
F 0 "#PWR0105" H 7925 4650 50  0001 C CNN
F 1 "GND" H 7930 4727 50  0000 C CNN
F 2 "" H 7925 4900 50  0001 C CNN
F 3 "" H 7925 4900 50  0001 C CNN
	1    7925 4900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0106
U 1 1 5BAD51F5
P 8700 5625
F 0 "#PWR0106" H 8700 5375 50  0001 C CNN
F 1 "GND" H 8705 5452 50  0000 C CNN
F 2 "" H 8700 5625 50  0001 C CNN
F 3 "" H 8700 5625 50  0001 C CNN
	1    8700 5625
	1    0    0    -1  
$EndComp
Text Label 7975 5775 2    50   ~ 0
PWM_OUT
Wire Notes Line
	7525 5525 7525 6200
Wire Wire Line
	6300 2000 6925 2000
Wire Wire Line
	8350 5000 8350 4900
Connection ~ 8350 4900
Wire Wire Line
	8350 4900 7925 4900
Text Label 8450 5100 2    50   ~ 0
PWM_OUT
Text Label 1400 1000 0    50   ~ 0
C0
Text Label 4200 2000 2    50   ~ 0
C0
$EndSCHEMATC
