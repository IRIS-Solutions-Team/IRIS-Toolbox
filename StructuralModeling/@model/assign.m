function [this, lsAssigned] = assign(this, varargin)
% assign  Assign parameters, steady states, std deviations or cross-correlations.
%
%
% Syntax
% =======
%
%     [M, Assigned] = assign(M, P)
%     [M, Assigned] = assign(M, N)
%     [M, Assigned] = assign(M, Name, Value, Name, Value, ...)
%     [M, Assigned] = assign(M, List, Values)
%
%
% Syntax for fast assign
% =======================
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
% Syntax for assigning only steady-state levels
% ==============================================
%
%     M = assign(M, '-level', ...)
%
%
% Syntax for assignin only steady-state growth rates
% ===================================================
%
%     M = assign(M, '-growth', ...)
%
%
% Input arguments
% ================
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
% Output arguments
% =================
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
% Description
% ============
%
% Calls with `Name`-`Value` or `List`-`Value` pairs throw an error if some
% names in the list are not valid names in the model object. Calls with a
% database, `P`, or another model object, `N`, do not perform this check.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent POS_QTY IX_QTY_RHS POS_STDCORR IX_STDCORR_RHS LS_ASSIGNED;
TYPE = @int8;

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

lsAssigned = cell(1, 0);
if isempty(varargin)
    return
end

flags = struct('Level', false, 'Growth', false, 'ExcludeNaNs', false);
readFlags( );

% Number of input arguments with the growth label removed.
n = length(varargin);
ne = sum(ixe);
nStdCorr = ne + ne*(ne-1)/2;
nAlt = length(this.Variant);
nQty = length(this.Quantity);
lsAllName = cell(1, 0);
lsInvalidLen = cell(1, 0);
lsInvalidImag = cell(1, 0);
lsInvalidLhsName = cell(1, 0);

% `Assign` and `stdcorr` are logical indices of values that have been
% assigned.
ixQty = false(1, nQty);
ixStdCorr = false(1, nStdCorr);

if isempty(varargin)
    % Do nothing.
    
elseif isa(varargin{1}, 'model')
    % Assign from another model object:
    % m = assign(m, n);
    % m = assign(m, n, list);
    assignFromModelObj( );
    
elseif n==1 && isnumeric(varargin{1})
    % Quick assignment after iniatialization.
    % m = assign(m,array).
    if isempty(POS_QTY) && isempty(POS_STDCORR)
        utils.error('modelobj:assign', ...
            ['Initialize assign( ) before using the function ', ...
            'with a single numeric input.']);
    end
    ixQty(POS_QTY) = true;
    ixStdCorr(POS_STDCORR) = true;
    
    this.Variant = model.Variant.assignQuantity( ...
        this.Variant, POS_QTY, ':', varargin{1}(IX_QTY_RHS) ...
        );
    
    this.Variant = model.Variant.assignStdCorr( ...
        this.Variant, POS_STDCORR, ':', varargin{1}(IX_STDCORR_RHS), ...
        this.Quantity.IxStdCorrAllowed ...
        );
    
    lsAssigned = LS_ASSIGNED;
    
    % Keep persistent variables and return immediately.
    return
    
elseif n<=2 && iscellstr(varargin{1})
    % assign(m, cellstr) initializes quick-assign function.
    % m = assign(m, cellstr, array);
    lsAllName = varargin{1}(:).';
    varargin(1) = [ ];
    nName = length(lsAllName);
    ell = lookup(this.Quantity, lsAllName);
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    ixQtyRhs = ~isnan(posQty);
    posQty = posQty(ixQtyRhs);
    ixStdCorrRhs = ~isnan(posStdCorr);
    posStdCorr = posStdCorr(ixStdCorrRhs);
    lsInvalidLhsName = lsAllName(~ixQtyRhs & ~ixStdCorrRhs);
    
    if isempty(varargin)
        % Initialize quick-assign access and return.
        POS_QTY = posQty;
        POS_STDCORR = posStdCorr;
        IX_QTY_RHS = ixQtyRhs;
        IX_STDCORR_RHS = ixStdCorrRhs;
        listAssigned( );
        LS_ASSIGNED = lsAssigned;
        
        % Keep persistent variables and return immediately.
        return
    elseif isnumeric(varargin{1})
        value = varargin{1};
        assignListAndValue( );
        chkLhsNames( );
    else
        utils.error('modelobj:assign', '#Invalid_assign:model');
    end
        
