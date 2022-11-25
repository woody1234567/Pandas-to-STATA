**********
* STEP 1 *
**********
* Only have to do the following three commands only the first time to tranform the data into .dta file.
cd "/Users/changjay/Desktop/Pandas-to-STATA Project/countylevel_tariffs_and_exports"
import delimited "step1_initial.csv", clear
save "step1_initial.dta", replace

* main adjustments for the data
use "step1_initial.dta", clear
keep if agglvl_code == 75
keep if own_code == 5
gen area_fips_head = substr(area_fips, 1, 2) // create this to drop some useless observations
drop if area_fips_head == "72" | area_fips_head == "78" | area_fips_head == "02" | area_fips_head == "15" // keep observations with area_fips_head other than "72", "78", "02", or "15". obs: 199,393, correct!
drop area_fips_head // this temporary variable can be dropped
collapse (sum) annual_avg_emplvl, by (industry_code) // sum annual_avg_emplvl in the same industry_code
rename annual_avg_emplvl nat_emplvl
save "step1.dta", replace // correspond to df.national

* Check: We check if there's any difference in nat_emplvl.
* import the output created by pandas
import delimited "step1_pandas.csv", clear
tostring industry_code, replace // in order to merge (when merging, the key in both files should have the same type)
save "step2_pandas.dta", replace

* merge our data and the data produced by pandas
use "step1.dta", clear
clonevar nat_emplvl_test = nat_emplvl
merge 1:1 industry_code using "step2_pandas.dta"

* assertion
assert nat_emplvl_test == nat_emplvl

* total(nat_emplvl) // checking the sum of nat_emplvl

**********
* STEP 2 *
**********
* Only have to do the following two importing commands only the first time to tranform the .csv into .dta file.
* import the china trade csv
cd "/Users/changjay/Desktop/Pandas-to-STATA Project/countylevel_tariffs_and_exports"
import delimited "step2_china.csv", clear
save "step2_china.dta", replace

* import the world trade csv
import delimited "step2_world.csv", clear
save "step2_world.dta", replace

* merge the two with key e_commodity and time
use "step2_china.dta", clear
merge 1:1 e_commodity time using "step2_world.dta"
keep e_commodity comm_lvl total_trade china_trade time
save "step2.dta", replace

* Check: We check whether observations with the same e_commodity code and time have the same china_trade and total_trade.
* For the first time you need to import the output created by pandas.
import delimited "step2_pandas.csv", clear
save "step2_pandas.dta", replace

* merge our data and the data produced by pandas
use "step2.dta", clear
clonevar china_trade_test = china_trade
clonevar total_trade_test = total_trade
merge 1:1 e_commodity time using "step2_pandas.dta"

* assertions
assert china_trade_test == china_trade
assert total_trade_test == total_trade // both are correct!



















