function [s, range, select] = srf(this, time, varargin)
% srf  Shock response functions, first-order solution only.
%
% Syntax
% =======
%
%     S = srf(M,NPer,...)
%     S = srf(M,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose shock responses will be simulated.
%
% * `Range` [ numeric | char ] - Simulation date range with the first date
% being the shock date.
%
% * `NPer` [ numeric ] - Number of simulation periods.
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with shock response time series.
%
% Options
% ========
%
% * `'delog='` [ *`true`* | `false` ] - Delogarithmise shock responses for
% log variables afterwards.
%
% * `'select='` [ cellstr | *`@all`* ] - Run the shock response function
% for a selection of shocks only; `@all` means all shocks are simulated.
%
% * `'size='` [ *`@auto`* | numeric ] - Size of the shocks that will be
% simulated; `@auto` means that each shock will be set to its std dev
% currently assigned in the model object `M`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('model.srf', varargin{:});

if ischar(opt.select)
    opt.select = regexp(opt.select, '\w+', 'match');
end

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32); 
ne = sum(ixe);
nAlt = length(this.Variant);
lse = this.Quantity.Name(ixe);

% Select shocks.
if isequal(opt.select, @all)
    pos = 1 : ne;
else
    nSel = length(opt.select);
    pos = nan(1, nSel);
    for i = 1 : length(opt.select)
        x = find( strcmp(opt.select{i}, lse) );
        if length(x)==1
            pos(i) = x;
        end
    end
    chkShockSelection( );
end
select = lse(pos);
nSel = length(select);

% Set size of shocks.
if strcmpi(opt.size, 'std') ...
        || isequal(opt.size, @auto) ...
        || isequal(opt.size, @std)
    shkSize = model.Variant.getStdCorr(this.Variant, pos, ':');
else
    shkSize = opt.size*ones(1, nSel, nAlt);
end

func = @(T, R, K, Z, H, D, U, Omg, iAlt, nPer) ...
    timedom.srf(T, R(:, pos), [ ], Z, H(:, pos), [ ], U, [ ], ...
    nPer, shkSize(1, :, iAlt));

[s, range, select] = myrf(this, time, func, select, opt);
for i = 1 : length(select)
    s.(select{i}).data(1,i,:) = shkSize(1,i,:);
    s.(select{i}) = trim(s.(select{i}));
end

return


    

    function chkShockSelection( )
        if any(isnan(pos))
            utils.error('model:srf', ...
                'This is not a valid shock name: %s ', ...
                opt.select{isnan(pos)});
        end
        nonUnique = parser.getMultiple(pos);
        if ~isempty(nonUnique)
            utils.error('model:srf', ...
                'This shock name is requested more than once: %s ', ...
                opt.select{nonUnique});
        end
    end
end
