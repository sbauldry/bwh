*** Purpose: Prepare data for analysis of black-white homicide rates
*** Author: S Bauldry
*** Date: November 13, 2017

*** Set working directory
cd ~/dropbox/research/statistics/bwh/bwh-work

*** Read and combine raw data for 2008-2010
clear
infix year 102-105 record_type 19 resident 20 month 65-66 day 85 ///
      str o_state 21-22 str o_county 23-25 str r_state 29-30     ///
	  str r_county 35-37 str sex 69 race 445-446 str age 70-73   ///
	  str marital2 84 str b_state 55-56 hispanic 484-486         ///
      h_origin 488 education 61-62 education_r 63 manner 107     ///
	  place 145 str icd10 146-149 cause358 150-152               ///
	  using "~/dropbox/research/data/mortality/2008/MULT2008.USPART2"  

keep if cause358 > 431 & cause358 < 442 
tempfile d1
save `d1', replace

clear
infix year 102-105 record_type 19 resident 20 month 65-66 day 85 ///
      str o_state 21-22 str o_county 23-25 str r_state 29-30     ///
	  str r_county 35-37 str sex 69 race 445-446 str age 70-73   ///
	  str marital2 84 str b_state 55-56 hispanic 484-486         ///
      h_origin 488 education 61-62 education_r 63 manner 107     ///
	  place 145 str icd10 146-149 cause358 150-152               ///
	  using "~/dropbox/research/data/mortality/2009/MULT2009.USPART2"  

keep if cause358 > 431 & cause358 < 442 
tempfile d2
save `d2', replace

clear
infix year 102-105 record_type 19 resident 20 month 65-66 day 85 ///
      str o_state 21-22 str o_county 23-25 str r_state 29-30     ///
	  str r_county 35-37 str sex 69 race 445-446 str age 70-73   ///
	  str marital2 84 str b_state 55-56 hispanic 484-486         ///
      h_origin 488 education 61-62 education_r 63 manner 107     ///
	  place 145 str icd10 146-149 cause358 150-152               ///
	  using "~/dropbox/research/data/mortality/2010/MULT2010.USPART2.EXACTDOD"  

