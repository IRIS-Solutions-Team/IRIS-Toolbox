function W = myglsqweights(This,Opt)
% myglsqweights  [Not a public function] Vector of period weights for VAR estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

xRange = This.Range;
nXPer = length(xRange);
p = Opt.order;

if ispanel(This)
    nGrp = length(This.GroupNames);
else
    nGrp = 1;
end

isTimeWeights = ~isempty(Opt.timeweights) && isa(Opt.timeweights,'tseries');
isGrpWeights = ~isempty(Opt.groupweights);

if ~isTimeWeights && ~isGrpWeights
    W = [ ];
    return
end

% Time weights.
if isTimeWeights
    Wt = Opt.timeweights(xRange,:);
    Wt = Wt(:).';
    Wt = repmat(Wt,1,nGrp);
else
    Wt = ones(1,nXPer);
end

% Group weights.
if isGrpWeights
    Wg = Opt.groupweights(:).';
    doChkGrpweights( );
else
    Wg = ones(1,nGrp);
end

% Total weights.
W = [ ];
for iGrp = 1 : nGrp
    W = [W,Wt*Wg(iGrp),nan(1,p)]; %#ok<AGROW>
end
W(W == 0) = NaN;
if all(isnan(W(:)))
    W = [ ];
end
   

% Nested functions...


%**************************************************************************
    
    
    function doChkGrpweights( )
        if length(Wg) ~= nGrp
            utils.error('VAR:myglsqweights', ...
                ['The length of the vector of group weights (%g) must ', ...
                'match the number of groups in the panel VAR object (%g).'], ...
                length(Wg),nGrp);
        end
    end % doChkGrpWeights( )

end