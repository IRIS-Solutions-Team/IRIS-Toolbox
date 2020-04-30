function this = postparse(this, qty, eqn, log, euc, puc, collector, opt, optimalOpt)
% postparse  Postparse model code
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

exception.ParseTime.storeFileName(this.FileName);

%
% Data preprocessor and postprocessor
%
removeFromLog = string.empty(1, 0);
for processor = ["Preprocessor", "Postprocessor"]
    collector.(processor) = regexprep(collector.(processor), '\s+', '');
    if ~isempty(collector.(processor))
        f = model.File( );
        f.FileName = this.FileName;
        f.Code = collector.(processor);
        f.Preparsed = true;
        this.(processor) = ExplanatoryEquation.fromFile(f);
        [this.(processor).Context] = deal("Preprocessor");
        this.(processor) = initializeLogStatus(this.(processor), log);
        removeFromLog = [removeFromLog, reshape(collectLhsNames(this.(processor)), 1, [ ])];
    end
end
if ~isempty(removeFromLog)
    log = setdiff(log, removeFromLog);
end


%
% Initialize log status of names from the !log-variables section
% and report invalid names
%
qty = initializeLogStatus(qty, log);


%
% Reporting Equations
%

% Check for name conflicts between LHS names in reporting equations and
% model names
if any(eqn.Type==TYPE(6))
    this.Reporting = rpteq(eqn, euc, this.FileName);
    conflictsWithinReporting = parser.getMultiple(this.Reporting.NamesOfLhs);
    if ~isempty(conflictsWithinReporting)
        thisError = { 'Model:Postparse:NameConflictsWithinReporting'
                      'This LHS reporting variable name is used more than once: %s' };
        throw( exception.ParseTime(thisError, 'error'), ...
               conflictsWithinReporting{:} );
    end
    checkList = [qty.Name, this.Reporting.NamesOfLhs];
    conflictsBetweenReportingAndModel = parser.getMultiple(checkList);
    if ~isempty(conflictsBetweenReportingAndModel)
        throw( exception.ParseTime('Model:Postparser:REPORTING_NAME_CONFLICT', 'error'), ...
               conflictsBetweenReportingAndModel{:} );
    end
end

%
% Presence of Loss Function
%

% Search transition equations for loss function; if found move it down to
% last position among transition equations
try
    [eqn, euc, isOptimal] = findLossFunc(eqn, euc);
catch exc
    throw( exception.Rethrow(exc) );
end

%
% Max lag and lead in measurement and transition equations
%
inxMT = eqn.Type==TYPE(1) | eqn.Type==TYPE(2);
maxSh = max([ euc.MaxShDynamic(inxMT), euc.MaxShSteady(inxMT) ]);
minSh = min([ euc.MinShDynamic(inxMT), euc.MinShSteady(inxMT) ]);
if isOptimal
    % Anticipate that multipliers will have leads as far as the greatest
    % lag, and lags as far as the greatest lead.
    maxSh = maxSh - minSh;
    minSh = minSh - maxSh;    
end

%
% Read Measurement and Transition Equations
%
try
    eqn = readEquations(eqn, euc);
catch exc
    throw( exception.Rethrow(exc) );
end

% Check for empty dynamic parts in measurement and transition equations.
% This may occur if the user types a semicolon between the full equations
% and its steady state version.
hereCheckEmptyEqtn( );

%
% Placeholders for Optimal Policy Equations
%

% Position of loss function
posLossEqtn = NaN;
% Presence of a floor constraint
isFloor = false;
% Positions of the floor variable, floor multiplier and floor parameter
posFloorVariable = [ ];
posFloorMultiplier = [ ];
posFloorParameter = [ ];
% Name of the multiplier associated with nonegativity constraint.
floorVariableName = '';
if  isOptimal
    % Create placeholders for new transition names (mutlipliers) and new
    % transition equations (derivatives of the loss function wrt existing
    % variables).
    prefix = optimalOpt.MultiplierPrefix;
    ixInvalidRef = strncmp(qty.Name, prefix, length(prefix));
    if any(ixInvalidRef)
        throw( ...
            exception.ParseTime('Model:Postparser:PREFIX_MULTIPLIER', 'error'), ...
            qty.Name{ixInvalidRef} ...
        );
    end
    hereCreatePlaceholdersForOptimal( );
end

%
% Read DTrends and Pairings
%

