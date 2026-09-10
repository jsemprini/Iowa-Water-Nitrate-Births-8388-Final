Title: Prenatal Exposure to Compliant Nitrate in Iowa Public Drinking Water (1983–1988)

Author: Jason Semprini, PhD, MPP



Analytic code for a population-based study linking finished-water nitrate measurements from Iowa public water systems to Iowa natality records, estimating the association between first-trimester exposure to drinking-water nitrate below the 10 mg/L federal maximum contaminant level and four adverse birth outcomes: preterm birth, very preterm birth, low birthweight, and very low birthweight.

This repository updates and corrects Semprini (2025), which was retracted in 2026. The principal corrections are the restriction to finished-water samples only, the exclusion of pregnancies exposed to non-compliant nitrate at or above 10 mg/L, a fixed 98-day first-trimester exposure window in place of a 30-day window around estimated conception, and correction for multiple hypothesis testing.

Every file below is published so that each step from raw measurement to reported estimate can be inspected independently. Together they document how the exposure panel was built, how the birth cohort was defined, how the two were linked, and how every number in the manuscript was produced.

Pipeline

The four Python notebooks run in order and hand off to the four Stata do-files.

py1 → py2 → py3 → py4 → analytic_data_1983-1988.csv → Stata1-4

The python notebooks are written for Google Colab with source data on Google Drive; paths are set in constants at the top of each notebook. They are committed with their execution outputs intact, so intermediate counts, diagnostics, and validation results can be read without re-running anything.

Data preparation (Python)

py1_createwater_final.ipynb — Builds the county-quarter nitrate exposure panel. Restricts the CHEEC archive to finished-water samples, assigns sampling coordinates to counties by point-in-polygon with an audited nearest-county fallback, and collapses measurements hierarchically to the county-quarter by taking medians within water-system-day, water-system-month, and water-system-quarter, then across systems (a population-served weighted mean is used instead only if population coverage meets a prespecified threshold). Unmonitored county-quarters are predicted from log1p(nitrate) ~ county FE + year-quarter FE + log1p(spatial nitrate), where the spatial predictor is the inverse-distance-weighted mean of observed concentrations in other counties within 100 km in the same quarter, with the five nearest observed counties used as a fallback. Predictions return to the natural scale by Duan smearing. Nitrate values at or above 10 mg/L are never deleted or truncated at this stage.

The notebook also runs the three leakage-safe validation designs reported in the manuscript — random five-fold cross-validation, a blocked contiguous two-quarter holdout within county, and artificial missingness at 75%, 50%, and 25% retention in well-observed counties — rebuilding the spatial predictor and the smearing factor from training data in every replication. 

py2_createbirth_final.ipynb — Prepares the natality records and defines the cohort. Reconstructs gestational start from the last menstrual period and detailed clinical gestational age using a stated hierarchy, then applies the outcome-independent entry and exit rules: gestational start on or after 1 January 1983, and early enough that a pregnancy continuing to 41 weeks 6 days could still be observed before the natality file ends on 31 December 1988. Restricts to singleton births of 20–41 completed weeks in counties represented in the water panel, and requires the full 98-day first-trimester window to fall inside the panel. All maternal race groups are retained here; the analytic restriction is applied later in Stata. Sample-flow counts are written to birth_sample_counts_T1_v3.csv and the two birth_flow_* files, which document the Figure 1 flow chart.

py3_link_water_birth_final.ipynb — Links each pregnancy to the county-quarter panel by county of maternal residence and exact calendar-day overlap. Because a 98-day window spans two and occasionally three quarters, exposure is the overlap-day-weighted mean rather than a single-quarter or unweighted value. Produces both t1_mean_complete (from the completed panel) and t1_mean_observed (from directly observed county-quarters only), the day-coverage diagnostics (t1_obsdays, t1_impdays, t1_obsfrac, t1_anyimp, t1_allobs) that support the coverage-threshold sensitivity analysis, and the pregnancy-level flags for any overlapping county-quarter containing a finished-water measurement at or above 10 mg/L.

py4_prepare_analysis_final.ipynb — Derives the parity and education indicators and freezes one analysis file carrying birth_id, the model covariates, and every t1_* field. No analytic restrictions are applied here by design, so that all sample selection is visible in one place in Stata. Output is analytic data, the input to all four Stata do-files.

Analysis (Stata)

All four do-files load analytic_data_1983-1988.csv and apply the same sample restrictions before estimation: exclusion of pregnancies with any overlapping finished-water measurement at or above 10 mg/L and with completed or observed first-trimester means at or above 10 mg/L; non-missing exposure and birthweight; births to White mothers; and prenatal care initiated by month 5. The estimation sample is then fixed to e(sample) from the preterm-birth model so that every specification is estimated on identical observations. All models are linear probability models absorbing county × birth-year and birth-year × conception-quarter fixed effects, adjusted for parity, maternal education, infant sex, marital status, and maternal age, with standard errors clustered on county. reghdfe is required; Stata3 additionally requires rwolf2.

Stata1-primary_complete.do — The primary analysis. Constructs the four binary outcomes and the three-level exposure categories (≤0.1 mg/L reference, >0.1 to <5 mg/L, ≥5 mg/L), reports the sample descriptives, and estimates each outcome, reporting average marginal effects with both unadjusted and Šidák-adjusted confidence intervals and p-values, plus a test of equality between the two exposure contrasts. Produces Table 1, Table 2, and Figures 2 and 3.

Stata2-sensitivity_permute.do — Permutation-based inference for the binary ≥5 mg/L contrast, estimated separately for each outcome with permutation clustered on county. Provides a distribution-free check on the parametric p-values in the primary models.

Stata3-sensitivity_RW.do — Romano-Wolf stepdown multiple-testing correction across the four outcomes, run jointly via rwolf2 with 9,999 replications and a fixed seed. Because the four outcomes are measured on the same pregnancies and are nested, very preterm birth within preterm birth, very low birthweight within low birthweight, this procedure controls the family-wise error rate while exploiting the dependence among the test statistics, rather than assuming independence as Bonferroni-type corrections do. Produces Table 3.

Stata4-sensitivity_compare.do — The imputation robustness check. Re-estimates the binary ≥5 mg/L contrast using the completed measure and the observed-only measure in turn, at each of four first-trimester observation-coverage thresholds (≥0, ≥30, ≥60, ≥90 of the 98 days directly observed). This tests whether the reported associations depend on the modelled county-quarter values. Produces Table 4 and Figure 4.

Data availability
The original data, the finished water data, and the final analytic data can be found here: https://doi.org/10.17605/OSF.IO/P39W4

Iowa natality detail files are publicly available from the National Bureau of Economic Research at https://www.nber.org/research/data/vital-statistics-natality-birth-data. 

Citation

Semprini J. Prenatal Exposure to Compliant Nitrate in Iowa Public Drinking Water (1983–1988). 
