% forExplanatory  Construct a simulation Plan object for Explanatory object or array
%{
% ## Syntax ##
%
%
%     p = Plan.forExplanatory(expy, simulationRange, ...)
%
%
% ## Input Arguments ##
%
%
% __`expy`__ [ Explanatory ]
% >
% Explanatory object or array for which the new simulation Plan `p`
% will be created on the `simulationRange`.
%
%
% __`simulationRange`__ [ DateWrapper ]
% >
% The range on which the `expy` object or array will be simulated using the
% simulation plan `p`.
%
%
% ## Output Arguments ##
%
%
% __`p`__ [ Plan ]
% >
% A new simulation Plan object that can be use when simulating the `expy`
% object or array on the `simulationRange`.
%
%
% ## Description ##
%
%
% The `Plan` object created by `Plan.forExplanatory( )` is to be
% used in an `Explanatory/simulate( )` function to specify the
% exogenized variables. Only the LHS variables in non-identities can be
% exogenized.  When an LHS variables is exogenized, the respective residual
% belonging to the equation is endogenized in the same periods; this is
% done automatically and no `endogenize( )` or `swap( )` functions are
% called by the user.
% 
% There are two ways how to exogenize a variable in a `Plan` created for an
% `Explanatory`:
%
% * `exogenize( )` exogenizes some LHS variables in some periods no matter
% what;
%
% * `exogenizeWhenData( )` exogenizes some LHS variables in specified
% periods; however, if data are missing (i.e. are `NaN`) for a particular
% exogenized point, the variabe in that period is not exogenized
% and treated endogenously instead.
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = forExplanatory(expy, simulationRange)

%( Input parser
persistent ip
if isempty(ip)
    ip = inputParser();
    addRequired(ip, 'expy', @(x) isa(x, 'Explanatory'));
    addRequired(ip, 'simulationRange', @validate.properRange);
end
parse(ip, expy, simulationRange);
simulationRange = double(simulationRange);
%)


this = Plan( );
this.BaseStart = simulationRange(1);
this.BaseEnd = simulationRange(end);
this = preparePlan(expy, this);

numEndogenous = this.NumOfEndogenous;
numExogenous = this.NumOfExogenous;
numExtendedPeriods = this.NumExtdPeriods;
this.IdAnticipatedExogenized = zeros(numEndogenous, numExtendedPeriods, 'int16');
this.IdUnanticipatedExogenized = zeros(numEndogenous, numExtendedPeriods, 'int16');
this.IdAnticipatedEndogenized = zeros(numExogenous, numExtendedPeriods, 'int16');
this.IdUnanticipatedEndogenized = zeros(numExogenous, numExtendedPeriods, 'int16');
this.InxToKeepEndogenousNaN = false(numEndogenous, numExtendedPeriods);

this.AnticipationStatusEndogenous = repmat(this.DefaultAnticipationStatus, numEndogenous, 1);
this.AnticipationStatusExogenous = repmat(this.DefaultAnticipationStatus, numExogenous, 1);

this.AllowUnderdetermined = true;
this.AllowOverdetermined = true;

end%

