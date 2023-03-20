
setCTSMode -specMultiMode true -engine ck -routeClkNet true
clockDesign -genSpecOnly Clock.ctstch
clockDesign -specFile Clock.ctstch -outDir clock_report -fixedInstBeforeCTS
