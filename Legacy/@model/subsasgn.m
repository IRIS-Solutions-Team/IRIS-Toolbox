function this = subsasgn(this, s, b)
% subsasgn  Subscripted assignment for model objects
%{
% ## Syntax for Assigning Parameter Variant from Another Object ##
%
%     m(index) = n
%
%
% ## Syntax for Deleting Specified Parameter Variants ##
%
%     m(index) = [ ]
%
%
% ## Syntax for Assigning Parameter Values or Steady Values ##
%
%     m.name = X
%     m(index).Name = X
%     m.name(index) = X
%
%
% ## Syntax for Assigning Std Deviations or Cross-Correlations of Shocks ##
%
%     m.std_name = X
%     m.corr_name1__name2 = X
%
% Double underscore is used to separate the names of shocks in correlation
% coefficients.
%
%
% ## Input Arguments ##
%
% * `m` [ model ] - Model object that will be assigned new parameter
% variants or new parameter values or new steady values.
%
% * `n` [ model ] - Model object compatible with `m` whose parameter
% variants will be assigned (copied) into `m`.
%
% * `index` [ numeric | logical ] - index (positional or logical) of
% parameter variants that will be assigned or deleted.
%
% * `name`, `name1`, `name2` [ char ] - Name of a variable, shock, or
% parameter.
%
% * `X` [ numeric ] - A value (or a vector of values) that will be assigned
% to a parameter or variable Named `name`.
%
%
% ## Output Arguments ##
%
% * `m` [ model ] - Model object with newly assigned or deleted parameter
% variants, or with newly assigned parameters, or steady values.
%
%
% ## Description ##
%
%
% ## Example ##
%
% Expand the number of parameter variants in a model object that has
% initially just one parameter variant:
%
%     m(1:10) = m;
%
% The parameter variants is simply copied ten times within the model
% object.
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

hereCheckInputArguments( );

nv = countVariants(this);

%
% Dot-Name Assignment
%     m.Name = x
%
if isnumeric(b) && (numel(b)==1 || numel(b)==nv) && numel(s)==1 && s(1).type=='.'
    name = char(s(1).subs);
    this = assignNameValue(this, char(s(1).subs), b);
    return
end

s = locallyCheckSubscripted(s, nv);

%
% Regular Assignment
%     this(inx) = b
% RHS must be a compatible Model object or empty
%
if any(strcmp(s(1).type, {'()', '{}'}))
    hereCheckRhsObject( );

    inxA = s(1).subs{1};
    
    % `this([ ]) = B` leaves `this` unchanged.
    if isempty(inxA)
        return
    end
    
    if isa(b, 'model') && ~isempty(b)
        % `this(Inx) = B`
        % where `B` is a non-empty model whose length is either 1 or the same as
        % the length of `this(Inx)`.
        nb = countVariants(b);
        if nb==1
            inxB = ones(size(inxA));
        else
            inxB = ':';
            if numel(inxA)~=nb && nb~=0
                exception.error([
                    "Model:InvalidNumVariants"
                    "The number of parameter variants on the LHS and the RHS "
                    "of a subscripted assignment must be the same."
                ]);
            end
        end
        this.Variant = subscripted(this.Variant, inxA, b.Variant, inxB);
    else
        % `this(Inx) = [ ]` or `this(Inx) = B`
        % where `B` is an empty model.
        this.Variant = subscripted(this.Variant, inxA, [ ]);
    end
    
elseif strcmp(s(1).type, '.')
    % this.Name(inx) = b
    % RHS must be numeric.
    
    name = s(1).subs;
    
    % Find the position of the Name in the Assign vector or stdcorr
    % vector.
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    % Create `Inx` for the third dimension.
    if numel(s)>1
        % `this.Name(Inx) = B`
        v = s(2).subs{1};
    else
        % `this.Name = B`
        v = ':';
    end

    %
    % Try assign the value if it's a valid name
    %
    try
        if ~isnan(posQty)
            this.Variant.Values(:, posQty, v) = b;
        elseif ~isnan(posStdCorr)
            this.Variant.StdCorr(:, posStdCorr, v) = b;
        end
    catch Err
        exception.error([ 
            "Model:InvalidParameterAssignment"
            "Error in a parameter assignment to a Model object. "
            "\n%s" 
        ], Err.message);
    end

    %
    % Throw an error if the name is invalid
    %
    if isnan(posQty) && isnan(posStdCorr)
        exception.error([ 
            "Model:InvalidNameInAssignment"
            "This name does not exist in the Model object: %s "
        ]);
    end

end

return

    function hereCheckInputArguments( )
        if ~isa(this, 'model') ...
                || ( ~isa(b, 'model') && ~isempty(b) && ~isnumeric(b) && ~islogical(b) )
            exception.error([
                "Model:InvalidSubscriptedAssignment"
                "Invalid subscripted assignment to Model object."
            ]);
        end
    end%


    function hereCheckRhsObject( )
        if ~isa(b, 'model') && ~isempty(b)
            exception.error([
                "Model:InvalidSubscriptedAssignment"
                "Invalid subscripted assignment to Model object."
            ]);
        end
        
        if ~isempty(b) && ~testCompatible(this, b)
            exception.error([
                "Model:IncompatibleObjectsInSubscriptedAssignment"
                "Model objects on the LHS and the RHS of a subsripted assignment "
                "are incompatible."
            ]);
        end
    end%
end%



function s = locallyCheckSubscripted(s, n)
% Check and rearrange subscripted reference to models with mutliple parameter variants

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

% Convert x(subs1).name(subs2) to x.name(subs1(subs2))
if numel(s)==3 && any(strcmp(s(1).type, {'()', '{}'})) ...
        && strcmp(s(2).type, {'.'}) ...
        && any(strcmp(s(3).type, {'()', '{}'}))
    % convert a(subs1).name(subs2) to a.name(subs1(subs2))
    subs1 = s(1).subs{1};
    if strcmp(subs1, ':')
        subs1 = 1 : n;
    end
    subs2 = s(3).subs{1};
    if strcmp(subs2, ':')
        subs2 = 1 : numel(subs1);
    end
    s(1) = [ ];
    s(2).subs{1} = subs1(subs2);
end

% Convert a(subs).name to a.name(subs)
if numel(s)==2 && any(strcmp(s(1).type, {'()', '{}'})) ...
        && strcmp(s(2).type, {'.'})
    s = s([2, 1]);
end

if numel(s)>2
    hereThrowInvalidLhsReference( );
end

% Convert a(:) or a.name(:) to a(1:n) or a.name(1:n)
% Convert a(logical) or a.name(logical) to a(numeric) or a.name(numeric)
if any(strcmp(s(end).type, {'()', '{}'}))
    if strcmp(s(end).subs{1}, ':')
        s(end).subs{1} = 1 : n;
    elseif islogical(s(end).subs{1})
        s(end).subs{1} = find(s(end).subs{1});
    end
end

% Throw error for mutliple subscripts
% a(subs1, subs2, ...) or a.name(subs1, subs2, ...)
if any(strcmp(s(end).type, {'()', '{}'}))
    if numel(s(end).subs)~=1 || ~isnumeric(s(end).subs{1})
        hereThrowInvalidLhsReference( );
    end
end

% Throw error if subscript is not real positive integer
if any(strcmp(s(end).type, {'()', '{}'}))
    inx = s(end).subs{1};
    if ~isnumeric(inx)
        if islogical(inx)
            inx = find(inx);
        else
            hereThrowInvalidLhsReference( );
        end
    end
    if any(inx<1) || any(inx>n) || any(round(inx)~=inx) || any(imag(inx)~=0)
        hereThrowInvalidLhsReference( );
    end
end

return

    function hereThrowInvalidLhsReference( )
        exception.error([
            "Model:InvalidLhsReferenceInAssignment"
            "Invalid reference to the LHS Model object in a subscripted assignment."
        ]);
    end%
end%

