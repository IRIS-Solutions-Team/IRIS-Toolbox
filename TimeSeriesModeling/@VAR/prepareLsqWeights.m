function W = prepareLsqWeights(this, opt)
% prepareLsqWeights  Vector of period weights for VAR estimation
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

extdRange = this.Range;
numExtdPeriods = numel(extdRange);
order = opt.Order;
numGroups = max(1, this.NumGroups);

isTimeWeights = ~isempty(opt.TimeWeights) && isa(opt.TimeWeights, 'Series');
isGrpWeights = ~isempty(opt.GroupWeights);

if ~isTimeWeights && ~isGrpWeights
    W = [ ];
    return
end

% Time weights
if isTimeWeights
    Wt = opt.TimeWeights(extdRange, :);
    Wt = Wt(:).';
    Wt = repmat(Wt, 1, numGroups);
else
    Wt = ones(1, numExtdPeriods);
end

% Group weights
if isGrpWeights
    Wg = opt.GroupWeights(:).';
    hereCheckGroupWeights( );
else
    Wg = ones(1, numGroups);
end

% Total weights
W = [ ];
for i = 1 : numGroups
    W = [W, Wt*Wg(i), nan(1, order)]; %#ok<AGROW>
end
W(W == 0) = NaN;
if all(isnan(W(:)))
    W = [ ];
end
   
return


    function hereCheckGroupWeights( )
        if numel(Wg)~=numGroups
            thisError = [
                "VAR:InvalidGroupWeights"
                "The length of the vector of group weights (%g) must "
                "match the number of groups in the panel VAR object (%g)."
            ];
            throw( ...
                exception.Base(thisError, 'error'), ...
                numel(Wg), numGroups ...
            );
        end%
    end% 
end%

