% postparse  Postparse model code
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function this = postparse(this, qty, eqn, log, euc, puc, collector, opt, optimalOpt)

exception.ParseTime.storeFileName(this.FileName);

%
% __Retrieve data preprocessors and postprocessors__
%
processorLhsNames = string.empty(1, 0);
for processor = ["Preprocessor", "Postprocessor"]
    collector.(processor) = regexprep(collector.(processor), "\s+", "");
    if ~isempty(collector.(processor))
        mf = ModelSource( );
        mf.FileName = this.FileName;
        mf.Code = collector.(processor);
        mf.Preparsed = true;
        this.(processor) = Explanatory.fromFile(mf);
        [this.(processor).Context] = deal(processor);
        this.(processor) = initializeLogStatus(this.(processor), log);
        processorLhsNames = [processorLhsNames, reshape(collectLhsNames(this.(processor)), 1, [])]; %#ok<AGROW>
    end
end

%
% Initialize log status of names from the !log-variables section
% and report invalid names
%
qty = initializeLogStatus(qty, log, processorLhsNames);


%
% Reporting Equations
%

% Check for name conflicts between LHS names in reporting equations and
% model names
if any(eqn.Type==6)
    this.Reporting = rpteq(eqn, euc, this.FileName);
    [flag, conflictsWithinReporting] = textual.nonunique(this.Reporting.NamesOfLhs);
    if flag
        exception.error([
            "Model:Postparse:NameConflictsReportingEquations"
            "This LHS reporting variable name is used more than once: %s"
        ], string(conflictsWithinReporting));
    end
    checkList = [qty.Name, this.Reporting.NamesOfLhs];
    [flag, conflictsBetweenReportingAndModel] = textual.nonunique(checkList);
    if flag
        exception.error([
            "Model:Postparse:NameConflictsReportingEquations"
            "This LHS reporting variable name already exists in the model: %s"
        ], string(conflictsBetweenReportingAndModel));
    end
end


% __Presence of loss function__
% Search transition equations for loss function; if found move it down to
% last position among transition equations
try
    [eqn, euc, isOptimal] = findLossFunc(eqn, euc);
catch exc
    throw( exception.Rethrow(exc) );
end

% Max lag and lead in measurement and transition equations
inxMT = eqn.Type==1 | eqn.Type==2;
maxSh = max([ euc.MaxShDynamic(inxMT), euc.MaxShSteady(inxMT) ]);
minSh = min([ euc.MinShDynamic(inxMT), euc.MinShSteady(inxMT) ]);
if isOptimal
    % Anticipate that multipliers will have leads as far as the greatest
    % lag, and lags as far as the greatest lead.
    maxSh = max([maxSh, -minSh]);
    minSh = min([minSh, -maxSh]);
end

% __Read measurement and transition equations__
try
    eqn = readEquations(eqn, euc);
catch exc
    throw( exception.Rethrow(exc) );
end


% Check for empty dynamic parts in measurement and transition equations.
% This may occur if the user types a semicolon between the full equations
% and its steady state version.
hereCheckEmptyEqtn( );


% __Placeholders for optimal policy equations__

% Position of loss function
posLossEqtn = NaN;

% Presence of floor constraints on policy variables
hasFloors = false;

% Positions of the floor variable, floor multiplier and floor parameter
posFloorVariable = [];
posFloorMultiplier = [];
posFloorParameter = [];

% Name of the multiplier associated with nonegativity constraint.
floorVariableName = '';
if  isOptimal
    % Create placeholders for new transition names (multipliers) and new
    % transition equations (derivatives of the loss function wrt existing
    % variables).
    prefix = optimalOpt.MultiplierPrefix;
    ixInvalidRef = strncmp(qty.Name, prefix, length(prefix));
    if any(ixInvalidRef)
        exception.error([
            "Parser:MultiplierPrefix"
            "This name starts with a prefix reserved for Lagrange multipliers in optimal policy models; "
            "change the name: %s "
        ], string(qty.Name{ixInvalidRef})); ...
    end
    hereCreatePlaceholdersForOptimal( );
end


% __Seal model quantities__
% * Add special names (exogenous ttrend)
% * Save original names
% * Populate transient properties
qty = seal(qty);


