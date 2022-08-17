function [exc, args] = checkStructureAfter(this, quantity, equation, opt)

exc = [ ];
args = { };

indxs = across(this.Incidence.Dynamic, 'Shift'); % Across all shifts.
insxs = across(this.Incidence.Steady, 'Shift');
ind0 = across(this.Incidence.Dynamic, 'Zero'); % At zero shift.
ins0 = across(this.Incidence.Steady, 'Zero');

ixy = quantity.Type==1;
ixx = quantity.Type==2;
ny = sum(ixy);
nx = sum(ixx);

ixm = equation.Type==1;
ixt = equation.Type==2;
nm = sum(ixm);
nt = sum(ixt);

% Current dates of transition variables
%---------------------------------------
% Dynamic equations.
test = ~any(ind0(ixt, ixx), 1);
if any(test)
    name = quantity.Name(ixx);
    exc = exception.ParseTime('Model:Postparser:NO_CURRENT_DATE_IN_DYNAMIC', opt.ThrowErrorAs);
    args = name(test);
    return
end
% Steady equations.
test = ~any(ins0(ixt, ixx), 1);
if any(test)
    name = quantity.Name(ixx);
    exc = exception.ParseTime('Model:Postparser:NO_CURRENT_DATE_IN_STEADY', opt.ThrowErrorAs);
    args = name(test);
    return
end

% Current dates of measurement variables
%----------------------------------------
% Dynamic equations.
test = ~any(ind0(ixm, ixy), 1);
if any(test)
    name = quantity.Name(ixy);
    exc = exception.ParseTime('Model:Postparser:NO_CURRENT_DATE_IN_DYNAMIC', opt.ThrowErrorAs);
    args = name(test);
    return
end
% Steady equations.
test = ~any(ins0(ixm, ixy), 1);
if any(test)
    name = quantity.Name(ixy);
    exc = exception.ParseTime('Model:Postparser:NO_CURRENT_DATE_IN_STEADY', opt.ThrowErrorAs);
    args = name(test);
    return
end

% No transition variable in some transition equations
%------------------------------------------------------
% Dynamic equations.
test = any(indxs(ixt, ixx), 2);
if any(~test)
    eqtn = equation.Input(ixt);
    exc = exception.ParseTime('Model:Postparser:NO_TRANSITION_VARIABLE_IN_DYNAMIC', opt.ThrowErrorAs);
    args = eqtn(~test);
    return
end
% Steady equations.
test = any(insxs(ixt, ixx), 2);
if any(~test)
    eqtn = equation.Input(ixt);
    exc = exception.ParseTime('Model:Postparser:NO_TRANSITION_VARIABLE_IN_STEADY', opt.ThrowErrorAs);
    args = eqtn(~test);
    return
end


% No measurement variable in some measurement equations
%-------------------------------------------------------
test = any(indxs(ixm, ixy), 2);
if any(~test)
    eqtn = equation.Input(ixm);
    exc = exception.ParseTime('Model:Postparser:NO_MEASUREMENT_VARIABLE_IN_DYNAMIC', opt.ThrowErrorAs);
    args = eqtn(~test);
    return
end
% Steady equations.
test = any(insxs(ixm, ixy), 2);
if any(~test)
    eqtn = equation.Input(ixm);
    exc = exception.ParseTime('Model:Postparser:NO_MEASUREMENT_VARIABLE_IN_STEADY', opt.ThrowErrorAs);
    args = eqtn(~test);
    return
end


% # transition equations ~= # transition variables
%--------------------------------------------------
if nt~=nx
    exc = exception.ParseTime('Model:Postparser:NUMBER_TRANSITION_EQUATIONS_VARIABLES', opt.ThrowErrorAs);
    args = {nt, nx};
    return
end

% # measurement equations ~= # measurement variables
%----------------------------------------------------
if nm~=ny
    exc = exception.ParseTime('Model:Postparser:NUMBER_MEASUREMENT_EQUATIONS_VARIABLES', opt.ThrowErrorAs);
    args = {nm, ny};
    return
end

end
