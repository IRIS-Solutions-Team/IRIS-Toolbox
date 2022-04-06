function likOpt = prepareFreqlOptions(this, range, varargin)
% prepareFreqlOptions  Prepare likelihood function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.prepareFreqlOptions');
    addParameter(pp, 'Band', [2, Inf], @(x) isnumeric(x) && length(x)==2);
    addParameter(pp, 'InxToExclude', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || isa(x, 'string') || islogical(x));
    addParameter(pp, {'ReturnObjFuncContribs', 'ObjCont', 'ObjDecomp'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'OutOfLik', { }, @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addParameter(pp, 'Relative', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Zero', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Deviation', false, @validate.logicalScalar);
    addParameter(pp, 'EvalTrends', logical.empty(1, 0));
end
likOpt = pp.parser(varargin{:});

if isempty(likOpt.EvalTrends)
    likOpt.EvalTrends = ~likOpt.Deviation;
end

%--------------------------------------------------------------------------

[ny, ~, nb] = sizeSolution(this.Vector);
nz = nnz(this.Quantity.IxObserved);
numPeriods = length(range);

% Conditioning measurement variables.
if nz>0
    likOpt.Condition = false(1, nz);
else
    [~, likOpt.InxToExclude] = userSelection2Index( this.Quantity, ...
                                                    likOpt.exclude, 1 );
end

% Out-of-lik parameters
if isempty(likOpt.OutOfLik)
    likOpt.OutOfLik = [ ];
else
    if ischar(likOpt.OutOfLik)
        likOpt.OutOfLik = regexp(likOpt.OutOfLik, '\w+', 'match');
    end
    likOpt.OutOfLik = likOpt.OutOfLik(:)';
    ell = lookup(this.Quantity, likOpt.OutOfLik, 4);
    pos = ell.PosName;
    inxOfNaN = isnan(pos);
    if any(inxOfNaN)
        throw( exception.Base('Model:InvalidName', 'error'), ...
               'parameter ', likOpt.OutOfLik{inxOfNaN} ); %#ok<GTARG>
    end
    likOpt.OutOfLik = pos;
end
likOpt.OutOfLik = likOpt.OutOfLik(:).';
npout = length(likOpt.OutOfLik);
if npout>0 && ~likOpt.EvalTrends
    THIS_ERROR  = { 'Model:CannotEstimateOutOfLik'
                    'Cannot estimate out-of-likelihood parameters with the option DTrends=false' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

end%

