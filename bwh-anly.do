*** Purpose: Analysis of black-white homicide rates
*** Author: S Bauldry
*** Date: November 13, 2017

*** Set working directory
cd ~/dropbox/research/statistics/bwh/bwh-work

*** Load prepared data
use bwh-data, replace


*** Descriptive statistics
sum hr* if nb > 20000 & !mi(hrb)


*** Estimating correlations and confidence intervals
*** note: ci2 is a user-written command
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
	
	local l = `k' + 3
	qui ci2 hrya hroa if nb > `i', corr
	local yocr = r(rho)
	local youb = r(ub)
	local yolb = r(lb)
	
	post PF (`l') (`n') (`i') (`yocr') (`youb') (`yolb')
}

postclose PF

*** Creating graph of results
preserve
use `PF'

graph twoway (rspike ub1 lb1 id) (scatter es1 id, mc(black)), scheme(s1mono) ///
  ytit("correlation") ylab(-0.2(0.2)1, angle(h) grid gstyle(dot)) xtit("")   ///
  xlab(1 "10K" 1.5 "15K" 2 `""20K" "{bf:White-Black}"' 2.5 "25K" 3 "30K"     ///
       4 "10K" 4.5 "15K" 5 `""20K" "{bf:Male-Female}"' 5.5 "25K" 6 "30K"     ///
	   7 "10K" 7.5 "15K" 8 `""20K" "{bf:YA-Other}"' 8.5 "25K" 9 "30K",       ///
	   grid gstyle(dot)) legend(off)                                         ///
  tit("Homicide Rate Correlations across Range of Minimum Black Population Sizes", ///
  size(medsmall)) note("Estimates with 95% confidence intervals. YA = young adult.")
graph export ~/desktop/bwh-fig1.pdf, replace
restore


*** Generating scatterplots

* Unstandardized black-white
graph twoway scatter hrw hrb [w = np] if nb > 25000, scheme(s1mono) ///
  ylab(0(2)10, angle(h) grid gstyle(dot)) msymbol(circle_hollow)    ///
  xlab( , grid gstyle(dot)) text(5.2 57.3 "NOLA")                   ///
  tit("Unstandardized Black and White Homicide Rates")              ///
  note("MSAs with at least 25,000 blacks. Weighted by MSA Size.")         
graph export ~/desktop/bwh-fig2.pdf, replace
  
* Unstandardized male-female
graph twoway scatter hrf hrm [w = np] if nb > 25000, scheme(s1mono) ///
  ylab( , angle(h) grid gstyle(dot)) msymbol(circle_hollow)         ///
  xlab( , grid gstyle(dot)) text(5 39 "NOLA")                       ///
  tit("Unstandardized Male and Female Homicide Rates")              ///
  note("MSAs with at least 25,000 blacks. Weighted by MSA Size.")         
graph export ~/desktop/bwh-fig3.pdf, replace
  
* Unstandardized young adult-other
graph twoway scatter hroa hrya [w = np] if nb > 25000, scheme(s1mono) ///
  ylab( , angle(h) grid gstyle(dot)) msymbol(circle_hollow)           ///
  xlab( , grid gstyle(dot)) text(8.8 57.2 "NOLA")                     ///
  tit("Unstandardized Young Adult and Other Ages Homicide Rates")     ///
  note("MSAs with at least 25,000 blacks. Weighted by MSA Size.")           
graph export ~/desktop/bwh-fig4.pdf, replace


* Standardized black-white
egen shrb = std(hrb)
egen shrw = std(hrw)
gen lbp = (nb > 10000 & nb < 25000)

graph twoway (scatter shrw shrb if nb > 25000, msymbol(circle_hollow) ) ///
  (lfit shrw shrb if nb > 25000, lc(black)), scheme(s1mono) legend(off) ///
  ylab( , angle(h) grid gstyle(dot)) xlab( , grid gstyle(dot))          ///
  tit("Standardized Black and White Homicide Rates")                    ///
  note("MSAs with at least 25,000 blacks.")                             ///
  xtit("standardized black homicide rate")                              ///
  ytit("standardized white homicide rate")
graph export ~/desktop/bwh-fig5.pdf, replace

graph twoway (scatter shrw shrb if nb > 25000, msymbol(circle_hollow) )   ///
  (lfit shrw shrb if nb > 25000, lc(black))                               ///
  (scatter shrw shrb if lbp, msymbol(circle))                             ///
  (lfit shrw shrb if lbp, lc(black) lp(dash)), scheme(s1mono) legend(off) ///
  ylab( , angle(h) grid gstyle(dot)) xlab( , grid gstyle(dot))            ///
  tit("Standardized Black and White Homicide Rates")                      ///
  note("Dark circles: MSAs with 10-25K blacks. Open circles: MSAs with 25K+ blacks.") ///
  xtit("standardized black homicide rate")                                ///
  ytit("standardized white homicide rate")
graph export ~/desktop/bwh-fig6.pdf, replace



*** Unemployment and homicide
corr hrb hrw if !mi(urb)

corr uro urb urw

regress hro uro if !mi(urb)
regress hrb urb if !mi(urb)
regress hrw urw if !mi(urb)

corr uro urm urf


  
  


  

