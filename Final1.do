//Drop missing data and recategorization
drop if mi(educ)
drop if educ>20
drop if mi(polviews)
drop if polviews>7
replace  polview    = 1 if (polview <= 3) 
replace  polview    = 2 if (polview > 3)&(polview<5)  
replace  polview    = 3 if (polview >= 5) 

label define category 1 "Liberal" 2 "Moderate" 3 ///
				"Conserative", modify

			label values polviews category
			
//Description			
des class educ sex race age polviews
sum educ
sum age
tab class

//Run the multinomial logit model
mlogit class educ i.sex i.race age i.polviews 

//Odds ratio e^b: present the findings using Long 1997, Table 6.5
listcoef sex

//Odds ratio e^b for every SD change on educ
listcoef age

//Example 2: test significance of each I.V. for the overall model with 5 outcomes
mlogtest, lr

/* Example 4: test the hypothesis about indistinguishable outcomes: 
>             whether we can combine categories of the outcome varaible */
mlogtest, combine


//Using predict command to save five probabilities for the current multinomial model
predict L W M U
sum L W M U

//Run ordered logit model and save model predicted probabilities
ologit class educ i.sex i.race age i.polviews
predict oL oW oM oU

//Compare predicted probabilties between mlogit and ologit
dotplot oL L
correlate oL L
dotplot oW W
correlate oW W
dotplot oM M
correlate oM M
dotplot oU U
correlate oU U

//Example 6: produce various predicted probabilities
//AMEs
mlogit class educ i.sex i.race age i.polviews
mchange, amount(one sd)
sum L W M U

//Produce a line charge using mgen & graph twoway
// Using the party affiliation data
use GSS2014, clear
mlogit class educ i.sex i.race age i.polviews
predict C1 C2 C3 C4
mgen, atmeans at(educ=(0(4)20)) stub(class) replace
label var C1 "Lower class"
label var C2 "Working class"
label var C3 "Middle class"
label var C4 "Upper class"

graph twoway connected ///
 C1 C2 C3 C4 classeduc, ///
 title("Multinomial logit model: other variables held at their means", ///
 size(medium)) ///
 ytitle(Probability of Social Class) ylab(0(.2)1, grid gmax gmin) ///
 msym(O Oh dh sh s) ///
 lpat(solid dash shortdash dash solid) ///
 legend(rows(2))

log close






















