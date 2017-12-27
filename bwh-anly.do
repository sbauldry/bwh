*** Purpose: Analysis of black-white homicide rates
*** Author: S Bauldry
*** Date: November 13, 2017

*** Set working directory
cd ~/dropbox/research/statistics/bwh/bwh-work

*** Load prepared data
use bwh-data, replace


*** Descriptive statistics
sum hr* if nb >= 20000 & !mi(nb)


*** Estimating correlations and confidence intervals
*** note: ci2 is a user-written command
postutil clear
tempfile PF
postfile PF id n nb es1 lb1 ub1 using `PF', replace

forval i = 10000(5000)30000 {
	local j = `i'/10000
	
	qui sum nb if nb >= `i' & !mi(nb)
	local n = r(N)

	qui ci2 hrw hrb if nb >= `i' & !mi(nb), corr
	local bwcr = r(rho)
	local bwub = r(ub)
	local bwlb = r(lb)
	
	post PF (`j') (`n') (`i') (`bwcr') (`bwub') (`bwlb')
	
	local k = `j' + 3
	qui ci2 hrm hrf if nb >= `i' & !mi(nb), corr
	local mfcr = r(rho)
	local mfub = r(ub)
	local mflb = r(lb)
	
	post PF (`k') (`n') (`i') (`mfcr') (`mfub') (`mflb')
	
	local l = `k' + 3
	qui ci2 hrya hroa if nb >= `i' & !mi(nb), corr
	local yocr = r(rho)
	local youb = r(ub)
	local yolb = r(lb)
	
	post PF (`l') (`n') (`i') (`yocr') (`youb') (`yolb')
}

postclose PF

*** Creating graph of results
preserve
use `PF'

* graphing across all city sizes
graph twoway (rspike ub1 lb1 id) (scatter es1 id, mc(black)), scheme(s1mono) ///
  ytit("correlation") ylab(-0.2(0.2)1, angle(h) grid gstyle(dot)) xtit("")   ///
  xlab(1 "10K" 1.5 "15K" 2 `""20K" "{bf:White-Black}"' 2.5 "25K" 3 "30K"     ///
       4 "10K" 4.5 "15K" 5 `""20K" "{bf:Male-Female}"' 5.5 "25K" 6 "30K"     ///
	   7 "10K" 7.5 "15K" 8 `""20K" "{bf:YA-Other}"' 8.5 "25K" 9 "30K",       ///
	   grid gstyle(dot)) legend(off)                                         ///
  tit("Homicide Rate Correlations across Range of Minimum Black Population Sizes", ///
  size(medsmall)) note("Estimates with 95% confidence intervals. YA = young adult.")
graph export ~/desktop/bwh-fig1a.pdf, replace

* graphing just 20K+
keep if id == 2 | id == 5 | id == 8
recode id (2 = 1) (5 = 2) (8 = 3)
graph twoway (rspike ub1 lb1 id) (scatter es1 id, mc(black)), scheme(s1mono) ///
  ytit("correlation") ylab(-0.2(0.2)1, angle(h) grid gstyle(dot)) xtit("")   ///
  xlab(0 " " 1 "White-Black" 2 "Male-Female" 3 "YA-Other" 4 " ", grid        ///
  gstyle(dot)) legend(off) tit("Homicide Rates Correlations")                ///
  saving(g1, replace)
restore


*** Generating scatterplots

* Unstandardized black-white
graph twoway scatter hrw hrb [w = np] if nb >= 20000 & !mi(nb),  ///
  ylab(0(2)10, angle(h) grid gstyle(dot)) msymbol(circle_hollow) ///
  xlab( , grid gstyle(dot)) text(5.2 57.5 "NOLA", size(small))   ///
  tit("Black and White") saving(g2, replace) scheme(s1mono) 
  
* Unstandardized male-female
graph twoway scatter hrf hrm [w = np] if nb >= 20000 & !mi(nb),  ///
  ylab(0(2)10, angle(h) grid gstyle(dot)) msymbol(circle_hollow) ///
  xlab( , grid gstyle(dot)) text(5 39 "NOLA", size(small))       ///
  tit("Male and Female") saving(g3, replace) scheme(s1mono)         
  
* Unstandardized young adult-other
graph twoway scatter hroa hrya [w = np] if nb >= 20000 & !mi(nb),      ///
  ylab(0(2)10, angle(h) grid gstyle(dot)) msymbol(circle_hollow)       ///
  xlab( , grid gstyle(dot)) text(8.8 56.8 "NOLA", size(small))         ///
  tit("Young Adult and Other Ages") saving(g4, replace) scheme(s1mono)          

* Combining graphs
graph combine g2.gph g3.gph g4.gph g1.gph, scheme(s1mono) iscale(0.5)
graph export ~/desktop/bwh-fig1.pdf, replace


*** Correlations
corr hrw hrb if nb >= 20000 & !mi(nb)
corr hrm hrf if nb >= 20000 & !mi(nb)
corr hrya hroa if nb >= 20000 & !mi(nb)


*** Partial correlation
gen pm = nm/np
gen pb = nb/np
gen py = nya/np
pcorr hrw hrb pm pb py if nb >= 20000 & !mi(nb)
pcorr hrm hrf pm pb py if nb >= 20000 & !mi(nb)
pcorr hrya hroa pm pb py if nb >= 20000 & !mi(nb)


*** Identifying MSAs with high/low black/white homicide rates
sum hrb if nb > 20000 & !mi(nb), detail
local hrb_p75 = r(p75)
local hrb_p25 = r(p25)

sum hrw if nb > 20000 & !mi(nb), detail
local hrw_p75 = r(p75)
local hrw_p25 = r(p25)

list name nb hrb hrw if hrb > `hrb_p75' & hrw < `hrw_p25' & !mi(nb) & nb > 20000
list name nb hrb hrw if hrw > `hrw_p75' & hrb < `hrb_p25' & !mi(nb) & nb > 20000
list name nb hrb hrw if hrw > `hrw_p75' & hrb > `hrb_p75' & !mi(nb) & nb > 20000


*** South and homicide
regress hro south if nb > 20000 & !mi(nb)
regress hrb south if nb > 20000 & !mi(nb)
regress hrw south if nb > 20000 & !mi(nb) 

gsort -hrb
list name nb hrb if nb > 25000 & !mi(hrb) & hrb > 35, clean noobs
