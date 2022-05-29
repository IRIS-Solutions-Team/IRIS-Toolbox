function posh = find(this, eqtnRequest, quanRequest)
% find  Find quantities and their lags/leads in one equation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

t0 = find(this.Shift==0);
nsh = length(this.Shift);
nQuan = size(this.Matrix, 2)/nsh;
inc = this.Matrix(eqtnRequest, :);
inc = reshape(inc, nQuan, nsh);
inc = inc.';
if nargin>2
    if islogical(quanRequest)
        inc(:, ~quanRequest) = false;
    else
        posDisregard = setdiff(1 : nQuan, quanRequest);
        inc(:, posDisregard) = false;
    end
end
[sh, pos] = find(inc);
sh = sh - t0;
pos = pos(:).';
sh = sh(:).';
posh = pos + 1i*sh;

end
