function this = aroc(this, varargin)
% aroc  Annualized gross rate of change
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     x = aroc(x, ~shift)
%
%
% ## Input Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] - 
% Input time series.
%
% __`~shift=-1`__ [ numeric ] - 
% Time shift, i.e. the number of periods over which the rate of change will
% be calculated.
%
%
% ## Output Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] - 
% Annualized percentage rate of change in the input data.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.aroc');
    parser.addRequired('inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    parser.addOptional('shift', -1, @(x) validate.numericScalar(x) && x==round(x));
    parser.addOptional('power', @auto, @(x) isequal(x, @auto) || validate.numericScalar(x) );
end
parser.parse(this, varargin{:});
shift = parser.Results.shift;
power = parser.Results.power;

if isequal(power, @auto)
    freq = DateWrapper.getFrequencyAsNumeric(this.Start);
    if freq==0
        power = 1;
    elseif abs(shift)==1
        power = freq;
    else
        power = freq / abs(shift);
    end
end

%--------------------------------------------------------------------------

if isempty(this.Data)
    return
end

this = unop(@numeric.roc, this, 0, shift, power);

end%

