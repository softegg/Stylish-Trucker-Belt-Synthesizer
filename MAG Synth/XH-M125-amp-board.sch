EESchema Schematic File Version 4
LIBS:Stylish-Belt-Synth - Full-cache
EELAYER 28 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 3
Title "MX-M125 XPT8871 Amplifier Board"
Date "2018-03-10"
Rev "1"
Comp "SoftEgg"
Comment1 "V0.1 T.B. Trzepacz 2018/2/19"
Comment2 "V0.2 T.B. Trzepacz 2018/10/14"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L SoftEggKicadLib:XPT8871 U2
U 1 1 5A8BB8FB
P 6375 3575
F 0 "U2" H 6325 4025 60  0000 C CNN
F 1 "XPT8871" H 6375 3775 60  0000 C CNN
F 2 "SMD_Packages:SOIC-8-N" H 6375 3475 60  0001 C CNN
F 3 "" H 6375 3475 60  0001 C CNN
	1    6375 3575
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small CA2
U 1 1 5A8BBD7D
P 5625 4275
F 0 "CA2" V 5675 4125 50  0000 L CNN
F 1 "1μF" V 5675 4325 50  0000 L CNN
F 2 "SoftEggKiCAD:C_Disc_D5.0mm_W2.5mm_P5.00mm+SMD" H 5625 4275 50  0001 C CNN
F 3 "" H 5625 4275 50  0001 C CNN
	1    5625 4275
	0    1    1    0   
$EndComp
$Comp
L device:C_Small CA1
U 1 1 5A8BBFCE
P 5625 4125
F 0 "CA1" V 5550 3975 50  0000 L CNN
F 1 "470μF" V 5550 4175 50  0000 L CNN
F 2 "SoftEggKiCAD:C_Disc_D5.0mm_W2.5mm_P5.00mm+SMD" H 5625 4125 50  0001 C CNN
F 3 "" H 5625 4125 50  0001 C CNN
	1    5625 4125
	0    1    1    0   
$EndComp
Wire Wire Line
	6575 4175 6575 4475
Wire Wire Line
	6275 4175 6275 4225
Wire Wire Line
	5725 4225 6275 4225
$Comp
L device:R R3
U 1 1 5A8BD036
P 5575 3275
F 0 "R3" V 5475 3275 50  0000 C CNN
F 1 "100Ω" V 5575 3275 50  0000 C CNN
F 2 "SoftEggKiCAD:R_Axial_DIN0204_L3.6mm_D1.6mm_P7.62mm_Horizontal+SMD804" V 5505 3275 50  0001 C CNN
F 3 "" H 5575 3275 50  0001 C CNN
	1    5575 3275
	0    1    1    0   
$EndComp
$Comp
L device:C_Small CA4
U 1 1 5A8BD103
P 5250 3275
F 0 "CA4" V 5150 3225 50  0000 L CNN
F 1 "0.39μF" V 5350 3175 50  0000 L CNN
F 2 "SoftEggKiCAD:C_Disc_D5.0mm_W2.5mm_P5.00mm+SMD" H 5250 3275 50  0001 C CNN
F 3 "" H 5250 3275 50  0001 C CNN
	1    5250 3275
	0    1    1    0   
$EndComp
Wire Wire Line
	5775 3275 5725 3275
Wire Wire Line
	5425 3275 5350 3275
$Comp
L device:C_Small CA3
U 1 1 5A8BD59A
P 5625 3675
F 0 "CA3" V 5725 3625 50  0000 L CNN
F 1 "1μF" V 5525 3625 50  0000 L CNN
F 2 "Capacitors_ThroughHole:CP_Radial_Tantal_D4.5mm_P2.50mm" H 5625 3675 50  0001 C CNN
F 3 "" H 5625 3675 50  0001 C CNN
	1    5625 3675
	0    1    1    0   
$EndComp
Wire Wire Line
	5050 3675 5525 3675
Wire Notes Line
	5000 4550 6975 4550
Wire Notes Line
	6975 4550 6975 2975
Wire Notes Line
	6975 2975 5000 2975
Wire Notes Line
	5000 2975 5000 4550
