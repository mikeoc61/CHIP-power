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
#
# Modified to send email when crossing battery charge threshold by Michael O'Connor
#
#######################################################################

# force ADC enable for battery voltage and current
i2cset -y -f 0 0x34 0x82 0xC3

###################
#read fuel gauge B9h
BAT_GAUGE_HEX=$(i2cget -y -f 0 0x34 0xb9)

# bash math -- converts hex to decimal so `bc` won't complain later...
# MSB is 8 bits, LSB is lower 4 bits
BAT_GAUGE_DEC=$(($BAT_GAUGE_HEX))

WARNING_THRESHOLD=20

if [ $BAT_GAUGE_DEC -ge $WARNING_THRESHOLD ]; then
	echo "CHIP battery percentage is: $BAT_GAUGE_DEC"
	exit 1
else
	echo "WARNING: CHIP Battery percentage is @ $BAT_GAUGE_DEC"
        echo "CHIP Battery charge @ $BAT_GAUGE_DEC" | mail -s "CHIP Battery needs to be charged" gmikeoc@gmail.com
fi

