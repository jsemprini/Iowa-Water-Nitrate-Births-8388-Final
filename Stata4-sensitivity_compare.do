*set working directory*

clear all

*Load "analytic_data_1983-1988.csv"
			   
			   
****final restrictions****
drop if birthweight_g==.
keep if maternal_race_broad=="White"
keep if prenatal_by5==1

drop if t1_mean_complete>=10 & t1_mean_complet!=.
drop if t1_mean_observed>=10 & t1_mean_observed!=.
drop if t1_mean_complete==.
drop if t1_mean_observed==.
drop if t1_max_finished_water>=10


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

keep if e(sample)

*updated binary exposure category*
gen n_five_o=0
replace n_five_o=1 if t1_mean_observed>=5

gen n_five_c=0
replace n_five_c=1 if t1_mean_complete>=5

estimates clear
***sens: compare completed versus observed, across threshold of observed days in first trimester window***

foreach y in ptb vptb lbw vlbw  {
	foreach x in n_five_c n_five_o{
foreach n of numlist 0 30 60 90{
qui: reghdfe `y' i.`x' i.($controls) c.maternal_age if t1_obsdays>=`n' , vce(cluster county_fips) absorb(county_fips#birth_year  birth_year#conception_quarter)

eststo: margins , dydx(`x') post
}
esttab , b(4) ci(4)

estimates clear
} 
}



