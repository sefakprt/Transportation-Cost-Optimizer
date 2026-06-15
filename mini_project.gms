$Title IE 202 Mini Project - Fall 2025

Sets
     i   Sources (Production Sites)   / 1*6 /
     j   Markets                      / 1*10 /;

Parameters
     Supply(i)   Production capacity at sites (million sq m)
     / 1 15, 2 20, 3 15, 4 10, 5 15, 6 10 /

     Demand(j)   Annual demand in markets (million sq m)
     / 1 11, 2 12, 3 9, 4 10, 5 8, 6 13, 7 7, 8 5, 9 6, 10 4 /;

* ------------------------------------------------------------------
* DATA ENTRY
* ------------------------------------------------------------------

* Table 1: Unit Cost by Rail ($1000s)
Table RailCost(i,j)
      1   2   3   4   5   6   7   8   9   10
   1  61  72  45  55  66  63  43  72  67  60
   2  69  78  60  49  56  57  50  63  78  48
   3  59  66  63  61  47  76  40  54  42  80
   4  59  63  60  59  69  70  40  53  73  65
   5  57  60  78  80  56  54  73  60  67  63
   6  62  46  47  55  55  60  54  77  48  42;

* Table 2: Unit Cost by Maritime Route ($1000s)
* Note: Missing values or merged columns in PDF handled based on Table 3 feasibility.
Table SeaTransCost(i,j)
      1   2   3   4   5   6   7   8   9   10
   1  31  38  24  0   35  23  31  23  44  41
   2  36  43  28  24  31  28  26  35  50  52
   3  0   33  36  32  26  24  35  24  43  33
   4  39  31  39  38  0   35  22  43  37  36
   5  20  31  43  37  27  36  38  23  0   38
   6  20  29  40  21  33  36  32  28  42  47;

* Table 3: Investment for Cargo Ships ($1000s)
Table InvestCost(i,j)
      1    2    3    4    5    6    7    8    9    10
   1  275  238  303  0  285  309  271  312  293  246
   2  293  270  318  250  265  232  321  255  322  255
   3  0    275  283  268  240  297  262  228  239  338
   4  271  241  267  318  0    249  240  282  311  284
   5  302  297  242  232  243  271  241  286  0    264
   6  295  253  256  263  243  274  285  247  284  245;

* ------------------------------------------------------------------
* COST CALCULATION
* ------------------------------------------------------------------

Parameter TotalSeaCost(i,j);
* EUAC is 8% of Investment + Shipping Cost
TotalSeaCost(i,j) = SeaTransCost(i,j) + (0.08 * InvestCost(i,j));

Parameter CostOpt1(i,j) "Option 1: Rail Only";
CostOpt1(i,j) = RailCost(i,j);

Parameter CostOpt2(i,j) "Option 2: Water Only (Rail if Water 0easible)";
* Use Water cost if available, otherwise use Rail cost
CostOpt2(i,j) = TotalSeaCost(i,j);
CostOpt2(i,j)$(TotalSeaCost(i,j) = 0) = RailCost(i,j);

Parameter CostOpt3(i,j) "Option 3: Cheapest of Rail or Water";
CostOpt3(i,j) = min(RailCost(i,j), TotalSeaCost(i,j));

* ------------------------------------------------------------------
* MODEL DEFINITION
* ------------------------------------------------------------------

Variables
     x(i,j)      Amount shipped from source i to market j
     z           Total Cost;

Positive Variable x;

Parameters
     CurrentCost(i,j)   Active cost parameter for the solver;

Equations
     ObjFunction       Minimize total transportation cost
     SupplyConst(i)    Do not exceed supply at sources
     DemandConst(j)    Satisfy demand at markets;

ObjFunction..        z =e= sum((i,j), CurrentCost(i,j) * x(i,j));

SupplyConst(i)..     sum(j, x(i,j)) =l= Supply(i);

DemandConst(j)..     sum(i, x(i,j)) =g= Demand(j);

Model TransportModel /all/;

* ------------------------------------------------------------------
* QUESTION 1: SOLVING ALL OPTIONS
* ------------------------------------------------------------------

* --- Option 1: Rail Only ---
CurrentCost(i,j) = CostOpt1(i,j);
Solve TransportModel using lp minimizing z;
Display "--- Results for Option 1 (Rail Only) ---", z.l, x.l;

* --- Option 2: Maritime Preferred ---
CurrentCost(i,j) = CostOpt2(i,j);
Solve TransportModel using lp minimizing z;
Display "--- Results for Option 2 (Maritime Preferred) ---", z.l, x.l;

* --- Option 3: Best of Both ---
CurrentCost(i,j) = CostOpt3(i,j);
Solve TransportModel using lp minimizing z;
Display "--- Results for Option 3 (Best Strategy) ---", z.l, x.l;

* ------------------------------------------------------------------
* PREPARING FOR QUESTIONS 2-5
* Note: We use Option 3 (Best Strategy) as the baseline for improvements.
* ------------------------------------------------------------------

* ------------------------------------------------------------------
* QUESTION 2: PRE-ASSIGNED SHIPMENTS
* Keep S1-M2, S3-M1, S3-M2 at 6 million tons.
* ------------------------------------------------------------------

* Reset constraints
x.lo(i,j) = 0;
x.up(i,j) = 0;

* Fix specific variables
x.fx('1','2') = 6;
x.fx('3','1') = 6;
x.fx('3','2') = 6;

CurrentCost(i,j) = CostOpt3(i,j);
Solve TransportModel using lp minimizing z;
Display "--- Answer to Q2: Fixed Shipments ---", z.l, x.l;

* ------------------------------------------------------------------
* SENSITIVITY ANALYSIS (For Q3, Q4, Q5)
* Resetting to Optimal Option 3 to get Marginal values
* ------------------------------------------------------------------
x.lo(i,j) = 0;
x.up(i,j) = 0;
CurrentCost(i,j) = CostOpt3(i,j);
Solve TransportModel using lp minimizing z;

* ------------------------------------------------------------------
* QUESTION 3: Source 4 -> Market 8 Relationship
* Look at Reduced Cost (x.m) for x('4','8')
* ------------------------------------------------------------------
Display "--- Answer to Q3: Cost to justify S4-M8 ---", x.m;

* ------------------------------------------------------------------
* QUESTION 4: Source 2 -> Market 7 by Rail
* Check if Rail cost is used in Opt 3. If not, look at difference.
* ------------------------------------------------------------------
Parameter RailCheck_S2_M7;
RailCheck_S2_M7 = RailCost('2','7');
Display "--- Answer to Q4: Check Rail Cost S2-M7 ---", RailCheck_S2_M7, x.l;

* ------------------------------------------------------------------
* QUESTION 5: Supply Variation
* Look at Shadow Prices (Marginals) of Supply Constraints
* ------------------------------------------------------------------
Display "--- Answer to Q5: Supply Shadow Prices ---", SupplyConst.m;