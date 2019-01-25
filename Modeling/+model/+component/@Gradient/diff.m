function dEqtn = diff(eqtn, vecWrt, output)
% diff  Differentiate one equation wrt to list of names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

try, output; catch, output = 'array'; end %#ok<NOCOM,VUNUS>

%--------------------------------------------------------------------------

% Create string and remove anonymous function preamble.
if isfunc(eqtn)
    eqtn = func2str(eqtn);
end
eqtn = regexprep(eqtn, '^@\(.*?\)', '', 'once');

% Replace x(:,n,t+k) with xN, xNpK, or xNmK.
eqtn = model.component.Gradient.array2symb(eqtn);

nWrt = length(vecWrt);
nm = real(vecWrt);
sh = imag(vecWrt);
lsUnknown = cell(1, nWrt);
for i = 1 : nWrt
    if sh(i)==0
        % Shift==0: replace x(1,23,t) with x23.
        lsUnknown{i} = sprintf('x%g', nm(i));
    elseif sh(i)>0
        % Shift>0: replace x(1,23,t+1) with x23p1.
        lsUnknown{i} = sprintf('x%gp%g', nm(i), sh(i));
    else
        % Shift<0: replace x(1,23,t-1) with x23m1.
        lsUnknown{i} = sprintf('x%gm%g', nm(i), abs(sh(i)));
    end
end

if strcmpi(output, 'array')
    lsUnknown = sprintf('%s ', lsUnknown{:});
end
dEqtn = Ad.diff(eqtn, lsUnknown);

% Replace xN, xNpK, xNmK back with x(N,t+/-K,:).
% Replace LN, LNpK, LNmK back with L(n,t+/-K,:).
dEqtn = model.component.Gradient.symb2array(dEqtn);

end
