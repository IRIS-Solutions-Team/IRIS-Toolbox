function d = derv(this, mode, wrt, isSimplify)
% derv  [Not a public function] Compute first derivatives wrt specified variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try, isSimplify; catch, isSimplify = true; end %#ok<NOCOM,VUNUS>

nWrt = length(wrt);
if nWrt==0
    utils.error('sydney:derv', ...
        'Empty list of Wrt variables');
end

%--------------------------------------------------------------------------

if isequal(mode, 'enbloc')
    % Create one sydney that evaluates to array of derivatives.
    d = mydiff(this, wrt);
    % Handle special case when there is no occurence of any of the `wrt`
    % variables in the expression, and a scalar zero is returned.
    if nWrt > 1 && isempty(d.Func) && isequal(d.args,0)
        d.args = false(nWrt,1);
        d.lookahead = false;
    elseif isSimplify
        if nWrt==1
            d = reduce(d, 1);
        else
            d = reduce(d);
        end
    end
elseif isequal(mode, 'separate')
    % Create cell array of sydneys.
    z = mydiff(this, wrt);
    d = cell(1,nWrt);
    for i = 1 : nWrt
        d{i} = reduce(z, i);
    end
else
    utils.error('sydney:derv', ...
        'Invalid output mode.');
end

end
