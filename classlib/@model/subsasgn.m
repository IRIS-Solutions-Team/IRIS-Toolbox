function this = subsasgn(this, s, b)
% subsasgn  Subscripted assignment for model and systemfit objects.
%
% Syntax for assigning parameterisations from other object
% =========================================================
%
%     M(Inx) = N
%
%
% Syntax for deleting specified parameterisations
% ================================================
%
%     M(Inx) = [ ]
%
%
% Syntax for assigning parameter values or steady-state values
% =============================================================
%
%     M.Name = X
%     M(Inx).Name = X
%     M.Name(Inx) = X
%
%
% Syntax for assigning std deviations or cross-correlations of shocks
% ====================================================================
%
%     M.std_Name = X
%     M.corr_Name1__Name2 = X
%
% Note that a double underscore is used to separate the Names of shocks in
% correlation coefficients.
%
%
% Input arguments
% ================
%
% * `M` [ model | systemfit ] - Model or systemfit object that will be assigned new
% parameterisations or new parameter values or new steady-state values.
%
% * `N` [ model | systemfit ] - Model or systemfit object compatible with `M` whose
% parameterisations will be assigned (copied) into `M`.
%
% * `Inx` [ numeric ] - Inx of parameterisations that will be assigned
% or deleted.
%
% * `Name`, `Name1`, `Name2` [ char ] - Name of a variable, shock, or
% parameter.
%
% * `X` [ numeric ] - A value (or a vector of values) that will be assigned
% to a parameter or variable Named `Name`.
%
%
% Output arguments
% =================
%
% * `M` [ model | systemfit ] - Model or systemfit object with newly
% assigned or deleted parameterisations, or with newly assigned parameters,
% or steady-state values.
%
%
% Description
% ============
%
%
% Example
% ========
%
% Expand the number of parameterisations in a model or systemfit object
% that has initially just one parameterisation:
%
%     m(1:10) = m;
%
% The parameterisation is simply copied ten times within the model or
% systemfit object.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isa(this, 'model') || (~isa(b, 'model') && ~isempty(b) && ~isnumeric(b))
    utils.error('modelobj:subsasgn', ...
        'Invalid subscripted reference or assignment to model object.');
end

%--------------------------------------------------------------------------

nAlt = length(this);

% Dot-name assignment m.Name = x
%--------------------------------
if isnumeric(b) ...
        && (numel(b)==1 || numel(b)==nAlt) ...
        && numel(s)==1 && s(1).type=='.'
    name = s(1).subs;
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    if isnan(posQty) && isnan(posStdCorr)
        if strcmpi(this.Behavior.InvalidDotAssign, 'error')
            throw(exception.Base('Model:InvalidName', 'error'), '', name); %#ok<GTARG>
        elseif strcmpi(this.Behavior.InvalidDotAssign, 'warning')
            throw(exception.Base('Model:InvalidName', 'warning'), '', name); %#ok<GTARG>
        else
            return
        end
    elseif ~isnan(posQty)
        this.Variant = model.Variant.assignQuantity( ...
            this.Variant, posQty, ':', b ...
            );
    else
        this.Variant = model.Variant.assignStdCorr( ...
            this.Variant, posStdCorr, ':', b ...
            );
    end
    return
end

nAlt = length(this);
s = alterSubs(s, nAlt);

% Regular assignment
%--------------------

% this(ix) = b
% RHS must be model or empty.

if any(strcmp(s(1).type, {'()', '{}'}))
    if ~isa(b, 'model') && ~isempty(b)
        utils.error('modelobj:subsasgn', ...
            'Invalid subscripted reference or assignment to model object.');
    end
    
    % Make sure the LHS and RHS model objects are compatible in yvector,
    % xvector, and evector.
    if isa(b, 'model') && ~iscompatible(this, b)
        utils.error('modelobj:subsasgn', ...
            ['Objects A and B are not compatible in ', ...
            'in subscripted assignment A( ) = B.']);
    end
    
    ixA = s(1).subs{1};
    
    % `This([ ]) = B` leaves `This` unchanged.
    if isempty(ixA)
        return
    end
    
    if isa(b, 'model') && ~isempty(b)
        % `This(Inx) = B`
        % where `B` is a non-empty model whose length is either 1 or the same as
        % the length of `This(Inx)`.
        nb = length(b.Variant);
        if nb==1
            ixB = ones(size(ixA));
        else
            ixB = ':';
            if length(ixA)~=nb && nb>0
                utils.error('modelobj:subsasgn', ...
                    ['Number of parameterisations on LHS and RHS ', ...
                    'of assignment to model object must be the same.']);
            end
        end
        this = subsalt(this, ixA, b, ixB);
    else
        % `This(Inx) = [ ]` or `This(Inx) = B`
        % where `B` is an empty model.
        this = subsalt(this, ixA, [ ]);
    end
    
