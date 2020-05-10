function [this, namesAssigned] = assign(this, varargin)
% assign  Assign parameters, steady states, std deviations or cross-correlations
%{
% ## Syntax ##
%
%     [M, Assigned] = assign(M, P)
%     [M, Assigned] = assign(M, N)
%     [M, Assigned] = assign(M, Name, Value, Name, Value, ...)
%     [M, Assigned] = assign(M, List, Values)
%
%
% ## Syntax for Fast Assign ##
%
%     % Initialise
%     assign(M, List);
%
%     % Fast assign
%     M = assign(M, Values);
%     ...
%     M = assign(M, Values);
%     ...
%
%
% ## Input arguments ##
%
% * `M` [ model ] - Model object.
%
% * `P` [ struct ] - Database whose fields refer to parameter
% names, variable names, std deviations, or cross-correlations.
%
% * `N` [ model ] - Another model object from which all parameteres
% (including std erros and cross-correlation coefficients), and
% steady-states values will be assigned that match the name and type in
% `M`.
%
% * `Name` [ char ] - A parameter name, variable name, std
% deviation, cross-correlation, or a regular expression that will be
% matched against model names.
%
% * `Value` [ numeric ] - A value (or a vector of values in case of
% multiple parameterisations) that will be assigned.
%
% * `List` [ cellstr ] - A list of parameter names, variable names, std
% deviations, or cross-correlations.
%
% * `Values` [ numeric ] - A vector of values.
%
%
% ## Output arguments ##
%
% * `M` [ model ] - Model object with newly assigned parameters and/or
% steady states.
%
% * `Assigned` [ cellstr | `Inf` ] - List of actually assigned parameter
% names, variables names (steady states), std deviations, and
% cross-correlations; `Inf` indicates that all values has been assigned
% from another model object.
%
%
% ## Description ##
%
% Calls with `Name`-`Value` or `List`-`Value` pairs throw an error if some
% names in the list are not valid names in the model object. Calls with a
% database, `P`, or another model object, `N`, do not perform this check.
%
%
% ## Example ##
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent POS_VALUES INDEX_VALUES_RHS POS_STDCORR INDEX_STDCORR_RHS NAMES_ASSIGNED
TYPE = @int8;

%--------------------------------------------------------------------------

inxE = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

namesAssigned = cell(1, 0);
if isempty(varargin)
    return
end

flags = hereReadFlags( );

% Number of input arguments with the growth label removed.
n = numel(varargin);
numE = nnz(inxE);
nStdCorr = numE + numE*(numE-1)/2;
nv = countVariants(this);
numQuantities = length(this.Quantity);
inputNames = cell(1, 0);
invalidLength = cell(1, 0);
invalidImag = cell(1, 0);
invalidLhsNames = cell(1, 0);

% `Assign` and `stdcorr` are logical indices of values that have been
% assigned.
inxValues = false(1, numQuantities);
inxStdCorr = false(1, nStdCorr);

if isempty(varargin)
    % Do nothing.
    
elseif isa(varargin{1}, 'model')
    % Assign from another model object:
    % m = assign(m, n);
    % m = assign(m, n, list);
    assignFromModelObj( );
    
elseif n==1 && isnumeric(varargin{1})
    % Quick assignment after iniatialization.
    % m = assign(m, array).
    assert( ...
        ~isempty(POS_VALUES) || ~isempty(POS_STDCORR), ...
        'model:assign', ...
        'Initialize assign( ) before using the function with a single numeric input.' ...
    );
    if any(INDEX_VALUES_RHS)
        this.Variant.Values(1, POS_VALUES, :) = varargin{1}(INDEX_VALUES_RHS);
    end
    if any(INDEX_STDCORR_RHS)
        this.Variant.StdCorr(1, POS_STDCORR, :) = varargin{1}(INDEX_STDCORR_RHS);
    end
    namesAssigned = NAMES_ASSIGNED;
    % Keep persistent variables and return immediately.
    return
    
elseif n<=2 && iscellstr(varargin{1})
    % assign(m, cellstr) initializes quick-assign function.
    % m = assign(m, cellstr, array);
    inputNames = reshape(varargin{1}, 1, [ ]);
    varargin(1) = [ ];
    numNames = numel(inputNames);
    ell = lookup(this.Quantity, inputNames);
    posQuantity = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    indexQuantityRhs = ~isnan(posQuantity);
    posQuantity = posQuantity(indexQuantityRhs);
    inxStdCorrRhs = ~isnan(posStdCorr);
    posStdCorr = posStdCorr(inxStdCorrRhs);
    invalidLhsNames = inputNames(~indexQuantityRhs & ~inxStdCorrRhs);
    
    if isempty(varargin)
        % Initialize quick-assign access and return.
        POS_VALUES = posQuantity;
        POS_STDCORR = posStdCorr;
        INDEX_VALUES_RHS = indexQuantityRhs;
        INDEX_STDCORR_RHS = inxStdCorrRhs;
        getNamesAssigned( );
        NAMES_ASSIGNED = namesAssigned;
        
        % Keep persistent variables and return immediately.
        return
    elseif isnumeric(varargin{1})
        value = varargin{1};
        assignListValue( );
        assert( ...
            isempty(invalidLhsNames), ...
            exception.Base('Model:InvalidName', 'error'), ...
            '', invalidLhsNames{:} ...
        );
    else
        utils.error('modelobj:assign', '#Invalid_assign:model');
    end
        
elseif n<=2 && (isstruct(varargin{1}) || isa(varargin{1}, 'table'))
    % Assign from struct or table
    % * m = assign(m, struct)
    % * m = assign(m, struct, clone)
    % * m = assign(m, table)
    % * m = assign(m, table, clone)
    d = varargin{1};
    varargin(1) = [ ];
    if isstruct(d)
        % Assign from struct
        inputNames = fieldnames(d);
        inputValues = struct2cell(d);
    else
        % Assign from table
        inputNames = d.Properties.RowNames;
        inputValues = table2cell(d(:, :));
    end
    if ~isempty(varargin) && ~isempty(varargin{1})
        cloneTemplate = varargin{1};
        inputNames = model.File.cloneAllNames(inputNames, cloneTemplate);
    end
    numNames = numel(inputNames);
    invalidLength = cell(1, 0);
    invalidImag = cell(1, 0);
    ell = lookup(this.Quantity, inputNames);
    posQuantity = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    for i = 1 : numNames
        if iscell(inputValues)
            value__ = inputValues{i};
        else
            value__ = inputValues(i, :);
        end
        % Do not check if names are valid LHS names in assignments from databases
        if isnan(posQuantity(i)) && isnan(posStdCorr(i))
            continue
        end
        hereAssignPositionValue(inputNames{i}, posQuantity(i), posStdCorr(i), value__);
    end
    reportInvalid( );

elseif all(cellfun(@(x) ischar(x) || isa(x, 'string') || isa(x, 'rexp'), varargin(1:2:end)))
    % m = assign(m, name, value, name, value, ...)
    % name is char or char list or rexp or double-dot list but not cellstr
    inputNames = varargin(1:2:end);
    numNames = numel(inputNames);
    % Remove equal signs from assign(m, 'alpha=', 1).
    for i = 1 : numNames
        inputNames{i} = strrep(inputNames{i}, ' ', '');
        if ~isempty(inputNames{i}) && inputNames{i}(end)=='='
            inputNames{i}(end) = '';
        end
    end
    inputValues = varargin(2:2:end);
    invalidLhsNames = cell(1, 0);
    invalidLength = cell(1, 0);
    invalidImag = cell(1, 0);
    for i = 1 : numNames
        if isa(inputNames{i}, 'rexp') || isempty(regexp(inputNames{i}, '\W', 'once'))
            %
            % Plain name
            %
            name__ = inputNames{i};
            [posValues__, posStdCorr__] = hereGetPositions(name__);
            if ~isempty(posValues__) || ~isempty(posStdCorr__)
                hereAssignPositionValue(name__, posValues__, posStdCorr__, inputValues{i});
            end
        else
            %
            % List of names: 'A1, A2, B'
            % Double-dot list: 'A1,..,A2'
            %
            list__ = inputNames{i};
            value__ = inputValues{i};
            if contains(list__, ',..,')
                list__ = parser.DoubleDot.parse(char(list__), parser.DoubleDot.COMMA);
            end
            list__ = regexp(list__, '\w+', 'match');
            for j = 1 : numel(list__)
                [posValues__, posStdCorr__] = hereGetPositions(list__{j});
                if ~isempty(posValues__) || ~isempty(posStdCorr__)
                    hereAssignPositionValue(list__{j}, posValues__, posStdCorr__, value__(:, min(j, end), :));
                end
            end
        end
    end
    reportInvalid( );
    if ~isempty(invalidLhsNames)
        throw( ...
            exception.Base('Model:InvalidName', 'error'), ...
            '', invalidLhsNames{:} ...
        ); %#ok<GTARG>
    end

else
    % Throw an invalid assignment error.
    throw( exception.Base('General:INVALID_ASSIGNMENT', 'error'), ...
           class(this) ); %#ok<GTARG>
end

% Reset persistent variables in each non-quick-assign calls
POS_VALUES = [ ];
INDEX_VALUES_RHS = [ ];
POS_STDCORR = [ ];
INDEX_STDCORR_RHS = [ ];
NAMES_ASSIGNED = { };

% Steady states cannot be changed from 0+0i.
inxNonzeroShocks = false(1, numQuantities);
inxNonzeroShocks(inxE) = any(this.Variant.Values(1, inxE, :)~=0, 3);
if any(inxNonzeroShocks)
    throw( ...
        exception.Base('Model:CannotChangeSteadyShocks', 'error'), ...
        this.Quantity.Name{inxNonzeroShocks} ...
    );
end

if nargout<2
    return
end

% Put together list of parameters, steady states, std deviations, and
% correlations that have been assigned.
getNamesAssigned( );

return

    
    function flags = hereReadFlags( )
        flags = struct( );
        flags.Level = false;
        flags.Change = false;
        flags.ExcludeNaNs = false;
        while ~isempty(varargin) && ischar(varargin{1}) ...
                && strncmp(varargin{1}, '-', 1)
            switch lower(strtrim(varargin{1}))
                case '-level'
                    flags.Level = true;
                case {'-change', '-growth'}
                    flags.Change = true;
                case '-excludenans'
                    flags.ExcludeNaNs = true;
                otherwise
                    throw( ...
                        exception.Base('Model:INVALID_ASSIGN_FLAG', 'error'), ...
                        varargin{1} ...
                    );
            end
            varargin(1) = [ ];
        end
    end%




    function assignFromModelObj( )
        rhs = varargin{1};
        namesToAssign = @all;
        if n>1
            namesToAssign = varargin{2};
            if ischar(namesToAssign)
                namesToAssign = regexp(namesToAssign, '\w+', 'match');
            end
        end
        inputNames = rhs.Quantity.Name;
        cloneTemplate = '';
        if n>2
            cloneTemplate = varargin{3};
            if ~isequal(namesToAssign, @all)
                namesToAssign = model.File.cloneAllNames(namesToAssign, cloneTemplate);
            end
            inputNames = model.File.cloneAllNames(inputNames, cloneTemplate);
        end
        nvRhs = countVariants(rhs);
        if nvRhs~=1 && nvRhs~=nv
            utils.error( 'modelobj:assign', ...
                         ['Cannot assign from object ', ...
                         'with different number of parameterisations.'] );
        end
        numQuantities = length(this.Quantity);
        inxMatchingTypes = true(1, numQuantities);
        for ii = 1 : numQuantities
            name = this.Quantity.Name{ii};
            if ~isequal(namesToAssign, @all) && ~any(strcmpi(name, namesToAssign))
                continue
            end
            ixRhs = strcmp(name, inputNames);
            if ~any(ixRhs)
                continue
            end
            if rhs.Quantity.Type(ixRhs)==this.Quantity.Type(ii)
                oldValue = this.Variant.Values(1, ii, :);
                newValue = rhs.Variant.Values(1, ixRhs, :);
                if flags.Change
                    newValue = real(oldValue) + 1i*imag(newValue);
                elseif flags.Level
                    newValue = real(newValue) + 1i*imag(oldValue);
                end
                this.Variant.Values(1, ii, :) = newValue;
                inxValues(ii) = true;
            else
                inxMatchingTypes(ii) = false;
            end
        end
        listStdCorr = [ getStdNames(this.Quantity), getCorrNames(this.Quantity) ];
        listStdCorrRhs = [ getStdNames(rhs.Quantity), getCorrNames(rhs.Quantity) ];
        if ~isempty(cloneTemplate)
            listStdCorrRhs = model.File.cloneAllNames(listStdCorrRhs, cloneTemplate);
        end
        for ii = 1 : numel(listStdCorr)
            ixRhs = strcmpi(listStdCorr{ii}, listStdCorrRhs);
            if ~any(ixRhs)
                continue
            end
            this.Variant.StdCorr(1, ii, :) = rhs.Variant.StdCorr(1, ixRhs, :);
            inxStdCorr(ii) = true;
        end
        if any(~inxMatchingTypes)
            utils.warning( 'modelobj:assign', ...
                           'This name not assigned because of type mismatch: %s ', ...
                           this.Quantity.Name{~inxMatchingTypes} );
        end
    end%



    function [posValues, posStdCorr] = hereGetPositions(name)
        ell__ = lookup(this.Quantity, name);
        if ~any(ell__.IxName) && ~any(ell__.IxStdCorr)
            % Do not report rexps that match no name
            if ~isa(inputNames{i}, 'rexp')
                invalidLhsNames{end+1} = name;
            end
            posValues = [ ];
            posStdCorr = [ ];
            return
        end
        posValues = find(ell__.IxName);
        posStdCorr = find(ell__.IxStdCorr);
    end%




    function hereAssignPositionValue(name, posValues, posStdCorr, value)
        % One or more names, one value
        value = reshape(value, [ ], 1);
        value = permute(value, [2, 3, 1]);
        numValues = numel(value);
        isValidLen = numValues==1 || numValues==nv;
        if ~isValidLen
            invalidLength{end+1} = name;
            return
        end
        isValidImag = all(imag(value)==0) ...
            || ( ~flags.Change && ~flags.Level ...
            && all(isnan(posStdCorr)) ...
            && ~any(this.Quantity.Type(posValues)==TYPE(4)) );
        if ~isValidImag
            invalidImag{end+1} = name;
            return
        end
        % Assign Variant.Values
        for pos = posValues(~isnan(posValues))
            if flags.Level || flags.Change
                oldValues = this.Variant.Values(:, pos, :);
                if flags.Change
                    value = real(oldValues) + 1i*value;
                elseif flags.Level
                    value = value + 1i*imag(oldValues);
                end
            end
            this.Variant.Values(:, pos, :) = value;
        end
        % Assign Variant.StdCorr
        for pos = posStdCorr(~isnan(posStdCorr))
            this.Variant.StdCorr(:, pos, :) = value;
        end
    end%




    function assignListValue( )
        if size(value, 2)==1 && numNames>1
            value = repmat(value, 1, numNames, 1);
        end
        if size(value, 3)==1 && nv>1
            value = repmat(value, 1, 1, nv);
        end
        if (flags.Change || flags.Level) && any(imag(value(:))~=0)
            utils.error('modelobj:assign', ...
                ['Cannot assign(...) non-zero imag numbers ', ...
                'with flag ''-level'' or ''-growth''.']);
        end
        if flags.Level || flags.Change
            oldValues = this.Variant(:, posQuantity, :);
            if flags.Change
                value(:, indexQuantityRhs, :) = real(oldValues) + 1i*value(:, indexQuantityRhs, :);
            elseif flags.Level
                value(:, indexQuantityRhs, :) = value(:, indexQuantityRhs, :) + 1i*imag(oldValues);
            end
        end
        if any(indexQuantityRhs)
            inxValues(posQuantity) = true;
            this.Variant.Values(:, posQuantity, :) = value(:, indexQuantityRhs, :);
        end
        if any(inxStdCorrRhs)
            inxStdCorr(posStdCorr) = true;
            this.Variant.StdCorr(:, posStdCorr, :) = value(:, inxStdCorrRhs, :);
        end
    end%




    function reportInvalid( )
        if ~isempty(invalidLength)
            utils.error( 'modelobj:assign', ...
                ['Incorrect number of alternative values assigned ', ...
                'to this name: %s.'], ...
                invalidLength{:} );
        end
        if ~isempty(invalidImag)
            utils.error( 'modelobj:assign', ...
                'This name cannot be assigned complex or imag number: %s ', ...
                invalidImag{:} );
        end
    end%




    function getNamesAssigned( )
        namesAssigned = this.Quantity.Name(inxValues);
        lse = this.Quantity.Name(inxE);
        namesAssigned = [namesAssigned, strcat('std_', lse(inxStdCorr(1:numE)))];
        pos = find( tril(ones(numE), -1)==1 );
        temp = zeros(numE);
        temp(pos(inxStdCorr(numE+1:end))) = 1;
        [row, col] = find(temp==1);
        namesAssigned = [ namesAssigned, ...
            strcat('corr_', lse(row), '__', lse(col)) ];
    end%
end%