% __Read dtrend equations and pairings__
% Read them after placeholders for optimal policy have been created
try
    [eqn, this.Pairing.Dtrends] = readDtrends(eqn, euc, qty);
    this.Pairing.Autoswaps = model.Pairing.readAutoswaps(qty, puc);
    this.Pairing.Assignments = model.Pairing.readAssignments(eqn, euc, qty);
catch exc
    throw(exception.Rethrow(exc));
end


% __Postprocess equations__

numQuant = numel(qty.Name);
numEqtn = numel(eqn.Input);
inxM = eqn.Type==1;
inxT = eqn.Type==2;
inxD = eqn.Type==3;
inxL = eqn.Type==4;

% Remove blank spaces
eqn.Input = regexprep(eqn.Input, {'\s+', '".*?"'}, {'', ''});
eqn.Dynamic = regexprep(eqn.Dynamic, '\s+', '');
eqn.Steady = regexprep(eqn.Steady, '\s+', '');

% Make sure all equations end with semicolons
eqn = locallyEnsureSemicolon(eqn);


%
% __Postparse Equations__
%

% Check for steady references in the wrong equations
% eqn.Dynamic(cellfun('isempty', eqn.Dynamic)) = {''};
% eqn.Steady(cellfun('isempty', eqn.Steady)) = {''};
hereCheckSteadyRef( );
try
    eqn = postparse(eqn, qty);
catch exc
    throw(exception.Rethrow(exc));
end

if isOptimal
    % Retrieve and remove the expression for the discount factor from the
    % parsed optimal policy equation
    close = textfun.matchbrk(eqn.Dynamic{posLossEqtn});
    % Discount factor has been already checked for empty
    lossDisc = eqn.Dynamic{posLossEqtn}(2:close-1);
    eqn.Dynamic{posLossEqtn} = eqn.Dynamic{posLossEqtn}(close+1:end);
end

