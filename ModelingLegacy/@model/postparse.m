function this = postparse(this, qty, eqn, euc, puc, collector, opt, optimalOpt)
% postparse  Postparse model code
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

exception.ParseTime.storeFileName(this.FileName);

%
% Data preprocessor and postprocessor
%
collector.Preprocessor = regexprep(collector.Preprocessor, '\s+', '');
if ~isempty(collector.Preprocessor)
    f = model.File( );
    f.FileName = this.FileName;
    f.Code = collector.Preprocessor;
    f.Preparsed = true;
    this.Preprocessor = ExplanatoryEquation.fromFile(f);
    [this.Preprocessor.Context] = deal("Preprocessor");
end
collector.Postprocessor = regexprep(collector.Postprocessor, '\s+', '');
if ~isempty(collector.Postprocessor)
    f = model.File( );
    f.FileName = this.FileName;
    f.Code = collector.Postprocessor;
    f.Preparsed = true;
    this.Postprocessor = ExplanatoryEquation.fromFile(f);
    [this.Postprocessor.Context] = deal("Postprocessor");
end

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
% Max Lag and Lead
%
ixmt = eqn.Type==TYPE(1) | eqn.Type==TYPE(2);
maxSh = max([ euc.MaxShDynamic(ixmt), euc.MaxShSteady(ixmt) ]);
minSh = min([ euc.MinShDynamic(ixmt), euc.MinShSteady(ixmt) ]);
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
checkEmptyEqtn( );

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
        throw( exception.ParseTime('Model:Postparser:PREFIX_MULTIPLIER', 'error'), ...
            qty.Name{ixInvalidRef} );
    end
    createPlaceholdersForOptimal( );
end

%
% Read DTrends, Links, Autoswap
%

% Read them after placeholders for optimal policy have been created
try
    [eqn, this.Pairing.Dtrend] = readDtrends(eqn, euc, qty);
    [eqn, this.Link] = readLinks(eqn, euc, qty);
    this.Pairing.Autoswap = model.component.Pairing.readAutoswap(qty, puc);
    this.Pairing.Assignment = model.component.Pairing.readAssignments(eqn, euc, qty);
catch exc
    throw( exception.Rethrow(exc) );
end

%
% Postprocess Equations
%
numQuant = numel(qty.Name);
numEqtn = numel(eqn.Input);
ixm = eqn.Type==TYPE(1);
ixt = eqn.Type==TYPE(2);
ixd = eqn.Type==TYPE(3);
ixmt = ixm | ixt;
ixmtd = ixmt | ixd;

% Remove blank spaces
eqn.Input = regexprep(eqn.Input, {'\s+', '".*?"'}, {'', ''});
eqn.Dynamic = regexprep(eqn.Dynamic, '\s+', '');
eqn.Steady = regexprep(eqn.Steady, '\s+', '');

% Make sure all equations end with semicolons.
for iEq = 1 : length(eqn.Input)
    if ~isempty(eqn.Input{iEq}) && eqn.Input{iEq}(end)~=';'
        eqn.Input{iEq}(end+1) = ';';
    end
    if ~isempty(eqn.Dynamic{iEq}) && eqn.Dynamic{iEq}(end)~=';'
        eqn.Dynamic{iEq}(end+1) = ';';
    end
    if ~isempty(eqn.Steady{iEq}) && eqn.Steady{iEq}(end)~=';'
        eqn.Steady{iEq}(end+1) = ';';
    end
end

%
% Postparse Equations
%
% Check for sstate references occuring in the wrong equations
hereCheckSteadyRef( );

try
    eqn = postparse(eqn, qty);
catch exc
    throw(exception.Rethrow(exc));
end

if isOptimal
    % Retrieve and remove the expression for the discount factor from the
    % parsed optimal policy equation.
    close = textfun.matchbrk(eqn.Dynamic{posLossEqtn});
    % Discount factor has been already checked for empty.
    lossDisc = eqn.Dynamic{posLossEqtn}(2:close-1);
    eqn.Dynamic{posLossEqtn} = eqn.Dynamic{posLossEqtn}(close+1:end);
end

