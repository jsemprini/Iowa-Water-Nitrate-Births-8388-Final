*set working directory*

clear all

*Load "analytic_data_1983-1988.csv"
			      
****final restrictions****
drop if t1_max_finished_water>=10 & t1_max_finished_water!=.
drop if t1_mean_complete>=10 & t1_mean_complet!=.
drop if t1_mean_observed>=10 & t1_mean_observed!=.

drop if t1_mean_complete==.
drop if t1_mean_observed==.

drop if birthweight_g==.
keep if maternal_race_broad=="White"
keep if prenatal_by5==1


* Primary categorical or binary covariates for all models
global controls  ///
				parity2 parity3plus ///
              meduc_hs meduc_gt_hs ///
               infant_male married

****outcomes
gen lbw=0
replace lbw=1 if birthweight_g<2500

gen ptb=0
replace ptb=1 if gest_age_weeks<37

*******extreme outcomes*******
gen vlbw=0
replace vlbw=1 if birthweight_g<1500

gen vptb=0
replace vptb=1 if gest_age_weeks<32


****create cat*****
gen n_cat=0 if  t1_mean_complete!=.
replace n_cat=1 if t1_mean_complete>.1  & t1_mean_complete!=.
replace n_cat=2 if t1_mean_complete>=5  & t1_mean_complete!=.

reghdfe ptb i.n_cat i.($controls) c.maternal_age , vce(cluster county_fips) absorb(county_fips#birth_year  birth_year#conception_quarter)

*final inclusion step
keep if e(sample)

***summary stats****
summ t1_mean_complete t1_mean_observed
gen diffs = t1_mean_complete - t1_mean_observed
summ diffs, detail
count if abs(diffs) > .000001

sum lbw vlbw ptb vptb 

sum birthweight_g gest_age_weeks

sum t1_mean_complete, det

tab n_cat

sum maternal_age

sum $controls

tab birth_year

estimates clear


***primary regression tests***

qui: reghdfe lbw i.n_cat i.($controls) c.maternal_age , vce(cluster county_fips) absorb(county_fips#birth_year  birth_year#conception_quarter)

test 1.n_cat = 2.n_cat

margins , dydx(n_cat)
margins , dydx(n_cat) mcompare(sidak)


qui: reghdfe ptb i.n_cat i.($controls) c.maternal_age , vce(cluster county_fips) absorb(county_fips#birth_year  birth_year#conception_quarter)

test 1.n_cat = 2.n_cat 

margins , dydx(n_cat)
margins , dydx(n_cat) mcompare(sidak)


qui: reghdfe vlbw i.n_cat i.($controls) c.maternal_age , vce(cluster county_fips) absorb(county_fips#birth_year  birth_year#conception_quarter)

test 1.n_cat = 2.n_cat

margins , dydx(n_cat)
margins , dydx(n_cat) mcompare(sidak)

qui: reghdfe vptb i.n_cat i.($controls) c.maternal_age , vce(cluster county_fips) absorb(county_fips#birth_year  birth_year#conception_quarter)

test 1.n_cat = 2.n_cat

margins , dydx(n_cat)
margins , dydx(n_cat) mcompare(sidak)