% Read them after placeholders for optimal policy have been created
try
    [eqn, this.Pairing.Dtrend] = readDtrends(eqn, euc, qty);
    this.Pairing.Autoswap = model.component.Pairing.readAutoswap(qty, puc);
    this.Pairing.Assignment = model.component.Pairing.readAssignments(eqn, euc, qty);
catch exc
    throw(exception.Rethrow(exc));
end

%
% Postprocess Equations
%
numQuant = numel(qty.Name);
numEqtn = numel(eqn.Input);
inxM = eqn.Type==TYPE(1);
inxT = eqn.Type==TYPE(2);
inxD = eqn.Type==TYPE(3);
inxL = eqn.Type==TYPE(4);

% Remove blank spaces
eqn.Input = regexprep(eqn.Input, {'\s+', '".*?"'}, {'', ''});
eqn.Dynamic = regexprep(eqn.Dynamic, '\s+', '');
eqn.Steady = regexprep(eqn.Steady, '\s+', '');

% Make sure all equations end with semicolons
eqn = locallyEnsureSemicolon(eqn);


%
% Postparse Equations
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
this.Incidence.Dynamic = model.component.Incidence(numEqtn, numQuant, minSh, maxSh);
this.Incidence.Steady = model.component.Incidence(numEqtn, numQuant, minSh, maxSh);
this.Incidence.Dynamic = fill(this.Incidence.Dynamic, qty, eqn.Dynamic, inxM | inxT | inxD | inxL); % [^1]
this.Incidence.Steady = fill(this.Incidence.Steady, qty, eqn.Steady, inxM | inxT);
inxCopy = (inxM | inxT | inxL) & cellfun('isempty', eqn.Steady);   
this.Incidence.Steady.Matrix(inxCopy, :) = this.Incidence.Dynamic.Matrix(inxCopy, :); 
% [^1]: Here, we create incidence also for links but remove any references
% to std or corr; this incidence is only used in steady state solver to
% take into account links. Otherwise, the full !links incidence needed in
% component.model.Link/reorder is created in that file.

% Check equation syntax before we compute optimal policy but after we
% remove the header min(...) from the loss function equation.
if opt.CheckSyntax
    checkSyntax(this, qty, eqn);
end

% Check the model structure before the loss function is processed.
[exc, args] = chkStructureBefore(this, qty, eqn);
if ~isempty(exc)
    throw(exc, args{:});
end

if isOptimal
    % Create optimal policy equations by adding the derivatives of the
    % Lagrangian wrt to the original transition variables. These `naddeqtn` new
    % equation will be put in place of the loss function and the `naddeqtn-1`
    % empty placeholders.
    new = optimalPolicy( this, qty, eqn, ...
                         posLossEqtn, lossDisc, ...
                         posFloorVariable, posFloorMultiplier, posFloorParameter, ...
                         optimalOpt.Type ); 

    % Update the placeholders for optimal policy equations in the model object, and parse them.
    last = find(eqn.Type==2, 1, 'last');
    eqn.Input(posLossEqtn:last) = new.Input(posLossEqtn:last);
    eqn.Dynamic(posLossEqtn:last) = new.Dynamic(posLossEqtn:last);
    
    % Add steady equations. Note that we must at least replace the old equation
    % in `lossPos` position (which was the objective function) with the new
    % equation (which is a derivative wrt to the first variables).
    eqn.Steady(posLossEqtn:last) = new.Steady(posLossEqtn:last);
    % Update the nonlinear equation flags.
    eqn.IxHash(posLossEqtn:last) = new.IxHash(posLossEqtn:last);
    
    % Update incidence matrices to include the new equations.
    indexUpdateIncidence = false(size(eqn.Input));
    indexUpdateIncidence(posLossEqtn:last) = true;
    this.Incidence.Dynamic = fill( ...
        this.Incidence.Dynamic, qty, eqn.Dynamic, indexUpdateIncidence ...
    );
    this.Incidence.Steady = fill( ...
        this.Incidence.Steady, qty, eqn.Steady, indexUpdateIncidence ...
    );
end

% Check the model structure after the loss function is processed.
[exc, args] = chkStructureAfter(this, qty, eqn);
if ~isempty(exc)
    throw(exc, args{:});
end


% 
% Create the Link component
%
this.Link = model.component.Link(eqn, euc, qty);


