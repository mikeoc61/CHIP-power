#!/bin/bash
# This program gets the battery info from PMU
# Voltage and current charging/discharging
#
# Nota : temperature can be more than real because of self heating
#######################################################################
# Copyright (c) 2014 by RzBo, Bellesserre, France
#
# Permission is granted to use the source code within this
# file in whole or in part for any use, personal or commercial,
# without restriction or limitation.
#
# No warranties, either explicit or implied, are made as to the
# suitability of this code for any purpose. Use at your own risk.
#######################################################################

# force ADC enable for battery voltage and current
i2cset -y -f 0 0x34 0x82 0xC3

# Output in row format

while [ 1 ]
do 

  echo "PStat Battery Voltage Discharge Charge Percent Temp           Date / Time"

x=1
while [ $x -le 10 ]
do

################################
#read Power status register @00h
POWER_STATUS=$(i2cget -y -f 0 0x34 0x00)

BAT_STATUS=$(($(($POWER_STATUS&0x02))/2))  # divide by 2 is like shifting rigth 1 times

################################
#read Power OPERATING MODE register @01h
POWER_OP_MODE=$(i2cget -y -f 0 0x34 0x01)

CHARG_IND=$(($(($POWER_OP_MODE&0x40))/64))  # divide by 64 is like shifting rigth 6 times

BAT_EXIST=$(($(($POWER_OP_MODE&0x20))/32))  # divide by 32 is like shifting rigth 5 times

################################
#read battery voltage	79h, 78h	0 mV -> 000h,	1.1 mV/bit	FFFh -> 4.5045 V
BAT_VOLT_MSB=$(i2cget -y -f 0 0x34 0x78)
BAT_VOLT_LSB=$(i2cget -y -f 0 0x34 0x79)

BAT_BIN=$(( $(($BAT_VOLT_MSB << 4)) | $(($(($BAT_VOLT_LSB & 0x0F)) )) ))

BAT_VOLT=$(echo "($BAT_BIN*1.1)"|bc)

###################
#read Battery Discharge Current	7Ch, 7Dh	0 mV -> 000h,	0.5 mA/bit	1FFFh -> 1800 mA
#AXP209 datasheet is wrong, discharge current is in registers 7Ch 7Dh
#13 bits
BAT_IDISCHG_MSB=$(i2cget -y -f 0 0x34 0x7C)
BAT_IDISCHG_LSB=$(i2cget -y -f 0 0x34 0x7D)

BAT_IDISCHG_BIN=$(( $(($BAT_IDISCHG_MSB << 5)) | $(($(($BAT_IDISCHG_LSB & 0x1F)) )) ))

BAT_IDISCHG=$(echo "($BAT_IDISCHG_BIN*0.5)"|bc)

###################
#read Battery Charge Current	7Ah, 7Bh	0 mV -> 000h,	0.5 mA/bit	FFFh -> 1800 mA
#AXP209 datasheet is wrong, charge current is in registers 7Ah 7Bh
#(12 bits)
BAT_ICHG_MSB=$(i2cget -y -f 0 0x34 0x7A)
BAT_ICHG_LSB=$(i2cget -y -f 0 0x34 0x7B)

BAT_ICHG_BIN=$(( $(($BAT_ICHG_MSB << 4)) | $(($(($BAT_ICHG_LSB & 0x0F)) )) ))
BAT_ICHG=$(echo "($BAT_ICHG_BIN*0.5)"|bc)

###################
#read internal temperature 	5eh, 5fh	-144.7c -> 000h,	0.1c/bit	FFFh -> 264.8c
TEMP_MSB=$(i2cget -y -f 0 0x34 0x5e)
TEMP_LSB=$(i2cget -y -f 0 0x34 0x5f)

# bash math -- converts hex to decimal so `bc` won't complain later...
# MSB is 8 bits, LSB is lower 4 bits
TEMP_BIN=$(( $(($TEMP_MSB << 4)) | $(($(($TEMP_LSB & 0x0F)) )) ))
TEMP_C=$(echo "($TEMP_BIN*0.1-144.7)"|bc)

###################
# Read Battery charge percentage
BAT_GAUGE_HEX=$(i2cget -y -f 0 0x34 0xb9) # Read AXP209 register B9H

# bash math -- converts hex to decimal so `bc` won't complain later...
# MSB is 8 bits, LSB is lower 4 bits
BAT_GAUGE_DEC=$(($BAT_GAUGE_HEX))  # Convert hex to Dec

  # Output readings in row format
  echo " "$POWER_STATUS " " $BAT_EXIST "  " $BAT_VOLT"mV   " $BAT_IDISCHG"mA    " $BAT_ICHG"mA     "$BAT_GAUGE_DEC"%   "$TEMP_
C"c  "$(date)

  # Increment counter and sleep a while
  x=$(( $x + 1 ))
  sleep 60

 done

done
