Transportation Optimization Model

This repository contains a GAMS-based linear programming model developed for the IE 202 Mini Project in the Fall 2025 semester. The primary objective of this model is to minimize total transportation costs while distributing goods from 6 production sites (sources) to 10 distinct markets.

Project Overview

The model determines the optimal shipping amounts by balancing production capacities at the sources with annual demands at the markets.

Transportation costs are evaluated across different transit modes, specifically rail and maritime routes.

Total maritime costs are calculated by adding the base sea transport cost to an 8% Equivalent Uniform Annual Cost (EUAC) of the cargo ship investments.

The model uses the CPLEX linear programming (LP) solver to minimize the total cost.

Evaluated Transportation Strategies
The code calculates and compares three distinct routing strategies:

Option 1: Relies entirely on rail transportation.

Option 2: Prefers maritime transportation, using rail only when water routes are unfeasible (represented by a zero cost).

Option 3: Strategically selects the cheapest available option between rail and water for each specific route.

Sensitivity and Advanced Analysis
Beyond basic cost minimization, the code includes specific constraints and analyses to answer project questions:

Evaluates total costs when specific shipments are pre-assigned (e.g., fixing volumes between Source 1 to Market 2, and Source 3 to Markets 1 and 2).

Extracts reduced costs (marginals) to justify the financial viability of specific routes, such as Source 4 to Market 8.

Checks the usage and difference of specific rail costs, like the route from Source 2 to Market 7.

Uses shadow prices from supply constraints to analyze the impact of supply variations.
