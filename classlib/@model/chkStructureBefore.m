function [exc, args] = chkStructureBefore(this, quantity, equation)
% chkStructureBefore  Check model structure before loss function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

exc = [ ];
args = { };

ixy = quantity.Type==TYPE(1);
ixx = quantity.Type==TYPE(2);
ixey = quantity.Type==TYPE(31);
ixex = quantity.Type==TYPE(32);
ixe = ixey | ixex;
ixp = quantity.Type==TYPE(4);
ixg = quantity.Type==TYPE(5);

ixm = equation.Type==TYPE(1);
ixt = equation.Type==TYPE(2);
ixd = equation.Type==TYPE(3);

indxs = across(this.Incidence.Dynamic, 'Shift'); % Across all shifts.
insxs = across(this.Incidence.Steady, 'Shift');
indxl = across(this.Incidence.Dynamic, 'Nonzero'); % Across lags and leads (non-zero shifts).
insxl = across(this.Incidence.Steady, 'Nonzero');
indxe = across(this.Incidence.Dynamic, 'Lead'); % Across leads (positive shifts).
insxe = across(this.Incidence.Steady, 'Lead');
ind0 = across(this.Incidence.Dynamic, 'Zero'); % At zero shift.
ins0 = across(this.Incidence.Steady, 'Zero');

% Lags/leads of measurement variables
%-------------------------------------
test = any(indxl(:, ixy), 2) | any(insxl(:, ixy), 2);
if any(test)
    exc = exception.ParseTime('Model:Postparser:MEASUREMENT_SHIFT', 'error');
    args = equation.Input(test);
    return
end

% Lags/leads of shocks
%----------------------
test = any(indxl(:, ixe), 2) | any(insxl(:, ixe), 2);
if any(test)
    exc = exception.ParseTime('Model:Postparser:SHOCK_SHIFT', 'error');
    args = equation.Input(test);
    return
end

% Lags/leads of parameters
%--------------------------
test = any(indxl(:, ixp), 2) | any(insxl(:, ixp), 2);
if any(test)
    exc = exception.ParseTime('Model:Postparser:PARAMETER_SHIFT', 'error');
    args = equation.Input(test);
    return
end

% Lags and leads of exogenous variables are captured as misplaced time
% subscripts.

% Measurement variables in transition equations.
test = any(indxs(ixt, ixy), 2) | any(insxs(ixt, ixy), 2);
if any(test)
    eqtn = equation.Input(ixt);
    exc = exception.ParseTime('Model:Postparser:MEASUREMENT_VARIABLE_IN_TRANSITION', 'error');
	args = eqtn(test);
    return
end

% No leads of transition variables in measurement equations.
test = any(indxe(ixm, ixx), 2) | any(insxe(ixm, ixx), 2);
if any(test)
    eqtn = equation.Input(ixm);
    exc = exception.ParseTime('Model:Postparser:LEAD_OF_TRANSITION_IN_MEASUREMENT', 'error');
    args = eqtn(test);
    return
end

% No current date of measurement variable in some measurement equation.
test = ~any(ind0(ixm, ixy), 2) | ~any(ins0(ixm, ixy), 2);
if any(test)
    eqtn = equation.Input(ixm);
    exc = exception.ParseTime('Model:Postparser:NO_CURRENT_MEASUREMENT', 'error');
    args = eqtn(test);
    return
end

if any(ixe)
    % Find transition shocks in measurement equations.
    test = any(ind0(ixm, ixex), 2) | any(ins0(ixm, ixex), 2);
    if any(test)
        eqtn = equation.Input(ixm);
        exc = exception.ParseTime('Model:Postparser:TRANSITION_SHOCK_IN_MEASUREMENT', 'error');
        args = eqtn(test);
        return
    end
    % Find measurement shocks in transition equations.
    test = any(ind0(ixt, ixey), 1) | any(ins0(ixt, ixey));
    if any(test)
        eqtn = equation.Input(ixt);
        exc = exception.ParseTime('Model:Postparser:MEASUREMENT_SHOCK_IN_TRANSITION', 'error');
        args = eqtn(test);
        return
    end
end

% Names other than parameters and exogenous variables in dtrend equations.
test = any(indxs(ixd, ~ixp & ~ixg), 2) | any(insxs(ixd, ~ixp & ~ixg), 2);
if any(test)
    eqtn = equation.Input(ixd);
    exc = exception.ParseTime('Model:Postparser:OTHER_THAN_PARAMETER_EXOGENOUS_IN_DTREND', 'error');
    args = eqtn(test);
    return
end

% Exogenous variables in equations other than dtrends.
% test = any(indxs(~ixd, ixg), 2) | any(insxs(~ixd, ixg), 2);
% if any(test)
%     eqtn = equation.Input(~ixd);
%     exc = exception.ParseTime('Model:Postparser:EXOGENOUS_IN_OTHER_THAN_DTREND', 'error');
% 	args = eqtn(test);
%     return
% end

end