elseif n<=2 && isstruct(varargin{1})
    % Assign from a database:
    % m = assign(m, struct);
    % m = assign(m, struct, clone);
    d = varargin{1};
    varargin(1) = [ ];
    lsAllName = fieldnames(d);
    allValue = struct2cell(d);
    if ~isempty(varargin) && ~isempty(varargin{1})
        cloneTemplate = varargin{1};
        lsAllName = parser.Preparser.cloneAllNames(lsAllName, cloneTemplate);
    end
    lsAllName = lsAllName(:).';
    allValue = allValue(:).';
    nName = length(lsAllName);
    lsInvalidLen = cell(1, 0);
    lsInvalidImag = cell(1, 0);
    ell = lookup(this.Quantity, lsAllName);
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    for i = 1 : nName
        name = lsAllName{i};
        value = allValue{i};
        % Do not check if names are valid LHS names in assignments from databases.
        if isnan(posQty(i)) && isnan(posStdCorr(i))
            continue
        end
        assignNameAndValue(name, posQty(i), posStdCorr(i), value);
    end
    chkValid( );

elseif all(cellfun(@(x) ischar(x) || isa(x, 'rexp'), varargin(1:2:end)))
    % m = assign(m, name, value, name, value, ...)
    % name is char or char list or rexp or double dot but not cellstr.
    lsAllName = varargin(1:2:end);
    nName = length(lsAllName);
    % Remove equal signs from assign(m, 'alpha=', 1).
    for i = 1 : nName
        lsAllName{i} = strrep(lsAllName{i},' ','');
        if ~isempty(lsAllName{i}) && lsAllName{i}(end)=='='
            lsAllName{i}(end) = '';
        end
    end
    allValue = varargin(2:2:end);
    lsInvalidLhsName = cell(1, 0);
    lsInvalidLen = cell(1, 0);
    lsInvalidImag = cell(1, 0);
    for i = 1 : nName
        name = lsAllName{i};
        value = allValue{i};
        if isa(name, 'rexp') || isempty(regexp(name, '\W', 'once'))
            % Plain name.
            assignNameAndValue(name, [ ], [ ], allValue{i});
        else
            % List of names:
            % A1, A2, B
            % or double-dot list 
            % A1,..,A2
            list = name;
            if ~isempty(strfind(list, ',..,'))
                list = parse(parser.doubledot.Keyword.COMMA, list);
            end
            list = regexp(list, '\w+', 'match');
            for j = 1 : length(list)
                ddName = list{j};
                if size(value, 2)==1
                    ddValue = value;
                else
                    ddValue = value(:, j, :);
                end
                assignNameAndValue(ddName, [ ], [ ], ddValue);
            end
        end
    end
    chkValid( );
    chkLhsNames( );

else
    % Throw an invalid assignment error.
    throw( exception.Base('General:INVALID_ASSIGNMENT', 'error'), class(this) ); %#ok<GTARG>
end

% Reset persistent variables in each non-quick-assign calls.
POS_QTY = [ ];
IX_QTY_RHS = [ ];
POS_STDCORR = [ ];
IX_STDCORR_RHS = [ ];
LS_ASSIGNED = { };

% Steady states cannot be changed from 0+0i.
ixZeroShock = true(1, ne);
for iAlt = 1 : nAlt
    ixZeroShock = ixZeroShock & this.Variant{iAlt}.Quantity(ixe)==0;
