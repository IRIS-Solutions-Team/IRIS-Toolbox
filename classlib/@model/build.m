function this = build(this, opt)
% build  Build or rebuild model object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

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
        dftStd = opt.stdlinear;
    else
        dftStd = opt.stdnonlinear;
    end
else
    dftStd = opt.std;
end

nAlt = 1;
if ~isempty(asgn) ...
        && isstruct(asgn) ...
        && ~isempty(fieldnames(asgn))
    % Check number of alternative parametrizations in input database, exclude shocks.
    lsName = [ ...
        this.Quantity.Name, ...
        getStdName(this.Quantity), ...
        getCorrName(this.Quantity), ...
        ];
    for i = 1 : length(lsName)
        if isfield(asgn, lsName{i}) && isnumeric(asgn.(lsName{i}))
            asgn.(lsName{i}) = asgn.(lsName{i})(:).';
            nAlt = max(nAlt, length(asgn.(lsName{i})));
        end
    end
end

% Reset the ordering of !links, and reorder if requested.
this = reorderLinks(this, opt);

% Pre-compute symbolic derivatives of
% * transition and measurement equations wrt variables (if symbdiff=true),
% * dtrends equations wrt parameters (always).
this = symbDiff(this, opt.symbdiff);

% Convert model equations to anonymous functions.
this = myeqtn2afcn(this);

% Create Deriv to System convertor.
this = myd2s(this, opt);

% Recreate transient properties.
this = populateTransient(this);

nh = sum(this.Equation.IxHash);
nExpand = 0;
template = model.Variant(this.Quantity, this.Vector, nExpand, nh, dftStd);
this.Variant = repmat({template}, 1, nAlt);

% Preallocate solution matrices. This must be done after populating
% transient properties because of Vector.System.
preallocSolution( );

this = assign(this, asgn);

% Refresh dynamic links after assigning parameters.
if opt.Refresh
    this = refresh(this);
end

return




    function preallocSolution( )
        [ny, ~, nb, nf, ne] = sizeOfSolution(this.Vector);
        [~, ~, ~, kf] = sizeOfSystem(this.Vector);
        
        this.solution{1} = nan(nf+nb, nb, nAlt); % T
        this.solution{2} = nan(nf+nb, ne, nAlt); % R
        this.solution{3} = nan(nf+nb, 1, nAlt); % K
        this.solution{4} = nan(ny, nb, nAlt); % Z
        this.solution{5} = nan(ny, ne, nAlt); % H
        this.solution{6} = nan(ny, 1, nAlt); % D
        this.solution{7} = nan(nb, nb, nAlt); % U
        this.solution{8} = nan(nf+nb, nh, nAlt); % Y - nonlin addfactors.
        this.solution{9} = nan(ny, nb, nAlt); % ZZ - Untransformed measurement.
        
        this.Expand{1} = nan(nb, kf, nAlt); % Xa
        this.Expand{2} = nan(nf, kf, nAlt); % Xf
        this.Expand{3} = nan(kf, ne, nAlt); % Ru
        this.Expand{4} = nan(kf, kf, nAlt); % J
        this.Expand{5} = nan(kf, kf, nAlt); % J^k
        this.Expand{6} = nan(kf, nh, nAlt); % Mu -- nonlin addfactors.
    end
end
