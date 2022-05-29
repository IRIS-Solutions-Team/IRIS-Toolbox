% pattern4postparse  Patterns and replacements for names in equations
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [replaceNames, replaceStdCorr] = pattern4postparse(this, listStdCorr)

numQuantities = numel(this.Name);

% Name patterns to search.
% ptn = strcat('\<', this.Name, '\>');
% ptn = this.Name;
% Replace parameter names including steady-state references and time
% subscripts; these are allowed but ignored.
% ###### ptn(ixp) = strcat('&?', ptn(ixp), '((\{[^\}]+\})?)');

% Replacements in dynamic equations
% Replacements in dtrends
replaceNames = cell(1, numQuantities);
for i = 1 : numQuantities
    replaceNames{i} = sprintf('%g', i);
end
replaceNames = strcat('x(', replaceNames, ',t)');

numStdCorr = numel(listStdCorr);
ell = lookup(this, listStdCorr);
inxValid = ~isnan(ell.PosStdCorr);

if any(~inxValid)
    throw( exception.Base('Quantity:INVALID_STD_CORR_IN_LINK', 'error'), ...
        listStdCorr{~inxValid} );
end

% Replacements for std_ and corr_ in links
replaceStdCorr = cell(1, numStdCorr);
for i = 1 : numStdCorr
    replaceStdCorr{i} = sprintf('%g', numQuantities+ell.PosStdCorr(i));
end
replaceStdCorr = strcat('x(', replaceStdCorr, ',t)');

end%