end
if any(~ixZeroShock)
    temp = true(1, nQty);
    temp(ixe) = ixZeroShock;
    throw( ...
        exception.Base('Model:CANNOT_CHANGE_STEADY_SHOCKS', 'error'), ...
        this.Quantity.Name{~temp} ...
        );
end

if nargout<2
    return
end

% Put together list of parameters, steady states, std deviations, and
% correlations that have been assigned.
listAssigned( );

return

    
    
    
    function readFlags( )
        while ~isempty(varargin) && ischar(varargin{1}) ...
                && strncmp(varargin{1}, '-', 1)
            switch lower(strtrim(varargin{1}))
                case '-level'
                    flags.Level = true;
                case '-growth'
                    flags.Growth = true;
                case '-excludenans'
                    flags.ExcludeNaNs = true;
                otherwise
                    throw( exception.Base('Model:INVALID_ASSIGN_FLAG', 'error'), ...
                        varargin{1} );
            end
            varargin(1) = [ ];
        end
    end




    function assignFromModelObj( )
        rhs = varargin{1};
        lsToAssign = @all;
        if n>1
            lsToAssign = varargin{2};
            if ischar(lsToAssign)
                lsToAssign = regexp(lsToAssign, '\w+', 'match');
            end
        end
        nAltRhs = length(rhs.Variant);
        if nAltRhs~=1 && nAltRhs~=nAlt
            utils.error('modelobj:assign', ...
                ['Cannot assign from object ', ...
                'with different number of parameterisations.']);
        end
        nQty = length(this.Quantity);
        ixMatchingType = true(1, nQty);
        for ii = 1 : nQty
            name = this.Quantity.Name{ii};
            if ~isequal(lsToAssign, @all) && ~any(strcmpi(name, lsToAssign))
                continue
            end
            ixRhs = strcmp(name, rhs.Quantity.Name);
            if ~any(ixRhs)
                continue
            end
            if rhs.Quantity.Type(ixRhs)==this.Quantity.Type(ii)
                oldValue = model.Variant.getQuantity(this.Variant, ii, ':');
                newValue = model.Variant.getQuantity(rhs.Variant, ixRhs, ':');
                if flags.Growth
                    newValue = real(oldValue) + 1i*imag(newValue);
                elseif flags.Level
                    newValue = real(newValue) + 1i*imag(oldValue);
                end
                this.Variant = model.Variant.assignQuantity( ...
                    this.Variant, ii, ':', newValue ...
                    );
                ixQty(ii) = true;
            else
                ixMatchingType(ii) = false;
            end
        end
        lsStdCorr = [ getStdName(this.Quantity), getCorrName(this.Quantity) ];
        lsStdCorrRhs = [ getStdName(rhs.Quantity), getCorrName(rhs.Quantity) ];
        for ii = 1 : length(lsStdCorr)
            ixRhs = strcmpi(lsStdCorr{ii}, lsStdCorrRhs);
            if ~any(ixRhs)
                continue
            end
            newValue = model.Variant.getStdCorr(rhs.Variant, ixRhs, ':');
            this.Variant = model.Variant.assignStdCorr( ...
                this.Variant, ii, ':', newValue, ...
                this.Quantity.IxStdCorrAllowed ...
                );
            ixStdCorr(ii) = true;
        end
        if any(~ixMatchingType)
            utils.warning('modelobj:assign', ...
                'This name not assigned because of type mismatch: %s ', ...
                this.Quantity.Name{~ixMatchingType});
        end
    end




    function assignNameAndValue(name, posQty, posStdCorr, value)
        % One or more names, one value.
        if isempty(posQty) && isempty(posStdCorr)
            ell = lookup(this.Quantity, name);
            ixQty = ell.IxName;
            ixStdCorr = ell.IxStdCorr;
            if ~any(ixQty) && ~any(ixStdCorr)
                if ~isa(lsAllName{i}, 'rexp')
                    lsInvalidLhsName{end+1} = name;
                end
                return
            end
            posQty = find(ixQty);
            posStdCorr = find(ixStdCorr);
        end
        value = value(:);
        value = permute(value, [2, 3, 1]);
        nValue = numel(value);
        isValidLen = nValue==1 || nValue==nAlt;
        if ~isValidLen
            lsInvalidLen{end+1} = name;
            return
        end
        isValidImag = all(imag(value)==0) ...
            || ( ~flags.Growth && ~flags.Level ...
            && all(isnan(posStdCorr)) ...
            && ~any(this.Quantity.Type(posQty)==TYPE(4)) );
        if ~isValidImag
            lsInvalidImag{end+1} = name;
            return
        end
        % Assign Variant{:}.Quantity
        for pos = posQty(~isnan(posQty))
            if flags.Level || flags.Growth
                x = model.Variant.getQuantity( ...
                    this.Variant, pos, ':' ...
                    );
                if flags.Growth
                    value = real(x) + 1i*value;
                elseif flags.Level
                    value = value + 1i*imag(x);
                end
            end
            this.Variant = model.Variant.assignQuantity( ...
                this.Variant, pos, ':', value ...
                );
        end
        % Assign Variant{:}.StdCorr
        for pos = posStdCorr(~isnan(posStdCorr))
            this.Variant = model.Variant.assignStdCorr( ...
                this.Variant, pos, ':', value, ...
                this.Quantity.IxStdCorrAllowed ...
                );
        end
    end




    function assignListAndValue( )
        if size(value,2)==1 && nName>1
            value = repmat(value, 1, nName, 1);
        end
        if size(value,3)==1 && nAlt>1
            value = repmat(value, 1, 1, nAlt);
        end
        if (flags.Growth || flags.Level) && any(imag(value(:))~=0)
            utils.error('modelobj:assign', ...
                ['Cannot assign(...) non-zero imag numbers ', ...
                'with flag ''-level'' or ''-growth''.']);
        end
        if flags.Level || flags.Growth
            x = model.Variant.getQuantity(this.Variant, posQty, ':');
            if flags.Growth
                value(1, ixQtyRhs, :) = real(x) + 1i*value(1, ixQtyRhs, :);
            elseif flags.Level
                value(1, ixQtyRhs, :) = value(1, ixQtyRhs, :) + 1i*imag(x);
            end
        end
        if any(ixQtyRhs)
            ixQty(posQty) = true;
            this.Variant = model.Variant.assignQuantity( ...
                this.Variant, posQty, ':', value(1, ixQtyRhs, :) ...
                );
        end
        if any(ixStdCorrRhs)
            ixStdCorr(posStdCorr) = true;
            this.Variant = model.Variant.assignStdCorr( ...
                this.Variant, posStdCorr, ':', value(1, ixStdCorrRhs, :), ...
                this.Quantity.IxStdCorrAllowed ...
                );
        end
    end




    function chkValid( )
        if ~isempty(lsInvalidLen)
            utils.error( 'modelobj:assign', ...
                ['Incorrect number of alternative values assigned ', ...
                'to this name: %s.'], ...
                lsInvalidLen{:} );
        end
        if ~isempty(lsInvalidImag)
            utils.error( 'modelobj:assign', ...
                'This name cannot be assigned complex or imag number: %s ', ...
                lsInvalidImag{:} );
        end
    end




    function chkLhsNames( )
        if ~isempty(lsInvalidLhsName)
            throw( exception.Base('Model:INVALID_NAME', 'error'), ...
                '', lsInvalidLhsName{:} ); %#ok<GTARG>
        end
    end




    function listAssigned( )
        lsAssigned = this.Quantity.Name(ixQty);
        lse = this.Quantity.Name(ixe);
        lsAssigned = [lsAssigned, strcat('std_', lse(ixStdCorr(1:ne)))];
        pos = find( tril(ones(ne),-1)==1 );
        temp = zeros(ne);
        temp(pos(ixStdCorr(ne+1:end))) = 1;
        [row,col] = find(temp==1);
        lsAssigned = [ lsAssigned, ...
            strcat('corr_', lse(row), '__', lse(col)) ];
    end
end