%
% Reset parsed file name
%
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
        inx = inxSteadyRef & eqn.Type==TYPE(3);
        if any(inx)
            throw( ...
                exception.ParseTime('Model:Postparser:SSTATE_REF_IN_DTREND', 'error'), ...
                eqn.Input{inx} ...
            );
        end
        % Not allowed in dynamic links
        inx = inxSteadyRef & eqn.Type==TYPE(4);
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
        numEquationsToAdd = sum(qty.Type==TYPE(2)) - 1;
        numQuantitiesToAdd = sum(eqn.Type==TYPE(2)) - 1;
        % The default name is 'Mu_Eq%g' but can be changed through the
        % option MultiplierPrefix=
        newName = cell(1, numQuantitiesToAdd);
        for ii = 1 : numQuantitiesToAdd
            newName{ii} = [ ...
                optimalOpt.MultiplierPrefix, ...
                sprintf('Eq%g', ii) ...
                ];
        end
        isFloor = ~isempty(optimalOpt.Floor);
        if isFloor
            numEquationsToAdd = numEquationsToAdd + 1;
            numQuantitiesToAdd = numQuantitiesToAdd + 1;
            floorVariableName = [ ...
                optimalOpt.MultiplierPrefix, ...
                optimalOpt.Floor ...
            ];
            newName{end+1} = floorVariableName;
        end
        % Insert the new names between at the beginning of the block of existing
        % transition variables.
        add = model.component.Quantity( );
        add.Name = newName;
        add.Label = repmat({char.empty(1, 0)}, 1, numQuantitiesToAdd);
        add.Alias = repmat({char.empty(1, 0)}, 1, numQuantitiesToAdd);
        add.IxLog = false(1, numQuantitiesToAdd);
        add.IxLagrange = true(1, numQuantitiesToAdd);
        add.IxObserved = false(1, numQuantitiesToAdd);
        add.Bounds = repmat(qty.DEFAULT_BOUNDS, 1, numQuantitiesToAdd);
        qty = insert(qty, add, TYPE(2), 'first');
        if isFloor
            floorParameterName = [model.FLOOR_PREFIX, optimalOpt.Floor];
            inxFloorParameter = strcmp(qty.Name, floorParameterName);
            % Floor parameter may be declared by the user
            if any(inxFloorParameter)
                posFloorParameter = find(inxFloorParameter);
            else
                add = model.component.Quantity( );
                add.Name = {floorParameterName};
                add.Label = {['Floor for ', optimalOpt.Floor]};
                add.Alias = {char.empty(1, 0)};
                add.IxLog = false(1, 1);
                add.IxLagrange = false(1, 1);
                add.IxObserved = false(1, 1);
                add.Bounds = repmat(qty.DEFAULT_BOUNDS, 1, 1);
                [qty, inxPre] = insert(qty, add, TYPE(4), 'last');
                posFloorParameter = find(inxPre, 1, 'last') + 1;
            end
        end
        
        % Loss function is always moved to last position among transition equations.
        posLossEqtn = length(eqn.Input);
        if isFloor
            % Find the position of floored variables in the list of names AFTER we
            % have inserted placeholders.
            inxFloorVariable = strcmp(optimalOpt.Floor, qty.Name);
            if ~any(inxFloorVariable) ...
                    || qty.Type(inxFloorVariable)~=int8(2)
                throw( ...
                    exception.ParseTime('Model:Postparser:NAME_CANNOT_BE_NONNEGATIVE', 'error'), ...
                    optimalOpt.Floor ...
                );
            end
            posFloorVariable = find(inxFloorVariable);
            posFloorMultiplier = find( strcmp(qty.Name, floorVariableName) );
        end
        
        % Add a total of `numEquationsToAdd` new transition equations, i.e. the
        % derivatives of the Lagrangian wrt the existing transition
        % variables. At the same time, remove the loss function so
        % a total of `numEquationsToAdd-1` placeholders need to be created.
        add = model.component.Equation( );
        add.Input = repmat({''}, 1, numEquationsToAdd);
        add.Label = repmat({''}, 1, numEquationsToAdd);
        add.Alias = repmat({''}, 1, numEquationsToAdd);
        add.Dynamic = repmat({''}, 1, numEquationsToAdd);
        add.Steady = repmat({''}, 1, numEquationsToAdd);
        add.IxHash = false(1, numEquationsToAdd);
        [eqn, ixPre, ixPost] = insert(eqn, add, TYPE(2), 'last');

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
        insert(euc, add, ixPre, ixPost);
    end%




    function hereCheckEmptyEqtn( )
        inxTM = eqn.Type==TYPE(1) | eqn.Type==TYPE(2);
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

