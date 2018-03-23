function this = build(this, opt)
% build  Build or rebuild model object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

asgn = opt.Assign;

% Assign user comment if it is non-empty, otherwise use what has been
% found in the model code.
if ~isempty(opt.comment)
    this.Comment = opt.comment;
end

% Differentiation step size.
if ~isempty(opt.epsilon)
    this.Tolerance.DiffStep = opt.epsilon;
end

% Time origin (base year) for deterministic trends.
this.BaseYear = opt.baseyear;

if any(this.Equation.IxHash)
    % Do not remove leads from state space vector if there are
    % nonlinearised equations.
    % TODO: More sophisticated check which leads are actually needed in
    % non-linerised equations.
    opt.removeleads = false;
end

% Assign default stdevs.
if isequal(opt.std, @auto)
    if this.IsLinear
        defaultStd = opt.stdlinear;
    else
        defaultStd = opt.stdnonlinear;
    end
else
    defaultStd = opt.std;
end

numOfVariants = 1;
if ~isempty(asgn) && isstruct(asgn) 
    % Check number of alternative parametrizations in input database.
    lsField = fieldnames(asgn);
    ell = lookup(this.Quantity, lsField);
    lsField(isnan(ell.PosName) & isnan(ell.PosStdCorr)) = [ ];
    for i = 1 : numel(lsField)
        name = lsField{i};
        if isnumeric(asgn.(name))
            numOfVariants = max(numOfVariants, numel(asgn.(name)));
        end
    end
end

% Reset the ordering of !links, and reorder if requested.
this.Link = reorder(this.Link, opt);

% Pre-compute symbolic derivatives of
% * transition and measurement equations wrt variables (if symbdiff=true),
% * dtrends equations wrt parameters (always).
this = symbDiff(this, opt.symbdiff);

% Convert model equations to anonymous functions.
this = myeqtn2afcn(this);

% Create Deriv to System convertor.
this = createD2S(this, opt);

% Recreate transient properties.
this = populateTransient(this);

% Preallocate variants.
lenOfExpansion = 0;
numOfHashed = nnz(this.Equation.IxHash);
numOfObserved = nnz(this.Quantity.IxObserved);
this.Variant = model.component.Variant( ...
    numOfVariants, this.Quantity, this.Vector, lenOfExpansion, numOfHashed, numOfObserved, defaultStd ...
);

% Assign from input database. This must be done after creating
% this.Variant.
this = assign(this, asgn);

% Refresh dynamic links after assigning parameters.
if opt.Refresh
    this = refresh(this);
end

end
