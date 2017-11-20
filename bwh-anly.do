*** Purpose: Analysis of black-white homicide rates
*** Author: S Bauldry
*** Date: November 13, 2017

*** Set working directory
cd ~/dropbox/research/statistics/bwh/bwh-work

*** Load prepared data
use bwh-data, replace


*** Estimating correlations and confidence intervals
postutil clear
tempfile PF
postfile PF id n nb es1 lb1 ub1 using `PF', replace

forval i = 10000(5000)30000 {
	local j = `i'/10000
	
	qui sum nb if nb > `i'
	local n = r(N)

	qui ci2 hrw hrb if nb > `i', corr
	local bwcr = r(rho)
	local bwub = r(ub)
	local bwlb = r(lb)
	
	post PF (`j') (`n') (`i') (`bwcr') (`bwub') (`bwlb')
	
	local k = `j' + 3
	qui ci2 hrm hrf if nb > `i', corr
	local mfcr = r(rho)
	local mfub = r(ub)
	local mflb = r(lb)
	
	post PF (`k') (`n') (`i') (`mfcr') (`mfub') (`mflb')
}

postclose PF

*** Creating graph of results
preserve
use `PF'

graph twoway (rspike ub1 lb1 id) (scatter es1 id, mc(black)), scheme(s1mono) ///
  ytit("correlation") ylab(-0.2(0.2)1, angle(h) grid gstyle(dot)) xtit("")   ///
  xlab(1 "10K" 1.5 "15K" 2 `""20K" "{bf:White-Black}"' 2.5 "25K" 3 "30K"     ///
       4 "10K" 4.5 "15K" 5 `""20K" "{bf:Male-Female}"' 5.5 "25K" 6 "30K",    ///
	   grid gstyle(dot)) legend(off)                                         ///
  tit("Homicide Rate Correlations across Range of Black Population Sizes",   ///
  size(medium)) note("Estimates with 95% confidence intervals.")
graph export ~/desktop/bwh-fig.pdf, replace
restore
