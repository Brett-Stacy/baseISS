paper_scenario_1.1 - ISS full to compare to assessment. expanded exactly like assessment.
paper_scenario_1.2 - Same as 1.1 except with updated package functionality as at scenario 21.1.
paper_scenario_1.3 - Same as 1.2 except with updated working minimum_sample_size for expansion.
paper_scenario_1.4 - Same as 1.3 except with minimum_sample size effecting nhls etc. and save data frame functionality to facilitate possible samples/haul plot for paper (version as at scenario 25.1)

paper_scenario_2.1 - Same as 1.1 except NULL expansion.
paper_scenario_2.2 - Same as 2.1 except with new version (as at scenario 25.1) and 500 iters
paper_scenario_3.1 - Same as 1.1 except NULL expand by sampling strata.
paper_scenario_3.2 - Same as 1.4 except NULL expand by sampling strata (like 3.1 but with new version)

paper_scenario_4.1 - Same as 1.1 except NULL expansion and NULL expand by sampling strata.
paper_scenario_4.2 - Same as 4.1 except with new version (as at scenario 25.1) and 500 iters
paper_scenario_5.1 - Same as 1.1 except NULL expansion and NULL expand by sampling strata and NULL boot.trip and NULL boot.haul.
paper_scenario_5.2 - Same as 5.1 except with new version (as at scenario 25.1) and 500 iters
paper_scenario_6.1 - Same as 5.1 except ADD back expansion. (no expand by sampling strata or boot)
paper_scenario_7.1 - Same as 5.1 except ADD back expansion and ADD back expand by sampling strata. (no boot)
paper_scenario_8.1 - Same as 5.1 except ADD back expansion and ADD back boot. (no expand by sampling strata)
paper_scenario_9.1 - Same as 1.1 except NULL expansion and NULL expand by sampling strata and NULL boot.trip. (only boot.length and boot.haul)
paper_scenario_9.2 - Same as 9.1 except with new version (as at scenario 25.1) and 500 iters
paper_scenario_10.1 - Same as 1.1 except NULL boot.trip and NULL boot.haul.
paper_scenario_11.1 - Same as 1.1 except NULL boot.trip.
paper_scenario_2.1.1 - 3x3 Grid. 10, 20, 30 length samples per haul X none, haul_only, haul_YAGM weighting factors. YES sampling strata expansion
paper_scenario_2.1.2 - Same as 2.1.1 except with new version (as at scenario 25.1) and 500 iters
paper_scenario_2.2.1 - 3x3 Grid. 10, 20, 30 length samples per haul X none, haul_only, haul_YAGM weighting factors. NO sampling strata expansion
paper_scenario_12.1 - Same as 4.1 except cut trips in half.
paper_scenario_13.1 - Same as 4.1 except cut hauls in half.
paper_scenario_14.1 - Same as 1.1 except cut trips in half.
paper_scenario_15.1 - Same as 1.1 except cut hauls in half.
paper_scenario_16.1 - Same as 1.1 except 1.5x trips.
paper_scenario_17.1 - Same as 1.1 except 1.5x hauls.
paper_scenario_18.1 - 7x2 Grid. 25%, 50%, ..., 200% Trip/Haul
paper_scenario_18.2 - Same as 18.1 except with new version (as at scenario 25.1) and 200 iters
paper_scenario_18.3 - Same as 18.2 except 500 iters and run with TAS computer.
paper_scenario_19.1 - 2x3 Grid. 50%, 150% Trip x none, haul_only, haul_YAGM weighting factors. YES sampling strata expansion.
paper_scenario_20.1 - 2x3 Grid. 50%, 150% Haul x none, haul_only, haul_YAGM weighting factors. YES sampling strata expansion.
paper_scenario_21.1 - 8 Vector of alternative length samples per haul: 1, 5, 10, 15, 20, 25, 30, 35. YES sampling strata expansion.
paper_scenario_22.1 - 8x3 Grid. Same as 2.1.1 except more Sample lengths
paper_scenario_22.2 - Same as 22.1 except with new version (as at scenario 25.1) and 500 iters
paper_scenario_23.1 - 7x8 Grid. Trip x samples.
paper_scenario_23.2 - Same as 23.1 except with new version (as at scenario 25.1) and 500 iters
paper_scenario_24.1 - 7x8 Grid. Haul x samples.
paper_scenario_24.2 - Same as 24.1 except with new version (as at scenario 25.1) and 200 iters
paper_scenario_24.3 - Same as 24.2 except 500 iters and only scenarios c(0.50, 0.75, 1.25)
paper_scenario_25.1 - 6x8 Grid. Haul/Trip x samples. .5/.5, .5/.75, .75/.5, .75/.75, 1.25/.5, 1.25/.75
paper_scenario_25.2.TAS - Same as 25.1 except with new version (as at scenario 25.1) and 500 iters. Run on TAS computer.
paper_scenario_25.3.TAS - Same as 25.2.TAS except 500 iters and only the scenarios used in the paper.