keep if cause358 > 431 & cause358 < 442 
tempfile d3
save `d3', replace

append using `d1'
append using `d2'


*** Preparing variables
gen fem = (sex == "F") if !mi(sex)

egen his = anymatch(h_origin), values(1 2 3 4 5 9)

gen     rrace = 1 if race == 1 & his != 1
replace rrace = 2 if race == 2 & his != 1
gen blk = (rrace == 2) if !mi(rrace)
keep if !mi(blk)

destring age, replace
recode age (201/699 2001/6999 = 0) (1999 = 1) (999 9999 = .) 
replace age = age - 1000 if age >= 1001 & age <= 1109

* note: using state (and county) of occurance
replace o_state = "02" if o_state == "AK"
replace o_state = "01" if o_state == "AL"
replace o_state = "05" if o_state == "AR"
replace o_state = "04" if o_state == "AZ"
replace o_state = "06" if o_state == "CA"
replace o_state = "08" if o_state == "CO"
replace o_state = "09" if o_state == "CT"
replace o_state = "11" if o_state == "DC"
replace o_state = "10" if o_state == "DE"
replace o_state = "12" if o_state == "FL"
replace o_state = "13" if o_state == "GA"
replace o_state = "15" if o_state == "HI"
replace o_state = "19" if o_state == "IA"
replace o_state = "16" if o_state == "ID"
replace o_state = "17" if o_state == "IL"
replace o_state = "18" if o_state == "IN"
replace o_state = "20" if o_state == "KS"
replace o_state = "21" if o_state == "KY"
replace o_state = "22" if o_state == "LA"
replace o_state = "25" if o_state == "MA"
replace o_state = "24" if o_state == "MD"
replace o_state = "23" if o_state == "ME"
replace o_state = "26" if o_state == "MI"
replace o_state = "27" if o_state == "MN"
replace o_state = "29" if o_state == "MO"
replace o_state = "28" if o_state == "MS"
replace o_state = "30" if o_state == "MT"
replace o_state = "37" if o_state == "NC"
replace o_state = "38" if o_state == "ND"
replace o_state = "31" if o_state == "NE"
replace o_state = "33" if o_state == "NH"
replace o_state = "34" if o_state == "NJ"
replace o_state = "35" if o_state == "NM"
replace o_state = "32" if o_state == "NV"
replace o_state = "36" if o_state == "NY"
replace o_state = "39" if o_state == "OH"
replace o_state = "40" if o_state == "OK"
replace o_state = "41" if o_state == "OR"
replace o_state = "42" if o_state == "PA"
replace o_state = "44" if o_state == "RI"
replace o_state = "45" if o_state == "SC"
replace o_state = "46" if o_state == "SD"
replace o_state = "47" if o_state == "TN"
replace o_state = "48" if o_state == "TX"
replace o_state = "49" if o_state == "UT"
replace o_state = "51" if o_state == "VA"
replace o_state = "50" if o_state == "VT"
replace o_state = "53" if o_state == "WA"
replace o_state = "55" if o_state == "WI"
replace o_state = "54" if o_state == "WV"
replace o_state = "56" if o_state == "WY"

egen cntyfips = concat(o_state o_county)

* change in FIPS code for Miami and Sarasota
replace cntyfips = "12086" if cntyfips == "12025"
replace cntyfips = "42260" if cntyfips == "14600"

*** Merge with MSA data
merge m:1 cntyfips using ///
  ~/dropbox/research/statistics/bwh/bwh-work/countyTOmsa08
  
drop if _merge == 1 | _merge == 2


*** Construct MSA level data set with homicide counts
gen nh = 1

tempfile d1 d2 d3 d4 d5 d6
preserve
collapse (count) nho = nh (first) name, by(metroid)
save `d1', replace
restore

preserve
keep if blk
collapse (count) nhb = nh, by(metroid)
save `d2', replace
restore

preserve
keep if !blk
collapse (count) nhw = nh, by(metroid)
save `d3', replace
restore

preserve
keep if fem
collapse (count) nhf = nh, by(metroid)
save `d4', replace
restore

preserve
keep if !fem
collapse (count) nhm = nh, by(metroid)
save `d5', replace
restore

use `d1', replace
forval i = 2/5 {
	merge 1:1 metroid using `d`i''
	drop _merge
}
save `d6', replace


*** Preparing ACS data on population size for MSAs
*** 2010 ACS 5-year Selected Population Tables
*** factfinder.census.gov/faces/nav/jsf/pages/download_center.xhtml#none
*** downloaded November 20, 2017
clear
import excel using bwh-acs/ACS_10_SF4_B01001_with_ann, first

gen pg = 1 if POPGROUPdisplaylabel == "Total population"
replace pg = 2 if POPGROUPdisplaylabel == "White alone"
replace pg = 3 if POPGROUPdisplaylabel == "Black or African American alone"
keep if !mi(pg)

rename (GEOid2 HD01_VD01 HD01_VD02 HD01_VD26) (metroid np nm nf)

keep metroid pg np nm nf
reshape wide np nm nf, i(metroid) j(pg)
rename (np1 np2 np3 nm1 nf1) (np nw nb nm nf)
keep metroid np nw nb nm nf
destring _all, replace

*** merging with homicide data
merge 1:1 metroid using `d6'

* drop small number of MSAs that did not merge
drop if _merge != 3
drop _merge


*** generate homicide rates
gen hro = (nho/3)/np
gen hrw = (nhw/3)/nw
gen hrb = (nhb/3)/nb
gen hrm = (nhm/3)/nm
gen hrf = (nhf/3)/nf


*** save data for analysis
save bwh-data, replace
