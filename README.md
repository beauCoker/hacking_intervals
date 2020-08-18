# Hacking Intervals

This repository contains the code (R, Python, and MATLAB) used in the paper [A Theory of Statistical Inference to Improve the Robustness of Scientific Results](https://arxiv.org/abs/1804.08646) by Beau Coker, Cynthia Rudin, and Gary King.

There is also [R package](https://github.com/beauCoker/hacking) that accompanies this paper. 


## Recidivism analysis

We use the dataset made available by [ProPublica](https://github.com/propublica/compas-analysis). In particular, we use the files `compas-scores-two-years.csv` and `compas.db`. To reproduce our results, use `Recidivism/Code/1_db2csv/db2csv.Rmd` to transform the raw ProPublica data into .csv files and use `Recidivism/Code/1_preprocessing/preprocessing.Rmd` to proprocess the .csv files for analysis. The code for the new feature analysis is stored in `Recidivism/Code/2_newfeature/Scripts` and the code for the SVM analysis is stored in `Recidivism/Code/2_svm/Scripts`.

Both analyses use the following features:
* `c_charge_degree_F`: Binary indicator if the most recent charge prior to the COMPAS score calculation is a felony.
* `sex_Male`: Binary indicator if the defendant is male.
* `age_screening`: Age in years at the time of the COMPAS score calculation.
* `age_18_20`, `age_21_22`, `age_23_25`, `age_26_45`, and `age_45`: Binary indicators based on
age screening for age groups 18-20, 21-22, 23-25, 26-45, and greater than or equal to 45, respectively. 
* `juvenile_felonies_0`, `juvenile_misdemeanors_0`, and `juvenile_crimes_0`: Binary indicators of whether there is more than one juvenile felony, misdemeanor, or crime, respectively. We use binary
indicators because the counts of each are highly right-skewed.
* `priors 0`, `priors 1`, `priors_2_3`, and `priors_3`: Binary indicators of whether the number of
priors is 0, 1, 2-3, or more than 3, respectively.

## Figures

Here's a guide to reproducing the figures in the paper.

##### Figure 1: Tethered hacking for $k$-NN prediction (illustration)

Created manually, no code available.

##### Figure 2: Tethered hacking for SVM prediction (illustration)

Run `Recidivism/Code/2_svm/Scripts/example.m`.

##### Figure 3: Tethered hacking for average treatment effect 

Run `Linear_regression/fig1_ATE.m`. This script also produces the results for Table 1 (see variables `beta0min` and `beta0max`). 

##### Figure 4: Tethered hacking for individual treatment effect 

Run `Linear_regression/fig2_IndividualTE.m`.

##### Figure 5: Presciptively-constrained hacking for odds ratio

Run these scripts:
* `Recidivism/Code/2_newfeature/Scripts/setup.m`
* `Recidivism/Code/2_newfeature/Scripts/main.m`

##### Figures 6-8: Tethered hacking for SVM prediction (recidivism data)

First run these scripts:
* `Recidivism/Code/2_svm/Scripts/setup.m`
* `Recidivism/Code/2_svm/Scripts/main_decile_score.m`
* `Recidivism/Code/2_svm/Scripts/main_race.m`
* `Recidivism/Code/2_svm/Scripts/main_score3.m`
* `Recidivism/Code/2_svm/Scripts/main_score8.m`

Then create the plots using:
`Recidivism/Code/2_svm/R_plots/recidivism_plots.Rmd`.

##### Figure EC.1: Prescriptively-constrained hacking for matching

Reproduced from Figure 3 in [Morucci et al. 2018](https://arxiv.org/pdf/1812.02227.pdf).

##### Figure EC.2: Tethered hacking for kernel regression

Run `Kernel_regression/Metric Learning for Kernel Regression.ipynb`.

##### Figure EC.3: Tethered hacking for PCA variable selection

Run these scripts:
* `PCA/variable_selection.m`
* `PCA/analyze_results_V_diff.m`

