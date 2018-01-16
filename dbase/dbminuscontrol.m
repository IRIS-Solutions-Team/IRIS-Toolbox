function [Dmc,C] = dbminuscontrol(varargin)
% dbminuscontrol  Create simulation-minus-control database.
%
%
% Syntax
% =======
%
%    [D,C] = dbminuscontrol(M,D)
%    [D,C] = dbminuscontrol(M,D,C)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object on which the databases `D` and `C` are
% based.
%
% * `D` [ struct ] - Simulation database.
%
% * `C` [ struct ] - Control database; if the input argument `C` is
% omitted the steady-state database of the model `M` is used for the
% control database.
%
%
% Output arguments
% =================
%
% * `D` [ struct ] - Simulation-minus-control database, in which all
% log variables are `d.x/c.x`, and all other variables are `d.x-c.x`.
%
% * `C` [ struct ] - Control database.
%
%
% Options
% ========
%
% * `'fresh='` [ `true` | *`false`* ] - If `true`, the output database will
% only contain entries corresponding to model variables in `M`; if `false`
% all other entries found in the input database will be also kept in the
% output database.
%
%
% Description
% ============
%
%
% Example
% ========
%
% We run a shock simulation in full levels using a steady-state (or
% balanced-growth-path) database as input, and then compute the deviations
% from the steady state.
%
%     d = sstatedb(m,1:40);
%     ... % Set up a shock or shocks here.
%     s = simulate(m,d,1:40);
%     s = dboverlay(d,s);
%     s = dbminuscontrol(m,s,d);
%
% The above block of code is equivalent to this one:
%
%     d = zerodb(m,1:40);
%     ... % Set up a shock or shocks here.
%     s = simulate(m,d,1:40,'deviation=',true);
%     s = dboverlay(d,s);
%

% -The IRIS Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

[This,D,C,varargin] = irisinp.parser.parse('dbase.dbminuscontrol',varargin{:});
opt = passvalopt('dbase.dbminuscontrol',varargin{:});

%--------------------------------------------------------------------------

list = [get(This,'YList'),get(This,'XList'),get(This,'EList')];
isLog = get(This,'IsLog');

if isempty(C)
    range = dbrange(D,list, ...
        'StartDate=','MaxRange','EndDate=','MaxRange');
    C = sstatedb(This,range);
end

Dmc = D;
ixKeep = true(size(list));
for i = 1 : length(list)
    name = list{i};
    if isfield(D,name) && isfield(C,name)
        if isLog.(name)
            func = @rdivide;
        else
            func = @minus;
        end
        try
            Dmc.(name) = bsxfun( ...
                func, ...
                real(D.(name)), ...
                real(C.(name)) ...
                );
            Dmc.(name) = comment(Dmc.(name),D.(name));
        catch %#ok<CTCH>
            ixKeep(i) = false;
        end
    else
        ixKeep(i) = false;
    end
end

if opt.fresh && any(~ixKeep)
    Dmc = rmfield(Dmc,list(~ixKeep));
end

end