elseif strcmp(s(1).type, '.')
    % this.Name = b or this.Name(ix) = b
    % RHS must be numeric.
    
    name = s(1).subs;
    
    % Find the position of the Name in the Assign vector or stdcorr
    % vector.
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    % Create `Inx` for the third dimension.
    if length(s)>1
        % `This.Name(Inx) = B`
        ix2 = s(2).subs{1};
    else
        % `This.Name = B`
        ix2 = ':';
    end

    % Assign the value or throw an error.
    if ~isnan(posQty)
        try
            this.Variant = model.Variant.assignQuantity( ...
                this.Variant, posQty, ix2, b ...
                );
        catch Err
            utils.error('modelobj:subsasgn', ...
                ['Error in model parameter assignment.\n', ...
                '\tUncle says: %s '], ...
                Err.message);
        end
    elseif ~isnan(posStdCorr)
        try
            this.Variant = model.Variant.assignQuantity( ...
                this.Variant, posQty, ix2, b ...
                );
        catch Err
            utils.error('modelobj:subsasgn', ...
                ['Error in model parameter assignment.\n', ...
                '\tUncle says: %s '], ...
                Err.message);
        end
    else
        utils.error('modelobj:subsasgn', ...
            'This name does not exist in the model object: %s ', ...
            name);
    end

end

end



function s = alterSubs(s, n)
% Check and rearrange subscripted reference to models with mutliple parameter variants.

% This function accepts the following subscripts
%     x(index)
%     x.name
%     x.(index)
%     x.name(index)
%     x(index).name(index)
% where index is either logical or numeric or ':'
% and returns
%     x(numeric)
%     x.name(numeric)

% Convert x(index1).name(index2) to x.name(index1(index2)).
if length(s)==3 && any(strcmp(s(1).type,{'()','{}'})) ...
        && strcmp(s(2).type,{'.'}) ...
        && any(strcmp(s(3).type,{'()','{}'}))
    % convert a(index1).name(index2) to a.name(index1(index2))
    index1 = s(1).subs{1};
    if strcmp(index1, ':')
        index1 = 1 : n;
    end
    index2 = s(3).subs{1};
    if strcmp(index2, ':')
        index2 = 1 : length(index1);
    end
    s(1) = [ ];
    s(2).subs{1} = index1(index2);
end

% Convert a(index).name to a.name(index).
if length(s)==2 && any(strcmp(s(1).type, {'()', '{}'})) ...
        && strcmp(s(2).type, {'.'})
    s = s([2, 1]);
end

if length(s)>2
    utils.error('modelobj:subsasgn', ...
        'Invalid reference to model object.');
end

% Convert a(:) or a.name(:) to a(1:n) or a.name(1:n).
% Convert a(logical) or a.name(logical) to a(numeric) or a.name(numeric).
if any(strcmp(s(end).type,{'()','{}'}))
    if strcmp(s(end).subs{1},':')
        s(end).subs{1} = 1 : n;
    elseif islogical(s(end).subs{1})
        s(end).subs{1} = find(s(end).subs{1});
    end
end

% Throw error for mutliple indices
% a(index1,index2,...) or a.name(index1,index2,...).
if any(strcmp(s(end).type, {'()', '{}'}))
    if length(s(end).subs)~=1 || ~isnumeric(s(end).subs{1})
        utils.error('modelobj:subsasgn', ...
            'Invalid reference to model object.');
    end
end

% Throw error if index is not real positive integer.
if any(strcmp(s(end).type,{'()','{}'}))
    ix = s(end).subs{1};
    if any(ix<1) || any(round(ix)~=ix) ...
            || any(imag(ix)~=0)
        utils.error('modelobj:subsasgn', ...
            ['Subscript indices must be ', ...
            'either real positive integers or logicals.']);
    end
end

end
