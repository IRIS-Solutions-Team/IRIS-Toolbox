
function int = hpdi(this, coverage, dim)

% >=R2019b
%{
arguments
    this Series
    coverage (1, 1) double {mustBePositive}
    dim (1, 1) double {mustBeInteger, mustBePositive} = 2
end
%}
% >=R2019b


% <=R2019a
%(
try, dim;
    catch, dim = 2;
end
%)
% <=R2019a


    int = unop(@series.hpdi, this, dim, coverage, dim);

end%