% Check for orphan { and & after we have substituted for the valid
% references
hereCheckTimeAndSteadyRef( );

% Find the occurences of variables, shocks, and parameters in individual
% equations, including the loss function and its discount factor; the
% occurences in the loss function will be replaced later with the
% occurences in the Lagrangian derivatives.
this.Incidence.Dynamic = model.Incidence(numEqtn, numQuant, minSh, maxSh);
this.Incidence.Steady = model.Incidence(numEqtn, numQuant, minSh, maxSh);
this.Incidence.Dynamic = fill(this.Incidence.Dynamic, qty, eqn.Dynamic, inxM | inxT | inxD | inxL); % [^1]
this.Incidence.Steady = fill(this.Incidence.Steady, qty, eqn.Steady, inxM | inxT);
inxCopy = (inxM | inxT | inxL) & cellfun('isempty', eqn.Steady);   
this.Incidence.Steady.Matrix(inxCopy, :) = this.Incidence.Dynamic.Matrix(inxCopy, :); 
% [^1]: Here, we create incidence also for links but remove any references
% to std or corr; this incidence is only used in steady state solver to
% refresh links. Otherwise, the full !links incidence needed in
% component.model.Link/reorder is created in that file.

% Check equation syntax before we compute optimal policy but after we
% remove the header min(...) from the loss function equation.
if opt.CheckSyntax
    checkSyntax(this, qty, eqn);
end

% Check the model structure before the loss function is processed.
[exc, args] = checkStructureBefore(this, qty, eqn, opt);
if ~isempty(exc)
    throw(exc, args{:});
end

if isOptimal
    % Create optimal policy equations by adding the derivatives of the
    % Lagrangian wrt to the original transition variables. These `naddeqtn` new
    % equation will be put in place of the loss function and the `naddeqtn-1`
    % empty placeholders.
    new = optimalPolicy( ...
        this, qty, eqn ...
        , posLossEqtn, lossDisc ...
        , posFloorVariable, posFloorMultiplier, posFloorParameter ...
        , optimalOpt.Type ...
    ); 

    % Update the placeholders for optimal policy equations in the model
    % object, and parse them.
    last = find(eqn.Type==2, 1, 'last');
    loss2last = posLossEqtn : last;
    eqn.Input(loss2last) = new.Input(loss2last);
    eqn.Dynamic(loss2last) = new.Dynamic(loss2last);

    % Add steady equations. Note that we must at least replace the old equation
    % in `lossPos` position (which was the objective function) with the new
    % equation (which is a derivative wrt to the first variables).
    eqn.Steady(loss2last) = new.Steady(loss2last);

    % Update the nonlinear equation flags.
    eqn.IxHash(loss2last) = new.IxHash(loss2last);

    % Update incidence matrices to include the new equations.
    inxUpdateIncidence = false(size(eqn.Input));
    inxUpdateIncidence(loss2last) = true;
    this.Incidence.Dynamic = fill( ...
        this.Incidence.Dynamic, qty, eqn.Dynamic, inxUpdateIncidence ...
    );
    this.Incidence.Steady = fill( ...
        this.Incidence.Steady, qty, eqn.Steady, inxUpdateIncidence ...
    );
end

% Check the model structure after the loss function is processed.
[exc, args] = checkStructureAfter(this, qty, eqn, opt);
if ~isempty(exc)
    throw(exc, args{:});
end


% Create the Link component
this.Link = model.Link(eqn, euc, qty);


% Reset parsed file name
exception.ParseTime.storeFileName( );


this.Quantity = qty;
this.Equation = eqn;

return

    function hereCheckTimeAndSteadyRef( )
        % Check for { in dynamic and steady equations
        inxOrphan = contains(eqn.Dynamic, '{') | contains(eqn.Steady, '{');
        if any(inxOrphan)
            throw( ...
                exception.ParseTime('Model:Postparser:MISPLACED_TIME_SUBSCRIPT', 'error'), ...
                eqn.Input{inxOrphan} ...
            );
        end
        % Check for & and $ in full and steady-state equations
        inxInvalidRef = contains(eqn.Dynamic, '&') | contains(eqn.Steady, '&');
        if any(inxInvalidRef)
            throw( ...
                exception.ParseTime('Model:Postparser:MISPLACED_STEADY_REFERENCE', 'error'), ...
                eqn.Input{inxInvalidRef} ...
            );
        end
    end%




    function hereCheckSteadyRef( )
        % Check for sstate references in the wrong equations
        inxSteadyRef = contains(eqn.Dynamic, '&') | contains(eqn.Dynamic, '&');
        % Not allowed in deterministic trends
        inx = inxSteadyRef & eqn.Type==3;
        if any(inx)
            throw( ...
                exception.ParseTime('Model:Postparser:SSTATE_REF_IN_DTREND', 'error'), ...
                eqn.Input{inx} ...
            );
        end
        % Not allowed in dynamic links
        inx = inxSteadyRef & eqn.Type==4;
        if any(inx)
            throw( ...
                exception.ParseTime('Model:Postparser:SSTATE_REF_IN_LINK', 'error'), ...
                eqn.Input{inx} ...
            );
        end
    end%


    function hereCreatePlaceholdersForOptimal( )
        % Add new variables, i.e. the Lagrange multipliers associated with all of
        % the existing transition equations except the loss function. These new
        % names will be ordered first -- the final equations will be ordered as
        % derivatives of the lagrangian wrt to the individual variables.
        numEquationsToAdd = sum(qty.Type==2) - 1;
        numQuantitiesToAdd = sum(eqn.Type==2) - 1;

        % The default name is 'Mu_Eq%g' but can be changed through the
        % option MultiplierPrefix=
        newNames = cell(1, numQuantitiesToAdd);
        for ii = 1 : numQuantitiesToAdd
            newNames{ii} = [optimalOpt.MultiplierPrefix, sprintf('Eq%g', ii)];
        end

        hasFloors = false; %~isempty(optimalOpt.NonNegative);
%         if hasFloors
%             numEquationsToAdd = numEquationsToAdd + 1;
%             numQuantitiesToAdd = numQuantitiesToAdd + 1;
%             floorVariableName = string(optimalOpt.MultiplierPrefix) + string(optimalOpt.NonNegative);
%             newNames{end+1} = char(floorVariableName);
%         end

        %
        % Insert the new names between at the beginning of the block of existing
        % transition variables.
        %
        add = model.Quantity.fromNames(newNames);
        add.IxLagrange(:) = true;
        qty = insert(qty, add, 2, 'first');

%         if hasFloors
%             floorParameterName = string(model.Quantity.FLOOR_PREFIX) + string(optimalOpt.NonNegative);
% 
%             % Floor parameter may be declared by the user
%             inxFloorParameter = startsWith(qty.Name, model.Quantity.FLOOR_PREFIX) & qty.Type==4;
%             if any(inxFloorParameter)
%                 posFloorParameter = find(inxFloorParameter);
%             else
%                 add = model.Quantity( );
%                 add.Name = {char(floorParameterName)};
%                 add.Label = {['Floor for ', optimalOpt.NonNegative]};
%                 add.Alias = {char.empty(1, 0)};
%                 add.Attributes = {string.empty(1, 0)};
%                 add.IxLog = false(1, 1);
%                 add.IxLagrange = false(1, 1);
%                 add.IxObserved = false(1, 1);
%                 add.Bounds = repmat(qty.DEFAULT_BOUNDS, 1, 1);
%                 [qty, inxPre] = insert(qty, add, 4, 'last');
%                 posFloorParameter = find(inxPre, 1, 'last') + 1;
%             end
%         end

        % Loss function is always moved to last position among transition equations.
        posLossEqtn = numel(eqn.Input);
%         if hasFloors
%             % Find the position of floored variables in the list of names AFTER we
%             % have inserted placeholders.
%             inxFloorVariable = strcmp(optimalOpt.NonNegative, qty.Name);
%             if ~any(inxFloorVariable) ...
%                     || qty.Type(inxFloorVariable)~=int8(2)
%                 throw( ...
%                     exception.ParseTime('Model:Postparser:NAME_CANNOT_BE_NONNEGATIVE', 'error'), ...
%                     optimalOpt.NonNegative ...
%                 );
%             end
%             posFloorVariable = find(inxFloorVariable);
%             posFloorMultiplier = find(strcmp(qty.Name, floorVariableName));
%         end

        %
        % Add a total of `numEquationsToAdd` new transition equations, i.e. the
        % derivatives of the Lagrangian wrt the existing transition
        % variables. At the same time, remove the loss function so
        % a total of `numEquationsToAdd-1` placeholders need to be created.
        %
        add = model.Equation( );
        add.Input = repmat({''}, 1, numEquationsToAdd);
        add.Label = repmat({''}, 1, numEquationsToAdd);
        add.Alias = repmat({''}, 1, numEquationsToAdd);
        add.Attributes = repmat({string.empty(1, 0)}, 1, numEquationsToAdd);
        add.Dynamic = repmat({''}, 1, numEquationsToAdd);
        add.Steady = repmat({''}, 1, numEquationsToAdd);
        add.IxHash = false(1, numEquationsToAdd);
        [eqn, ~, ~, posLoss] = insert(eqn, add, 2, 'last');

        add = parser.EquationUnderConstruction( );
        add.LhsDynamic = repmat({''}, 1, numEquationsToAdd);
        add.RhsDynamic = repmat({''}, 1, numEquationsToAdd);
        add.SignDynamic = repmat({''}, 1, numEquationsToAdd);
        add.LhsSteady = repmat({''}, 1, numEquationsToAdd);
        add.RhsSteady = repmat({''}, 1, numEquationsToAdd);
        add.SignSteady = repmat({''}, 1, numEquationsToAdd);
        add.MaxShDynamic = zeros(1, numEquationsToAdd);
        add.MaxShSteady = zeros(1, numEquationsToAdd);
        add.MinShDynamic = zeros(1, numEquationsToAdd);
        add.MinShSteady = zeros(1, numEquationsToAdd);
        euc = insert(euc, add, [], posLoss);
    end%


    function hereCheckEmptyEqtn( )
        inxTM = eqn.Type==1 | eqn.Type==2;
        ixEmpty = cellfun('isempty', eqn.Dynamic) & inxTM;
        if any(ixEmpty)
            throw( ...
                exception.ParseTime('Model:Postparser:DYNAMIC_EQUATION_EMPTY', 'error'), ...
                eqn.Input{ixEmpty} ...
            );
        end
    end%
end%


%
% Local Functions
%


function eqn = locallyEnsureSemicolon(eqn)
    for i = 1 : numel(eqn.Input)
        if ~isempty(eqn.Input{i}) && eqn.Input{i}(end)~=';'
            eqn.Input{i}(end+1) = ';';
        end
        if ~isempty(eqn.Dynamic{i}) && eqn.Dynamic{i}(end)~=';'
            eqn.Dynamic{i}(end+1) = ';';
        end
        if ~isempty(eqn.Steady{i}) && eqn.Steady{i}(end)~=';'
            eqn.Steady{i}(end+1) = ';';
        end
    end
end%

