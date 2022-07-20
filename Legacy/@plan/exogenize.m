function This = exogenize(This,List,Dates,Sigma)
% exogenize  Exogenize variables or re-exogenize shocks at the specified dates.
%
% Syntax
% =======
%
%     P = exogenize(P,List,Dates)
%     P = exogenize(P,Dates,List)
%     P = exogenize(P,List,Dates,Sigma)
%     P = exogenize(P,Dates,List,Sigma)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char ] - List of variables that will be exogenized,
% or list of shocks that will be re-exogenized.
%
% * `Dates` [ numeric | @all ] - Dates at which the variables will be
% exogenized; `@all` means the entire simulation range specified when
% creating the plan object.
%
% * `Sigma` [ `1` | `1i` ] - Only when re-exogenising shocks: Select the
% anticipation mode in which the shock will be re-exogenized; if omitted,
% `Sigma = 1`.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on exogenized
% variables included.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Sigma;
catch
    Sigma = 1;
end

if isnumeric(List) && (ischar(Dates) || iscellstr(Dates))
    [List,Dates] = deal(Dates,List);
end

% Parse required input arguments.
isnumericscalar = @(x) isnumeric(x) && isscalar(x);
pp = inputParser( );
pp.addRequired('List',@(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
pp.addRequired('Dates',@(x) isnumeric(x) || isequal(x,@all) );
pp.addRequired('Weight', ...
    @(x) isnumericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0 && x ~= 0 );
pp.parse(List,Dates,Sigma);

% Convert char list to cell of str.
if ischar(List)
    List = regexp(List,'[A-Za-z]\w*','match');
elseif isa(List, 'string')
    List = cellstr(List);
end

if isempty(List)
    return
end

%--------------------------------------------------------------------------

Dates = double(Dates);
[Dates,outOfRange] = mydateindex(This,Dates);
if ~isempty(outOfRange)
    % Report invalid dates.
    utils.error('plan:exogenize', ...
        'These dates are out of simulation plan range: %s.', ...
        dat2charlist(outOfRange));
end

nList = numel(List);
valid = true(1,nList);

for i = 1 : nList
    % Try to exogenize an endogenous variable.
    index = strcmp(This.XList,List{i});
    if any(index)
        This.XAnch(index,Dates) = true;
    else
        % Try to re-exogenize a shock.
        index = strcmp(This.NList,List{i});
        if any(index)
            if real(Sigma) > 0
                This.NAnchReal(index,Dates) = false;
                This.NWghtReal(index,Dates) = 0;
            elseif imag(Sigma) > 0
                This.NAnchImag(index,Dates) = false;
                This.NWghtImag(index,Dates) = 0;
            end
        else
            % Neither worked.
            valid(i) = false;
        end
    end
end

% Report invalid names.
if any(~valid)
    utils.error('plan:exogenize', ...
        'Cannot exogenize this name: ''%s''.', ...
        List{~valid});
end

end
