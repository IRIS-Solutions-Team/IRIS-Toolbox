function this = subsasgn(this, s, b)
% subsasgn  Subscripted assignment for model objects
%
% __Syntax for Assigning Parameterisations from Other Object
%
%     M(Index) = N
%
%
% __Syntax for Deleting Specified Parameter Variants__
%
%     M(Index) = [ ]
%
%
% __Syntax for Assigning Parameter Values or Steady Values__
%
%     M.Name = X
%     M(Index).Name = X
%     M.Name(Index) = X
%
%
% __Syntax for Assigning Std Deviations or Cross-Correlations of Shocks__
%
%     M.Std_Name = X
%     M.Corr_Name1__Name2 = X
%
% Double underscore is used to separate the names of shocks in correlation
% coefficients.
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object that will be assigned new parameter
% variants or new parameter values or new steady values.
%
% * `N` [ model ] - Model object compatible with `M` whose parameter
% variants will be assigned (copied) into `M`.
%
% * `Index` [ numeric ] - Index of parameter variants that will be assigned
% or deleted.
%
% * `Name`, `Name1`, `Name2` [ char ] - Name of a variable, shock, or
% parameter.
%
% * `X` [ numeric ] - A value (or a vector of values) that will be assigned
% to a parameter or variable Named `Name`.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Model object with newly assigned or deleted parameter
% variants, or with newly assigned parameters, or steady values.
%
%
% __Description__
%
%
% __Example__
%
% Expand the number of parameter variants in a model object that has
% initially just one parameter variant:
%
%     m(1:10) = m;
%
% The parameter variants is simply copied ten times within the model
% object.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if ~isa(this, 'model') ...
   || ( ~isa(b, 'model') && ~isempty(b) && ~isnumeric(b) && ~islogical(b) )
    utils.error('model:subsasgn', ...
        'Invalid subscripted reference or assignment to model object.');
end

%--------------------------------------------------------------------------

nv = length(this);

% __Dot-Name Assignment__
% m.Name = x
if isnumeric(b) ...
        && (numel(b)==1 || numel(b)==nv) ...
        && numel(s)==1 && s(1).type=='.'
    name = s(1).subs;
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    if ~isnan(posQty)
        this.Variant.Values(:, posQty, :) = b;
    elseif ~isnan(posStdCorr)
        this.Variant.StdCorr(:, posStdCorr, :) = b;
    else
        if strcmpi(this.Behavior.InvalidDotAssign, 'error')
            throw(exception.Base('Model:InvalidName', 'error'), '', name); %#ok<GTARG>
        elseif strcmpi(this.Behavior.InvalidDotAssign, 'warning')
            throw(exception.Base('Model:InvalidName', 'warning'), '', name); %#ok<GTARG>
        end 
    end
    return
end

s = checkSubscripted(s, nv);

% __Regular Assignment__
% this(ix) = b
% RHS must be model or empty.

if any(strcmp(s(1).type, {'()', '{}'}))
    assert( ...
        isa(b, 'model') || isempty(b), ...
        'model:subsasgn', ...
        'Invalid subscripted reference or assignment to model object.' ...
    );
    
    % Make sure the LHS and RHS model objects are compatible in yvector,
    % xvector, and evector.
    assert( ...
        isempty(b) || iscompatible(this, b), ...
        'model:subsasgn', ...
        'Model objects A and B are not compatible in subscripted assignment A( ) = B.' ...
    );
    
    ixA = s(1).subs{1};
    
    % `this([ ]) = B` leaves `this` unchanged.
    if isempty(ixA)
        return
    end
    
    if isa(b, 'model') && ~isempty(b)
        % `this(Inx) = B`
        % where `B` is a non-empty model whose length is either 1 or the same as
        % the length of `this(Inx)`.
        nb = length(b);
        if nb==1
            ixB = ones(size(ixA));
        else
            ixB = ':';
            assert( ...
                length(ixA)==nb || nb==0, ...
                'model:subsasgn', ...
                'The numbers of parameter variants on LHS and RHS of subscripted assignment must be the same.' ...
            );
        end
        this.Variant = subscripted(this.Variant, ixA, b.Variant, ixB);
    else
        % `this(Inx) = [ ]` or `this(Inx) = B`
        % where `B` is an empty model.
        this.Variant = subscripted(this.Variant, ixA, [ ]);
    end
    
elseif strcmp(s(1).type, '.')
    % this.Name(ix) = b
    % RHS must be numeric.
    
    name = s(1).subs;
    
    % Find the position of the Name in the Assign vector or stdcorr
    % vector.
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    % Create `Inx` for the third dimension.
    if length(s)>1
        % `this.Name(Inx) = B`
        v = s(2).subs{1};
    else
        % `this.Name = B`
        v = ':';
    end

    % Assign the value or throw an error.
    if ~isnan(posQty)
        try
            this.Variant.Values(:, posQty, v) = b;
        catch Err
            utils.error( ...
                'model:subsasgn', ...
                ['Error in model parameter assignment.\n', ...
                '\tUncle says: %s '], ...
                Err.message ...
            );
        end
    elseif ~isnan(posStdCorr)
        try
            this.Variant.StdCorr(:, posStdCorr, v) = b;
        catch Err
            utils.error( ...
                'model:subsasgn', ...
                ['Error in model parameter assignment.\n', ...
                '\tUncle says: %s '], ...
                Err.message ...
            );
        end
    else
        utils.error( ...
            'model:subsasgn', ...
            'This name does not exist in the model object: %s ', ...
            name ...
        );
    end

end

end



function s = checkSubscripted(s, n)
% Check and rearrange subscripted reference to models with mutliple parameter variants.

% This function accepts the following subscripts
%     x(subs)
%     x.name
%     x.(subs)
%     x.name(subs)
%     x(subs).name(subs)
% where subs is either logical or numeric or ':'
% and returns
%     x(numeric)
%     x.name(numeric)

% Convert x(subs1).name(subs2) to x.name(subs1(subs2)).
if length(s)==3 && any(strcmp(s(1).type,{'()','{}'})) ...
        && strcmp(s(2).type,{'.'}) ...
        && any(strcmp(s(3).type,{'()','{}'}))
    % convert a(subs1).name(subs2) to a.name(subs1(subs2))
    subs1 = s(1).subs{1};
    if strcmp(subs1, ':')
        subs1 = 1 : n;
    end
    subs2 = s(3).subs{1};
    if strcmp(subs2, ':')
        subs2 = 1 : length(subs1);
    end
    s(1) = [ ];
    s(2).subs{1} = subs1(subs2);
end

% Convert a(subs).name to a.name(subs).
if length(s)==2 && any(strcmp(s(1).type, {'()', '{}'})) ...
        && strcmp(s(2).type, {'.'})
    s = s([2, 1]);
end

if length(s)>2
    utils.error('model:subsasgn', ...
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

% Throw error for mutliple subscripts
% a(subs1, subs2, ...) or a.name(subs1, subs2,...).
if any(strcmp(s(end).type, {'()', '{}'}))
    if length(s(end).subs)~=1 || ~isnumeric(s(end).subs{1})
        utils.error('model:subsasgn', ...
            'Invalid reference to model object.');
    end
end

% Throw error if subscript is not real positive integer.
if any(strcmp(s(end).type,{'()','{}'}))
    ix = s(end).subs{1};
    if any(ix<1) || any(round(ix)~=ix) ...
            || any(imag(ix)~=0)
        utils.error('model:subsasgn', ...
            ['Subscript indices must be ', ...
            'either real positive integers or logicals.']);
    end
end

end
