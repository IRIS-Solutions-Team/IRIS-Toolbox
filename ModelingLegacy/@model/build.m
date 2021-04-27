% build  Build or rebuild model object
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function this = build(this, opt)

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
    % Do not remove leads from state-space vector if there are hashed
    % equations
    % TODO: More sophisticated check which leads are needed in hashed
    % equations
    opt.removeleads = false;
end

% Assign default std deviations
if isequal(opt.DefaultStd, @auto)
    if this.IsLinear
        defaultStd = opt.stdlinear;
    else
        defaultStd = opt.stdnonlinear;
    end
else
    defaultStd = opt.DefaultStd;
end


% Reset the ordering of !links, and reorder if requested.
this.Link = reorder(this.Link, opt);

% Pre-compute symbolic derivatives of
% * transition and measurement equations wrt variables (if symbdiff=true),
% * dtrends equations wrt parameters (always).
% Convert string equations to anonymous functions
this = differentiate(this, opt.symbdiff);

% Create Deriv to System convertor
this = createD2S(this, opt);

% Populate transient properties
this = populateTransient(this);

% Preallocate variants
lenExpansion = 0;
numHashed = nnz(this.Equation.IxHash);
numObserved = nnz(this.Quantity.IxObserved);
defaultFloor = 0;
preallocateFunc = getPreallocateFunc(this);
numVariants = locallyGetNumVariants(this.Quantity, asgn);
this.Variant = model.component.Variant( ...
    numVariants, this.Quantity, this.Vector, lenExpansion, numHashed, numObserved, ...
    defaultStd, defaultFloor, preallocateFunc ...
);

% Assign from input database. This must be done after creating
% this.Variant.
this = assign(this, asgn);

% Refresh dynamic links after assigning parameters.
if opt.Refresh
    this = refresh(this);
end

end%

%
% Local functions
%

function numVariants = locallyGetNumVariants(quantity, asgn)
    %(
    numVariants = 1;
    if ~isempty(asgn) && isstruct(asgn) 
        % Check number of alternative parametrizations in input database.
        listFields = fieldnames(asgn);
        ell = lookup(quantity, listFields);
        listFields(isnan(ell.PosName) & isnan(ell.PosStdCorr)) = [ ];
        for n = reshape(string(listFields), 1, [])
            if isnumeric(asgn.(n))
                numVariants(end+1) = numel(asgn.(n));
            end
        end
        numVariants = max(numVariants);
    end
    %)
end%

