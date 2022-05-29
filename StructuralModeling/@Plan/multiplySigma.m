function this = multiplySigma(this, dates, names, varargin)
% assign  Multiply sigmas (std deviations) of exogenous quantities in a simulation Plan
%{
% ## Syntax ##
%
%
%     output = function(input, ...)
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ | ]
% >
% Description
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ | ]
% >
% Description
%
%
% ## Options ##
%
%
% __`OptionName=Default`__ [ | ]
% >
% Description
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('Plan.assign');
    addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
    addRequired(pp, 'datesToAssign', @(x) isequal(x, @all) || validate.date(x));
    addRequired(pp, 'namesToAssign', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    addRequired(pp, 'variantsToAssign', @(x) isequal(x, @all) || isnumeric(x));
    addRequired(pp, 'multiplier', @isnumeric);
end
if numel(varargin)==1
    variants = @all;
    multiplier = varargin{1};
else
    [variants, multiplier] = varargin{:};
end
pp.parse(this, dates, names, variants, multiplier);
opt = pp.Options;

%--------------------------------------------------------------------------

inxDates = resolveDates(this, dates);

context = 'be assigned sigmas';
inxNames = this.resolveNames(names, this.NamesOfExogenous, context);
if ~any(inxNames)
    return
end

inxVariants = resolveVariants(this, variants);

this.SigmasExogenous(inxNames, inxDates, inxVariants) = this.SigmasExogenous(inxNames, inxDates, inxVariants) .* multiplier;

end%

