function pri = parseEstimStruct(this, est, pri, startIfNan, penalty, initVal)

if isempty(initVal)
    initVal = 'struct';
end

%--------------------------------------------------------------------------

np = numel(pri.LsParam);

pri.Init = nan(1, np);
pri.Lower = nan(1, np);
pri.Upper = nan(1, np);
pri.FnPrior = cell(1, np);
pri.IxPrior = false(1, np);

ixValidBounds = true(1, np);
ixWithinBounds = true(1, np);
ixPenaltyFunction = false(1, np);

doParameters( );
reportViolationOfBounds( );

% Penalty specification is obsolete.
reportPenaltyFunc( );

% Remove parameter fields and return a struct with non-parameter fields.
est = rmfield(est, pri.LsParam);

return


    function doParameters( )
        for ii = 1 : np
            name = pri.LsParam{ii};
            spec = est.(name);
            if isnumeric(spec)
                spec = num2cell(spec);
            end
            
            % __Starting Value__
            if isstruct(initVal) ...
                    && isfield(initVal,name) ...
                    && isnumeric(initVal.(name)) && numel(initVal.(name))==1
                p0 = initVal.(name);
            elseif ischar(initVal) && strcmpi(initVal, 'struct') ...
                    && ~isempty(spec) && isnumeric(spec{1}) && numel(spec{1})==1
                p0 = spec{1};
            else
                p0 = NaN;
            end
            % If the starting value is `NaN` at this point, use the currently assigned
            % value from the model object, `startIfNan`.
            if isequaln(p0, NaN)
                p0 = startIfNan(ii);
            end
            
            % __Lower and Upper Bounds__
            % Lower bound.
            if length(spec)>1 && isnumeric(spec{2}) && numel(spec{2})==1
                pl = spec{2};
            else
                pl = -Inf;
            end
            % Upper bound.
            if length(spec)>2  && isnumeric(spec{3}) && numel(spec{3})==1
                pu = spec{3};
            else
                pu = Inf;
            end
            % Check that the lower bound is lower than the upper bound.
            if pl>=pu
                ixValidBounds(ii) = false;
                continue
            end
            % Check that the starting values in within the bounds.
            if p0<pl || p0>pu
                ixWithinBounds(ii) = false;
                continue
            end
            
            % __Prior Distribution Function__
            % The 4th element in the estimation struct can be either a prior
            % distribution function (a function_handle) or penalty function, i.e. a
            % numeric vector [weight] or [weight,pbar]. The latter option is only for
            % bkw compatibility, and will be deprecated.
            isPrior = false;
            fnPrior = [ ];
            if length(spec)>3 && ~isempty(spec{4})
                if isa(spec{4}, 'distribution.Distribution')
                    fnPrior = spec{4};
                    isPrior = true;
                elseif isa(spec{4},'function_handle')
                    % The 4th element is a prior distribution function handle.
                    fnPrior = spec{4};
                    isPrior = true;
                elseif isnumeric(spec{4}) && numel(spec{4})==1  && penalty>0
                    % The 4th element is a penalty function.
                    ixPenaltyFunction(ii) = true;
                    fnPrior = penalty2Prior(spec, p0, startIfNan(ii), penalty);
                    isPrior = true;
                end
            end
            
            % __Populate the `Pri` struct__
            pri.Init(ii) = p0;
            pri.Lower(ii) = pl;
            pri.Upper(ii) = pu;
            pri.FnPrior{ii} = fnPrior;
            pri.IxPrior(ii) = isPrior;
        end
    end


    function reportViolationOfBounds( )
        % Report bounds where lower>=upper.
        if any(~ixValidBounds)
            utils.error(class(this), ...
                ['Lower and upper bounds for this parameter ', ...
                'are inconsistent: ''%s''.'], ....
                pri.LsParam{~ixValidBounds});
        end
        % Report bounds where start<lower or start>upper.
        if any(~ixWithinBounds)
            utils.error(class(this), ...
                ['Starting value for this parameter is ', ...
                'outside the specified bounds: ''%s''.'], ....
                pri.LsParam{~ixWithinBounds});
        end
    end


    function reportPenaltyFunc( )
        if any(ixPenaltyFunction)
            exception.warning([
                "Deprecated"
                "Some parameter priors are specified as penalty functions;" 
                "penalty functions are deprecated and will be removed from a future version of IRIS;"
                "replace them with normal prior distributions."
            ]);
        end
    end
end


function fnPrior = penalty2Prior(spec, p0, startIfNan, penalty)
    % The 4th entry is a penalty function, compute the
    % total weight including the Penalty option.
    totalWeight = spec{4}(1)*penalty;
    if numel(spec{4})==1
        % Only the weight specified. The centre of penalty
        % function is then set identical to the starting
        % value.
        pBar = p0;
    else
        % Both the weight and the centre specified.
        pBar = spec{4}(2);
    end
    if isnan(pBar)
        pBar = startIfNan;
    end
    % Convert penalty function to a normal prior:
    %
    % w*(p - pbar)^2==1/2*((p - pbar)/sgm)^2 => sgm =
    % 1/sqrt(2*w).
    %
    sgm = 1/sqrt(2*totalWeight);
    fnPrior = distribution.Normal('MeanStd', pBar, sgm);
end
