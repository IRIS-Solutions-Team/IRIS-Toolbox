% diff  Differentiate one equation wrt to list of names
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function diffEqtn = diff(eqtn, wrts, output)

% Create string and remove anonymous function preamble.
if isa(eqtn, 'function_handle')
    eqtn = func2str(eqtn);
end
eqtn = regexprep(eqtn, '^@\(.*?\)', '', 'once');

% Replace x(:,n,t+k) with xN, xNpK, or xNmK.
eqtn = model.Gradient.array2symb(eqtn);

numWrts = numel(wrts);
nm = real(wrts);
sh = imag(wrts);
listUnknowns = cell(1, numWrts);
for i = 1 : numWrts
    if sh(i)==0
        % Shift==0: replace x(1,23,t) with x23.
        listUnknowns{i} = sprintf('x%g', nm(i));
    elseif sh(i)>0
        % Shift>0: replace x(1,23,t+1) with x23p1.
        listUnknowns{i} = sprintf('x%gp%g', nm(i), sh(i));
    else
        % Shift<0: replace x(1,23,t-1) with x23m1.
        listUnknowns{i} = sprintf('x%gm%g', nm(i), abs(sh(i)));
    end
end

if string(output)=="array"
    listUnknowns = sprintf('%s ', listUnknowns{:});
end
diffEqtn = Ad.diff(eqtn, listUnknowns);

% Replace xN, xNpK, xNmK back with x(N,t+/-K,:).
% Replace LN, LNpK, LNmK back with L(n,t+/-K,:).
diffEqtn = model.Gradient.symb2array(diffEqtn);

end%

