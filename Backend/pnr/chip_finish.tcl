
set top_cell SYS_TOP

# Add Filler Cells
set filler_cell_list {FILL1M FILL2M FILL4M FILL8M FILL16M FILL32M FILL64M}
addFiller -cell $filler_cell_list -prefix FILLER -markFixed

# Generate Post-PNR Gate Level Netlist
saveNetlist export/${top_cell}.v 

# Generate Post-PNR Gate Level Netlist with PG Pins
saveNetlist export/${top_cell}_pg.v -includePowerGround

# Generate SDF File
delayCal -sdf export/${top_cell}.sdf -version 3.0

#report area
report_area > report/area.rpt

#report power
report_power -outfile report/power.rpt

# Generate GDS File
streamOut export/${top_cell}.gds -mapFile gds2InLayer.map -libName DesignLib -stripes 1 -units 2000 -mode ALL
