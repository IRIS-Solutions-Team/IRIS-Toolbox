function this = build(this, opt)

context = opt.Context;

% Assign user comment if it is non-empty, otherwise use what has been
% found in the model code.
if ~isempty(opt.Comment) && strlength(opt.Comment)>0
    this.Comment = opt.Comment;
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
    if this.LinearStatus
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
% * measurement trends equations wrt parameters (always).
% Convert string equations to anonymous functions
temp = struct();
temp.Symbolic = opt.symbdiff;
temp.DiffOutput = "array";
this.Gradient = differentiate(this, temp);


% Convert measurement trends, links and gradients to anonymous functions
this = functionsFromEquations(this);


% Create Deriv to System convertor
this = createD2S(this, opt);


% Populate transient properties
this = populateTransient(this);


%
% Preallocate variants
%
lenExpansion = 0;
numHashed = nnz(this.Equation.IxHash);
numObserved = nnz(this.Quantity.IxObserved);
numQuants = numel(this.Quantity);
defaultFloor = 0;
preallocateFunc = getPreallocateFunc(this);
numVariants = locallyGetNumVariants(this.Quantity, context);
this.Variant = model.Variant( ...
    numVariants, this.Quantity, this.Vector, lenExpansion, numHashed, numObserved, ...
    defaultStd, defaultFloor, preallocateFunc ...
);


%
% Assign values that are zero by default
%
inxZero.Level = false(1, numQuants);
inxZero = prepareZeroSteady(this, inxZero);
this.Variant.Values(1, inxZero.Level, :) = 0;


%
% Assign from input database; this must be done after creating
% this.Variant and assigning default zeros
%
this = assign(this, context);


%
% Refresh dynamic links after assigning parameters
%
if opt.Refresh
    this = refresh(this);
end

end%

%
% Local functions
%

function numVariants = locallyGetNumVariants(quantity, context)
    %(
    numVariants = 1;
    if ~isempty(context) && isstruct(context) 
        % Check number of alternative parametrizations in input database.
        listFields = fieldnames(context);
        ell = lookup(quantity, listFields);
        listFields(isnan(ell.PosName) & isnan(ell.PosStdCorr)) = [ ];
        for n = reshape(string(listFields), 1, [])
            if isnumeric(context.(n))
                numVariants(end+1) = numel(context.(n));
            end
        end
        numVariants = max(numVariants);
    end
    %)
end%

