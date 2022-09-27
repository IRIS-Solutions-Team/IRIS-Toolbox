%{
% 
% # `subsref` ^^(Model)^^
% 
% {== Subscripted reference for Model objects ==}
% 
% 
% ## Syntax for retrieving object with subset of parameter variants
% 
%      m(index)
% 
% 
% ## Syntax for retrieving parameters or steady-state values
% 
%      m.name
% 
% 
% ## Syntax to retrieve std deviations or cross-correlation of shocks
% 
%      m.std_shock
%      m.corr_shock1__shock2
% 
% 
%  Note that a double underscore is used to separate the names of shocks in
%  correlation coefficients.
% 
% 
% ## Input Arguments
% 
% __`m`__ [ Model ]
% > 
% > Model object.
% >  
% 
% 
% __`index`__ 
% > 
% > Index (positional or logical) of requested parameterisations.
% > 
% 
% 
% __`name`__ 
% > 
% > Name of a variable, shock, or parameter.
% > 
% 
% __`shock`, `shock1`, `shock2`__
% > 
% > Names of shocks.
% >  
% 
% ## Description
% 
% 
% 
% ## Examples
% 
% ```matlab
% ```
% 
%}
% --8<--


function output = subsref(this, s)

nv = countVariants(this);

% Dot-name reference m.name
if isequal(s(1).type,'.') && validate.string(s(1).subs) 
    name = char(s(1).subs);
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    if ~isnan(posQty)
        % Quantity
        output = this.Variant.Values(:, posQty, :);
        output = permute(output, [1, 3, 2]);
    elseif ~isnan(posStdCorr)
        % Std or Corr
        output = this.Variant.StdCorr(:, posStdCorr, :);
        output = permute(output, [1, 3, 2]);
    elseif nv==1 && contains(name, ',..,')
        % Double dot reference ,..,
        list = parser.DoubleDot.parse(name, parser.DoubleDot.COMMA);
        list = regexp(string(list), "\w+", "match");
        numList = numel(list);
        output = nan(1, numList);
        for i = 1 : numList
            output(i) = subsref(this, substruct('.', list(i)));
        end
    else
        behavior = this.Behavior.InvalidDotReference;
        if strcmpi(behavior, 'Error')
            throw( exception.Base('Model:InvalidName', 'Error'), '', name ); %#ok<GTARG>
        elseif strcmpi(behavior, 'Warning')
            % Return NaN with a warning
            throw( exception.Base('Model:InvalidName', 'Warning'), '', name ); %#ok<GTARG>
            output = nan(1, nv);
            return
        else
            % Return NaN silently
            output = nan(1, nv);
            return
        end
    end
    if isa(this.Behavior.DotReferenceFunc, 'function_handle')
        output = feval(this.Behavior.DotReferenceFunc, output);
    end
    s(1) = [ ];
    if ~isempty(s)
        output = subsref(output, s);
    end
    return
end

if strcmp(s(1).type, '()') && numel(s(1).subs)==1 && isnumeric(s(1).subs{1})
    % m(pos)
    variantsRequested = s(1).subs{1};
    output = getVariant(this, variantsRequested);
    s(1) = [ ];
    if ~isempty(s)
        output = subsref(output, s);
    end
    return
end

if strcmp(s(1).type, '{}') && numel(s(1).subs)==1 ...
        && (ischar(s(1).subs{1}) || isstring(s(1).subs{1}))
    % m{'query'} or m{"query"}
    output = access(this, s(1).subs{1});
    return
end

exception.error([
    "Model"
    "Invalid subscripted reference to a Model object."
]);

end%

