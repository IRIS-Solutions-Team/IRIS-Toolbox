function W = myglsqweights(this, opt)
% myglsqweights  Vector of period weights for VAR estimation
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

extendedRange = this.Range;
numExtendedPeriods = length(extendedRange);
p = opt.Order;

if ispanel(this)
    numGroups = length(this.GroupNames);
else
    numGroups = 1;
end

isTimeWeights = ~isempty(opt.TimeWeights) && isa(opt.TimeWeights, 'tseries');
isGrpWeights = ~isempty(opt.GroupWeights);

if ~isTimeWeights && ~isGrpWeights
    W = [ ];
    return
end

% Time weights
if isTimeWeights
    Wt = opt.TimeWeights(extendedRange, :);
    Wt = Wt(:).';
    Wt = repmat(Wt, 1, numGroups);
else
    Wt = ones(1, numExtendedPeriods);
end

% Group weights
if isGrpWeights
    Wg = opt.GroupWeights(:).';
    checkGroupWeights( );
else
    Wg = ones(1, numGroups);
end

% Total weights
W = [ ];
for iGrp = 1 : numGroups
    W = [W, Wt*Wg(iGrp), nan(1, p)]; %#ok<AGROW>
end
W(W == 0) = NaN;
if all(isnan(W(:)))
    W = [ ];
end
   
return


    function checkGroupWeights( )
        if length(Wg) ~= numGroups
            utils.error('VAR:myglsqweights', ...
                ['The length of the vector of group weights (%g) must ', ...
                'match the number of groups in the panel VAR object (%g).'], ...
                length(Wg), numGroups);
        end
    end 
end
