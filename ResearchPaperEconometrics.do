clear

cd "AlpArhanUguray/Research Project/STATA"

log using researchproject.log, replace

* Import the data from excel and save as a dta file, re-label the variables

import excel using "Data For Econometrics Research PaperTRYOUT.xlsx", sheet("STATA") clear firstrow

save TheDemandForElectricCars.dta, replace


label var year "The Base Year 2014"
label var us_states "U.S. States Identifier"
label var ecarsales "Electric Car Sales"
label var ecarprices "Average Electric Car Prices Across 13 Models After Tax-Exemption and Incentives"
label var numstations "The Number of Public Electric Fueling Stations"
label var medianincome "Median Income(2014 Dollars)"
label var taxexempt "Tax Exemption of the States( 1 if Exempt, otherwise 0)"
label var price_electricity "Price of Electricity Converted to Per Gasoline Gallon Equivalent"
label var price_gasoline "Price of Gasoline per Gallon"



save TheDemandForElectricCars.dta, replace

* Summary Statistics

use TheDemandForElectricCars.dta
   ssc install estout, replace
estpost tabstat *, stats(mean sd sk kurt min p5 p25 p50 p75 p95 max) ///
                      column(statistics)
   esttab  using descriptive_stats_demand.csv, ///
           cells("mean(fmt(2)) sd skewness kurtosis min p5 p25 p50 p75 p95 max") ///
           replace ///
           label ///
           varwidth(30) ///
           nomtitles ///
           nonumbers ///

* Correlation Matrix For the Regressions For .CSV File
quietly:  estpost corr ecarsales ecarprices numstations medianincome price_electricity price_gasoline, matrix listwise
esttab using table_correlation_electriccars.csv, ///
       replace ///
       plain ///
       nonumbers ///
       unstack ///
       not ///
       compress ///
       title("Table 1.  Correlation Table for the Factors that Influence the Demand of Electric Cars ") ///
       addnote("Note:  50 States in 2014 in the USA.")
	   
		   
* Individual Regression Equations to Describe the functional forms with their signs
* Drawing Scatter Plot for the functional form of the independent variable "ecarprices"

*regress ecarsales price_electricity
*cprplot price_electricity, mspline msopts(bands(13))   


gen ecarprices2 = ecarprices^2
gen medianincome2 = medianincome^2
gen price_electricity2 = price_electricity^2
gen price_gasoline2 = price_gasoline^2
gen numstations2 = numstations^2

* Dependent Variable: Average Electric Car Sales Across States
* Estimated Model of the Regression:
regress ecarsales ecarprices ecarprices2 price_electricity price_gasoline numstations medianincome, robust


* Several Regression Comparisons Across the Independent Variables
eststo clear   /* clear any regressions that may be already stored in memory */
  eststo:  quietly  regress ecarsales ecarprices ecarprices2 price_electricity price_gasoline numstations medianincome, robust
  eststo:  quietly  regress ecarsales price_electricity price_gasoline numstations medianincome, robust
  eststo:  quietly  regress ecarsales ecarprices ecarprices2 price_gasoline numstations , robust
  esttab  using table_sidebyside_regressions_CSV.csv, ///
          r2 ar2 se scalar(F rmse) ///
          star(* 0.10 ** 0.05 *** 0.01) ///
          replace ///
          label ///
          depvars ///
          varwidth(30) ///
          title("Table 3.  Regression results for the Factors that Influence the Demand of Electric Cars") ///
          nonotes ///
          addnote("Note 1:  Robust standard errors are displayed in parenthesis." ///
                  "Note 2:  [Number of Observations are 50]" ///
                  "Significance levels:  * p<0.10; ** p<0.05; *** p<0.01" ///
                  "Source:  []")

				  
*** The 3 regressions to check for omitted variable bias:
regress ecarsales ecarprices ecarprices2 price_electricity price_gasoline numstations medianincome, robust
regress ecarsales price_electricity price_gasoline numstations medianincome, robust
regress ecarsales ecarprices ecarprices2 price_gasoline numstations , robust

* Correlation between all of the variables				 
correlate ecarsales ecarprices ecarprices2 price_electricity price_gasoline numstations medianincome
				  
*** Graphs 
* Histogram For the All of the Variables

hist ecarsales, ///
	 title("Histogram:  2014 Electric Car Sales Across 50 States in the USA" ///
           " ", span) ///
		   

*close the log

log close

