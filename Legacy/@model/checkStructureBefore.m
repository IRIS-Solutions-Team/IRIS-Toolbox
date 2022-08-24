function [exc, args] = checkStructureBefore(this, quantity, equation, opt)

exc = [];
args = {};

inxY = quantity.Type==(1);
inxX = quantity.Type==(2);
ixey = quantity.Type==(31);
ixex = quantity.Type==(32);
ixe = ixey | ixex;
ixp = quantity.Type==(4);
ixg = quantity.Type==(5);

ixm = equation.Type==(1);
ixt = equation.Type==(2);
ixd = equation.Type==(3);

% __No Transition Variable__
if ~any(inxX)
    exc = exception.ParseTime('Model:Postparser:NO_TRANSITION_VARIABLE', opt.ThrowErrorAs);
    return
end

% __No Transition Equation__
if ~any(ixt)
    exc = exception.ParseTime('Model:Postparser:NO_TRANSITION_EQUATION', opt.ThrowErrorAs);
    return
end

indxs = across(this.Incidence.Dynamic, 'Shift'); % Across all shifts.
insxs = across(this.Incidence.Steady, 'Shift');
indxl = across(this.Incidence.Dynamic, 'Nonzero'); % Across lags and leads (non-zero shifts).
insxl = across(this.Incidence.Steady, 'Nonzero');
indxe = across(this.Incidence.Dynamic, 'Lead'); % Across leads (positive shifts).
insxe = across(this.Incidence.Steady, 'Lead');
ind0 = across(this.Incidence.Dynamic, 'Zero'); % At zero shift.
ins0 = across(this.Incidence.Steady, 'Zero');

% __Lags/Leads of Measurement Variables__
test = any(indxl(:, inxY), 2) | any(insxl(:, inxY), 2);
if any(test)
    exc = exception.ParseTime('Model:Postparser:MEASUREMENT_SHIFT', opt.ThrowErrorAs);
    args = equation.Input(test);
    return
end

% __Lags/Leads of Shocks__
test = any(indxl(:, ixe), 2) | any(insxl(:, ixe), 2);
if any(test)
    exc = exception.ParseTime('Model:Postparser:SHOCK_SHIFT', opt.ThrowErrorAs);
    args = equation.Input(test);
    return
end

% Lags and leads of exogenous variables are captured as misplaced time
% subscripts.

% __Measurement Variables in Transition Equations__
test = any(indxs(ixt, inxY), 2) | any(insxs(ixt, inxY), 2);
if any(test)
    eqtn = equation.Input(ixt);
    exc = exception.ParseTime('Model:Postparser:MEASUREMENT_VARIABLE_IN_TRANSITION', opt.ThrowErrorAs);
    args = eqtn(test);
    return
end

% __No Leads of Transition Variables in Measurement Equations__
test = any(indxe(ixm, inxX), 2) | any(insxe(ixm, inxX), 2);
if any(test)
    eqtn = equation.Input(ixm);
    exc = exception.ParseTime('Model:Postparser:LEAD_OF_TRANSITION_IN_MEASUREMENT', opt.ThrowErrorAs);
    args = eqtn(test);
    return
end

% __No Current Date of Measurement Variable in Some Measurement Equation__
test = ~any(ind0(ixm, inxY), 2) | ~any(ins0(ixm, inxY), 2);
if any(test)
    eqtn = equation.Input(ixm);
    exc = exception.ParseTime('Model:Postparser:NO_CURRENT_MEASUREMENT', opt.ThrowErrorAs);
    args = eqtn(test);
    return
end

if any(ixe)
    % __Transition Shocks in Measurement Equations__
    test = any(ind0(ixm, ixex), 2) | any(ins0(ixm, ixex), 2);
    if any(test)
        eqtn = equation.Input(ixm);
        exc = exception.ParseTime('Model:Postparser:TRANSITION_SHOCK_IN_MEASUREMENT', opt.ThrowErrorAs);
        args = eqtn(test);
        return
    end
    % __Measurement Shocks in Transition Equations__
    test = any(ind0(ixt, ixey), 1) | any(ins0(ixt, ixey));
    if any(test)
        eqtn = equation.Input(ixt);
        exc = exception.ParseTime('Model:Postparser:MEASUREMENT_SHOCK_IN_TRANSITION', opt.ThrowErrorAs);
        args = eqtn(test);
        return
    end
end

% Names other than parameters and exogenous variables in dtrend equations
test = any(indxs(ixd, ~ixp & ~ixg), 2) | any(insxs(ixd, ~ixp & ~ixg), 2);
if any(test)
    eqtn = equation.Input(ixd);
    exc = exception.ParseTime('Model:Postparser:OTHER_THAN_PARAMETER_EXOGENOUS_IN_DTREND', opt.ThrowErrorAs);
    args = eqtn(test);
    return
end

% Exogenous variables in equations other than measurement trends - the user
% may allow exogenous variables, they only work in nonlinear simulations
if ~opt.AllowExogenous
    test = any(indxs(~ixd, ixg), 2) | any(insxs(~ixd, ixg), 2);
    if any(test)
        eqtn = equation.Input(~ixd);
        exc = exception.ParseTime('Model:Postparser:ExogenousInOtherThanDtrend', opt.ThrowErrorAs);
        args = eqtn(test);
        return
    end
end

end%