AFTER SUP MEETING DECIDING W/OUT REPLACEMENT, AND MIN ONLY, AND 20 AND UNDER
paper_scenario_26.1 - Same as 1.4 (base) except min(20, # samples) with replacement
paper_scenario_27.1 - Same as 26.1 except without replacement
paper_scenario_28.1 - Same as 27.1 except only for hauls
paper_scenario_29.1 - Same as 18.3 except reductions to 0.1:0.9 1977:2023. base ISSB otherwise.
paper_scenario_30.1 - Same as 2.1.2 except no change to sampling rate
paper_scenario_31.1 - Same as 27.1 except for 1, 5, 10, 15, 20 sampling rate and w/ & w/o port samples - like 28.1
paper_scenario_32.1 - Same as 31.1 except w/ haul only and only ==20
paper_scenario_33.1 - Same as 29.1 except with replace = FALSE

paper_scenario_34.1 - Same as 1.4 (base) except no port samples
paper_scenario_35.1 - Same as 31.1 except reduce only port samples - I DON'T KNOW IF THIS IS POSSIBLE BECAUSE I WOULD HAVE TO CHANGE THE CODE TO CONDITION ON CHANGING SAMPLE SIZE ONLY WHEN PORT JOINS ARE SELECTED IN THE BOOTSTRAPPING.
paper_scenario_36.1 - Same as 31.1 except only include port samples and run a non-reduction scenario. Does ISSB change much when port samples reduced? - NOT WORKING BECAUE OF YEAR PROBLEM WHEN TRYING TO PLOT RESULTS. BACKBURNER FOR NOW.

INTENTION: BOOT SAMPLING UNITS INDIVIDUALLY
paper_scenario_37.1 - Same as 1.4 except yes expansion, no SS, yes boot length, no other boot
paper_scenario_37.2 - Same as 37.1 except boot haul instead of length - worked
paper_scenario_37.3 - Same as 37.1 except boot trips instead of length or hauls - worked

INTENTION: ADJUST EXPANSION AND TRIPS OR HAULS
paper_scenario_38.1 - Same as 22.1 except with the new length subsample routine.
paper_scenario_38.2 - Same as 38.1 except including a case for each expansion complexity without sample changes
paper_scenario_39.1 - Same as 23.2 except with the new length subsample routine. TRIP
paper_scenario_39.2 - Same as 39.1 except replace=FALSE.
paper_scenario_39.3 - PROBLEM: trip at 75% + replace=FALSE is giving higher iss than 31.1 at 100% for some reason. this scenario runs the code at .9 and 1.0 to test if they are also higher. results: still higher for 1.0 than 31.1! the only difference is replace=false here. mayby thats messing things up.
paper_scenario_39.4 - PROBLEM try replace=true. This solved it. So run a replace=FALSE at 1.0 trips to compare all trips to.
paper_scenario_39.5 - Same as 39.2 except only for trip proportion 1.0. I will compare the others in 39.2 to this because of of the problems identified.
paper_scenario_39.6 - Same as 39.1 making sure replace=TRUE and with 1.0 case. ran on MAC.
paper_scenario_40.1 - Same as 24.3 except with the new length subsample routine.replace=FALSE for haul resample. HAUL
paper_scenario_40.2 - Same as 40.1 except with replace=TRUE to complement 39.6 for Trips.

SCRAP SAMPLING STRATA WEIGHTING FOR ALL SCENARIOS
paper_scenario_1.5 - Same as 1.4 except no SS weighting.
paper_scenario_41.1 - Same as 1.5 except only boot length (same as 5.2) and no SS.
paper_scenario_42.1 - Same as 1.5 except only boot length and boot.haul (same as 9.2) and no SS.
paper_scenario_43.1 - Same as 1.5 except only boot length and boot.haul and boot.trip (same as 4.2) and no SS.
paper_scenario_44.1 - Same as 30.1 except no SS. Expansion complexity
paper_scenario_45.1 - Same as 33.1 except no SS. Trip & Haul decrease 0.1-0.9
paper_scenario_46.1 - Same as 38.2 except no SS. Expansion complexity vs Samples. replace==FALSE, except for 999 case. may need to change this!
paper_scenario_47.1 - Same as 31.1 except no SS. Reduce samples: min, w/o replacement, w/ w/o port samples. NEED TO RUN.
paper_scenario_48.1 - Same as 45.1 except 1.0 only and replace=FALSE to get 45.1 plots to be right.


paper_scenario_39.7 - Same as 39.6 except no SS weighting. Trips x samples. Replace=TRUE. Ran on MAC
paper_scenario_39.8 - Same as 39.7 except replace=FALSE
paper_scenario_40.3 - Same as 40.2 escept no SS weighting. Hauls x samples. Replace=TRUE. Ran on TAS
paper_scenario_40.4 - Same as 40.3 except replace=FALSE. TAS
paper_scenario_49.1 - Same as 25.3 except no SS weighting. Trips/Hauls x samples. Replace = TRUE.
paper_scenario_50.1 - Same as 49.1 except replace=FALSE
























