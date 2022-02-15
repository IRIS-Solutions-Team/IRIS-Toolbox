# Overview of grouping objects

Grouping objects are used for aggregating the contributions of shocks
in model simulations, [`model/simulate`](model/simulate), or aggregating
the contributions of measurement variables in Kalman filtering, 
[`model/filter`](model/filter).

Constructor
============

* [`Grouping`](Grouping/Grouping) - Create new empty Grouping object


Getting information about groups
=================================

* [`detail`](Grouping/detail) - Details of a Grouping object
* [`isempty`](Grouping/isempty) - True for empty Grouping object


Setting up and using groups
============================

* [`addgroup`](Grouping/addgroup) - Add measurement variable group or shock group to Grouping object
* [`eval`](Grouping/eval) - Evaluate contributions in input database S using Grouping object G

