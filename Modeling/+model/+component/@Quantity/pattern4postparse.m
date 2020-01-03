function [rpl, rplSx] = pattern4postparse(this, lsStdCorr)
% pattern4postparse  Patterns and replacements for names in equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

nQuan = length(this.Name);

% Name patterns to search.
% ptn = strcat('\<', this.Name, '\>');
% ptn = this.Name;
% Replace parameter names including steady-state references and time
% subscripts; these are allowed but ignored.
% ###### ptn(ixp) = strcat('&?', ptn(ixp), '((\{[^\}]+\})?)');

% Replacements in dynamic equations.
% Replacements in dtrends.
rpl = cell(1, nQuan);
for i = 1 : nQuan
    rpl{i} = sprintf('%g', i);
end
rpl = strcat('x(', rpl, ',t)');

nStdCorr = length(lsStdCorr);
ell = lookup(this, lsStdCorr);
ixValid = ~isnan(ell.PosStdCorr);

if any(~ixValid)
    throw( exception.Base('Quantity:INVALID_STD_CORR_IN_LINK', 'error'), ...
        lsStdCorr{~ixValid} );
end

% Replacements for std_ and corr_ in links.
rplSx = cell(1, nStdCorr);
for i = 1 : nStdCorr
    rplSx{i} = sprintf('%g', nQuan+ell.PosStdCorr(i));
end
rplSx = strcat('x(', rplSx, ',t)');

end
