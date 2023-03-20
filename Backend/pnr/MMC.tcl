
create_library_set -name max_library -timing "/home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.lib"
create_library_set -name typ_library -timing "/home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"
create_library_set -name min_library -timing "/home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.lib"

create_constraint_mode -name func_constraints -sdc_files {/home/IC/Projects/System/Backend/DFT/sdc/SYS_TOP_func.sdc}
create_constraint_mode -name capture_constraints -sdc_files {/home/IC/Projects/System/Backend/DFT/sdc/SYS_TOP_capture.sdc}
create_constraint_mode -name scan_constraints -sdc_files {/home/IC/Projects/System/Backend/DFT/sdc/SYS_TOP_scan.sdc}

create_rc_corner -name RCcorner -T {25}


create_delay_corner -name min_corner -library_set min_library -rc_corner RCcornercreate_delay_corner -name max_corner -library_set max_library -rc_corner RCcorner

#func
create_analysis_view -name func_setup_analysis_view -delay_corner max_corner -constraint_mode func_constraints
create_analysis_view -name func_hold_analysis_view -delay_corner min_corner -constraint_mode func_constraints

#capture
create_analysis_view -name capture_setup_analysis_view -delay_corner max_corner -constraint_mode capture_constraints
create_analysis_view -name capture_hold_analysis_view -delay_corner min_corner -constraint_mode capture_constraints

#scan
create_analysis_view -name scan_setup_analysis_view -delay_corner max_corner -constraint_mode scan_constraints
create_analysis_view -name scan_hold_analysis_view -delay_corner min_corner -constraint_mode scan_constraints

set_analysis_view -setup {func_setup_analysis_view capture_setup_analysis_view scan_setup_analysis_view} \
                  -hold {func_hold_analysis_view capture_hold_analysis_view scan_hold_analysis_view}