% Check for orphan { and & after we have substituted for the valid
% references.
checkTimeSsref( );

% Find the occurences of variables, shocks, and parameters in individual
% equations, including the loss function and its discount factor. The
% occurences in the loss function will be replaced later with the
% occurences in the Lagrangian derivatives.
this.Incidence.Dynamic = model.component.Incidence(numEqtn, numQuant, minSh, maxSh);
this.Incidence.Steady = model.component.Incidence(numEqtn, numQuant, minSh, maxSh);
this.Incidence.Dynamic = fill(this.Incidence.Dynamic, qty, eqn.Dynamic, ixmtd); % 1/
this.Incidence.Steady = fill(this.Incidence.Steady, qty, eqn.Steady, ixmt);
ixCopy = ixmt & cellfun(@isempty, eqn.Steady);   
this.Incidence.Steady.Matrix(ixCopy, :) = this.Incidence.Dynamic.Matrix(ixCopy, :); 

% 1/ Do not create Incidence matrix for !links because they can have std_
% and corr_ on both LHS and RHS for which Incidence matrix does not have
% columns. Incidence in !links is only needed in model.reorderLinks and is
% created in that file.

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

% Create link object.
ixl = eqn.Type==TYPE(4);
this.Link.Input = eqn.Input(ixl);
this.Link.RhsExpn = eqn.Dynamic(ixl);
eqn.Dynamic(ixl) = {''};

% Reset parsed file name
exception.ParseTime.storeFileName( );
this.Quantity = qty;
this.Equation = eqn;

return

    
    
    
    
    function checkTimeSsref( )
        % Check for { in dynamic and steady equations.
        ixOrphan = ~cellfun( @isempty, strfind(eqn.Dynamic, '{') ) ...
            | ~cellfun( @isempty,strfind(eqn.Steady, '{') ) ;
        if any(ixOrphan)
            throw( ...
                exception.ParseTime('Model:Postparser:MISPLACED_TIME_SUBSCRIPT', 'error'), ...
                eqn.Input{ixOrphan} ...
                );
        end
        % Check for & and $ in full and steady-state equations.
        ixInvalidRef = ~cellfun( @isempty, strfind(eqn.Dynamic, '&') ) ...
            | ~cellfun( @isempty, strfind(eqn.Steady, '&') );
        if any(ixInvalidRef)
            throw( ...
                exception.ParseTime('Model:Postparser:MISPLACED_STEADY_REFERENCE', 'error'), ...
                eqn.Input{ixInvalidRef} ...
                );
        end
    end%




    function hereCheckSteadyRef( )
        % Check for sstate references in the wrong equations
        func = @(c) ~cellfun(@(x) isempty(strfind(x, '&')), c);
        inxSteadyRef = func(eqn.Dynamic) | func(eqn.Steady);
        % Not allowed in deterministic trends.
        inx = inxSteadyRef & eqn.Type==TYPE(3);
        if any(inx)
            throw( exception.ParseTime('Model:Postparser:SSTATE_REF_IN_DTREND', 'error'), ...
                eqn.Input{inx} );
        end
        % Not allowed in dynamic links
        inx = inxSteadyRef & eqn.Type==TYPE(4);
        if any(inx)
            throw( exception.ParseTime('Model:Postparser:SSTATE_REF_IN_LINK', 'error'), ...
                eqn.Input{inx} );
        end
    end%




    function createPlaceholdersForOptimal( )
        % Add new variables, i.e. the Lagrange multipliers associated with all of
        % the existing transition equations except the loss function. These new
        % names will be ordered first -- the final equations will be ordered as
        % derivatives of the lagrangian wrt to the individual variables.
        nAddEqtn = sum(qty.Type==TYPE(2)) - 1;
        nAddQuan = sum(eqn.Type==TYPE(2)) - 1;
        % The default name is 'Mu_Eq%g' but can be changed through the
        % option MultiplierPrefix=
        newName = cell(1, nAddQuan);
        for ii = 1 : nAddQuan
            newName{ii} = [ ...
                optimalOpt.MultiplierPrefix, ...
                sprintf('Eq%g', ii) ...
                ];
        end
        isFloor = ~isempty(optimalOpt.Floor);
        if isFloor
            nAddEqtn = nAddEqtn + 1;
            nAddQuan = nAddQuan + 1;
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
        add.Label = repmat({char.empty(1, 0)}, 1, nAddQuan);
        add.Alias = repmat({char.empty(1, 0)}, 1, nAddQuan);
        add.IxLog = false(1, nAddQuan);
        add.IxLagrange = true(1, nAddQuan);
        add.IxObserved = false(1, nAddQuan);
        add.Bounds = repmat(qty.DEFAULT_BOUNDS, 1, nAddQuan);
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
        
        % Add a total of `nAddEqtn` new transition equations, i.e. the
        % derivatives of the Lagrangian wrt the existing transition
        % variables. At the same time, remove the loss function so
        % a total of `nAddEqtn-1` placeholders need to be created.
        add = model.component.Equation( );
        add.Input = repmat({''}, 1, nAddEqtn);
        add.Label = repmat({''}, 1, nAddEqtn);
        add.Alias = repmat({''}, 1, nAddEqtn);
        add.Dynamic = repmat({''}, 1, nAddEqtn);
        add.Steady = repmat({''}, 1, nAddEqtn);
        add.IxHash = false(1, nAddEqtn);
        [eqn, ixPre, ixPost] = insert(eqn, add, TYPE(2), 'last');

        add = parser.EquationUnderConstruction( );
        add.LhsDynamic = repmat({''}, 1, nAddEqtn);
        add.RhsDynamic = repmat({''}, 1, nAddEqtn);
        add.SignDynamic = repmat({''}, 1, nAddEqtn);
        add.LhsSteady = repmat({''}, 1, nAddEqtn);
        add.RhsSteady = repmat({''}, 1, nAddEqtn);
        add.SignSteady = repmat({''}, 1, nAddEqtn);
        add.MaxShDynamic = zeros(1, nAddEqtn);
        add.MaxShSteady = zeros(1, nAddEqtn);
        add.MinShDynamic = zeros(1, nAddEqtn);
        add.MinShSteady = zeros(1, nAddEqtn);
        insert(euc, add, ixPre, ixPost);
    end%




    function checkEmptyEqtn( )
        ixtm = eqn.Type==TYPE(1) | eqn.Type==TYPE(2);
        ixEmpty = cellfun(@isempty, eqn.Dynamic) & ixtm;
        if any(ixEmpty)
            throw( ...
                exception.ParseTime('Model:Postparser:DYNAMIC_EQUATION_EMPTY', 'error'), ...
                eqn.Input{ixEmpty} ...
                );
        end
    end%
end%
