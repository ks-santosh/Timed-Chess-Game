
# Requre quartus project
package require ::quartus::project

# Set pin locations for LCD on GPIO 0
set_location_assignment PIN_AJ17 -to LT24Data[0]
set_location_assignment PIN_AJ19 -to LT24Data[1]
set_location_assignment PIN_AK19 -to LT24Data[2]
set_location_assignment PIN_AK18 -to LT24Data[3]
set_location_assignment PIN_AE16 -to LT24Data[4]
set_location_assignment PIN_AF16 -to LT24Data[5]
set_location_assignment PIN_AG17 -to LT24Data[6]
set_location_assignment PIN_AA18 -to LT24Data[7]
set_location_assignment PIN_AA19 -to LT24Data[8]
set_location_assignment PIN_AE17 -to LT24Data[9]
set_location_assignment PIN_AC20 -to LT24Data[10]
set_location_assignment PIN_AH19 -to LT24Data[11]
set_location_assignment PIN_AJ20 -to LT24Data[12]
set_location_assignment PIN_AH20 -to LT24Data[13]
set_location_assignment PIN_AK21 -to LT24Data[14]
set_location_assignment PIN_AD19 -to LT24Data[15]
set_location_assignment PIN_AG20 -to LT24Reset_n
set_location_assignment PIN_AG16 -to LT24RS
set_location_assignment PIN_AD20 -to LT24CS_n
set_location_assignment PIN_AH18 -to LT24Rd_n
set_location_assignment PIN_AH17 -to LT24Wr_n
set_location_assignment PIN_AJ21 -to LT24LCDOn

# Set pin location for Clock
set_location_assignment PIN_AA16 -to clock

# Set pin location for globalReset SW[9]
set_location_assignment PIN_AE12 -to globalReset

# Set pin location for resetApp
set_location_assignment PIN_V16 -to resetApp

# Set pin location for PlaySwitch SW[0]
set_location_assignment PIN_AB12 -to PlaySwitch

# Set pin location for LockSwitch SW[1]
set_location_assignment PIN_AC12 -to LockSwitch

# Set pin location for chess move input keys
set_location_assignment PIN_Y16 -to KeyLeft
set_location_assignment PIN_W15 -to KeyDown
set_location_assignment PIN_AA15 -to KeyUp
set_location_assignment PIN_AA14 -to KeyRight

# Set pin location for TimerSwitch SW[2]
set_location_assignment PIN_AF9 -to TimerSwitch

# Set seven segment displays for chess timer for White Player
set_location_assignment PIN_AE26 -to WhiteClockUnitsSec[0]
set_location_assignment PIN_AE27 -to WhiteClockUnitsSec[1]
set_location_assignment PIN_AE28 -to WhiteClockUnitsSec[2]
set_location_assignment PIN_AG27 -to WhiteClockUnitsSec[3]
set_location_assignment PIN_AF28 -to WhiteClockUnitsSec[4]
set_location_assignment PIN_AG28 -to WhiteClockUnitsSec[5]
set_location_assignment PIN_AH28 -to WhiteClockUnitsSec[6]

set_location_assignment PIN_AJ29 -to WhiteClockTensSec[0]
set_location_assignment PIN_AH29 -to WhiteClockTensSec[1]
set_location_assignment PIN_AH30 -to WhiteClockTensSec[2]
set_location_assignment PIN_AG30 -to WhiteClockTensSec[3]
set_location_assignment PIN_AF29 -to WhiteClockTensSec[4]
set_location_assignment PIN_AF30 -to WhiteClockTensSec[5]
set_location_assignment PIN_AD27 -to WhiteClockTensSec[6]
	
set_location_assignment PIN_AB23 -to WhiteClockMins[0]
set_location_assignment PIN_AE29 -to WhiteClockMins[1]
set_location_assignment PIN_AD29 -to WhiteClockMins[2]
set_location_assignment PIN_AC28 -to WhiteClockMins[3]
set_location_assignment PIN_AD30 -to WhiteClockMins[4]
set_location_assignment PIN_AC29 -to WhiteClockMins[5]
set_location_assignment PIN_AC30 -to WhiteClockMins[6]

# Set seven segment displays for chess timer for Black Player
set_location_assignment PIN_AD26 -to BlackClockUnitsSec[0]
set_location_assignment PIN_AC27 -to BlackClockUnitsSec[1]
set_location_assignment PIN_AD25 -to BlackClockUnitsSec[2]
set_location_assignment PIN_AC25 -to BlackClockUnitsSec[3]
set_location_assignment PIN_AB28 -to BlackClockUnitsSec[4]
set_location_assignment PIN_AB25 -to BlackClockUnitsSec[5]
set_location_assignment PIN_AB22 -to BlackClockUnitsSec[6]

set_location_assignment PIN_AA24 -to BlackClockTensSec[0]
set_location_assignment PIN_Y23 -to BlackClockTensSec[1]
set_location_assignment PIN_Y24 -to BlackClockTensSec[2]
set_location_assignment PIN_W22 -to BlackClockTensSec[3]
set_location_assignment PIN_W24 -to BlackClockTensSec[4]
set_location_assignment PIN_V23 -to BlackClockTensSec[5]
set_location_assignment PIN_W25 -to BlackClockTensSec[6]
	
set_location_assignment PIN_V25 -to BlackClockMins[0]
set_location_assignment PIN_AA28 -to BlackClockMins[1]
set_location_assignment PIN_Y27 -to BlackClockMins[2]
set_location_assignment PIN_AB27 -to BlackClockMins[3]
set_location_assignment PIN_AB26 -to BlackClockMins[4]
set_location_assignment PIN_AA26 -to BlackClockMins[5]
set_location_assignment PIN_AA25 -to BlackClockMins[6]

# Commit assignments
export_assignments