Wire Wire Line
	5775 3875 5050 3875
Connection ~ 5050 3875
Wire Wire Line
	5775 3675 5725 3675
Wire Wire Line
	5525 4125 5525 4200
Wire Wire Line
	5725 4125 5725 4225
Connection ~ 5725 4225
Wire Wire Line
	5525 4200 5050 4200
Connection ~ 5525 4200
Text Notes 5150 3075 0    60   ~ 0
Amplifier Board
Wire Wire Line
	5050 3675 5050 3875
Wire Wire Line
	5050 3875 5050 4200
Wire Wire Line
	5725 4225 5725 4275
Wire Wire Line
	5525 4200 5525 4275
$Comp
L conn:Conn_01x06 JA1
U 1 1 5AA56D62
P 3575 3675
F 0 "JA1" H 3495 4092 50  0000 C CNN
F 1 "Conn_01x06" H 3495 4001 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x06_Pitch2.54mm" H 3575 3675 50  0001 C CNN
F 3 "~" H 3575 3675 50  0001 C CNN
	1    3575 3675
	-1   0    0    -1  
$EndComp
Wire Wire Line
	3775 3475 4600 3475
Wire Wire Line
	4600 3475 4600 4625
Wire Wire Line
	4600 4625 6275 4625
Wire Wire Line
	6275 4625 6275 4225
Connection ~ 6275 4225
Wire Wire Line
	3775 3575 3900 3575
Wire Wire Line
	3900 3575 3900 3675
Wire Wire Line
	3900 3675 3775 3675
Wire Wire Line
	3900 3575 5050 3575
Wire Wire Line
	5050 3575 5050 3675
Connection ~ 3900 3575
Connection ~ 5050 3675
Wire Wire Line
	3775 3775 4850 3775
Wire Wire Line
	4850 3775 4850 3275
Wire Wire Line
	4850 3275 5150 3275
Wire Wire Line
	3775 3875 4525 3875
Wire Wire Line
	4525 3875 4525 4775
Wire Wire Line
	4525 4775 7275 4775
Wire Wire Line
	7275 4775 7275 3475
Wire Wire Line
	7275 3475 6975 3475
Wire Wire Line
	6975 3675 7600 3675
Wire Wire Line
	7600 3675 7600 4950
Wire Wire Line
	7600 4950 4200 4950
Wire Wire Line
	4200 4950 4200 3975
Wire Wire Line
	4200 3975 3775 3975
Wire Wire Line
	5050 4200 5050 4475
Wire Wire Line
	5050 4475 6575 4475
Connection ~ 5050 4200
Text Label 3900 3475 0    50   ~ 0
VCC
Text Label 3900 3575 0    50   ~ 0
GND
Text Label 3900 3675 0    50   ~ 0
GND
Text Label 3900 3775 0    50   ~ 0
VIN
Text Label 3900 3875 0    50   ~ 0
VO2
Text Label 3900 3975 0    50   ~ 0
VO1
Wire Wire Line
	5775 3475 5050 3475
Wire Wire Line
	5050 3475 5050 3575
Connection ~ 5050 3575
Text HLabel 3475 3475 0    50   Input ~ 0
VCC
Text HLabel 3475 3575 0    50   Input ~ 0
GND
Text HLabel 3475 3675 0    50   Input ~ 0
IN-
Text HLabel 3475 3775 0    50   Input ~ 0
IN+
Text HLabel 3475 3875 0    50   Input ~ 0
OUT-
Text HLabel 3475 3975 0    50   Input ~ 0
OUT+
Wire Wire Line
	3475 3475 3775 3475
Connection ~ 3775 3475
Wire Wire Line
	3475 3575 3775 3575
Connection ~ 3775 3575
Wire Wire Line
	3475 3675 3775 3675
Connection ~ 3775 3675
Wire Wire Line
	3475 3775 3775 3775
Connection ~ 3775 3775
Wire Wire Line
	3475 3875 3775 3875
Connection ~ 3775 3875
Wire Wire Line
	3475 3975 3775 3975
Connection ~ 3775 3975
$EndSCHEMATC
