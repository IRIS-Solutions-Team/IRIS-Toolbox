function dEqtn = mydiffeqtn(eqtn, wrt)
% mydiffeqtn  Differentiate one equation wrt to a list of names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

isSimplify = true;

% Create string and remove anonymous function preamble.
if isfunc(eqtn)
    eqtn = func2str(eqtn);
end
eqtn = regexprep(eqtn, '^@\(.*?\)', '', 'once');

% Replace x(:,n,t+k) with xN, xNpK, or xNmK.
eqtn = sydney.myeqtn2symb(eqtn);

nWrt = length(wrt);
nm = real(wrt);
sh = imag(wrt);
lsUnknown = cell(1, nWrt);
for i = 1 : nWrt
    if sh(i)==0
        % Shift==0: replace x(1,23,t) with x23.
        lsUnknown{i} = sprintf('x%g', nm(i));
    elseif sh(i) > 0
        % Shift>0: replace x(1,23,t+1) with x23p1.
        lsUnknown{i} = sprintf('x%gp%g', nm(i), round(sh(i)));
    else
        % Shift<0: replace x(1,23,t-1) with x23m1.
        lsUnknown{i} = sprintf('x%gm%g', nm(i), round(abs(sh(i))));
    end
end

% temp = Ad.diff(eqtn, lsUnknown);

% Create sydney object for the current equation.
Z = sydney(eqtn, lsUnknown);
Z = derv(Z, 'enbloc', lsUnknown, isSimplify);
dEqtn = char(Z);

% Replace xN, xNpK, xNmK back with x(N,t+/-K,:).
% Replace LN, LNpK, LNmK back with L(n,t+/-K,:).
dEqtn = sydney.mysymb2eqtn(dEqtn, 'dynamic');

end
