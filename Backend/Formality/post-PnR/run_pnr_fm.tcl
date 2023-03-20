
mkdir -p logs
mkdir -p reports

# Invoke Formality
fm_shell -f pnr_fm_script.tcl | tee logs/pnr_fm_log.log
