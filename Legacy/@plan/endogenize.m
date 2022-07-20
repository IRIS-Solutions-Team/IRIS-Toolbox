function This = endogenize(This,List,Dates,Sigma)
% endogenize  Endogenize shocks or re-endogenize variables at the specified dates.
%
%
% Syntax
% =======
%
%     P = endogenize(P,List,Dates)
%     P = endogenize(P,Dates,List)
%     P = endogenize(P,List,Dates,Sigma)
%     P = endogenize(P,Dates,List,Sigma)
%
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char ] - List of shocks that will be endogenized, or
% list of variables that will be re-endogenize.
%
% * `Dates` [ numeric | `@all` ] - Dates at which the shocks or variables
% will be endogenized; `@all` means the entire simulation range specified
% when creating the plan object.
%
% * `Sigma` [ `1` | `1i` | numeric ] - Anticipation mode (real or
% imaginary) for endogenized shocks, and their numerical weight (used
% in underdetermined simulation plans); if omitted, `Sigma = 1`.
%
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on endogenized
% shocks included.
%
%
% Description
% ============
%
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
pp.addRequired('List',@(x) ischar(x) || iscellstr(x) );
pp.addRequired('Dates',@(x) isnumeric(x) || isequal(x,@all) );
pp.addRequired('Weight', ...
    @(x) isnumericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0 );
pp.parse(List,Dates,Sigma);

% Convert char list to cell of str.
if ischar(List)
    List = regexp(List,'[A-Za-z]\w*','match');
end

if isempty(List)
    return
end

%--------------------------------------------------------------------------

Dates = double(Dates);
[Dates,outOfRange] = mydateindex(This,Dates);
if ~isempty(outOfRange)
    % Report invalid dates.
    utils.error('plan:endogenize', ...
        'These dates are out of simulation plan range: %s.', ...
        dat2charlist(outOfRange));
end

nList = numel(List);
valid = true(1,nList);

for i = 1 : nList
    % Try to endogenize a shock.
    inx = strcmp(This.NList,List{i});
    if any(inx)
        if Sigma == 0
            % Re-exogenize the shock again.
            This.NAnchReal(inx,Dates) = false;
            This.NAnchImag(inx,Dates) = false;
            This.NWghtReal(inx,Dates) = 0;
            This.NWghtImag(inx,Dates) = 0;
        else
            if real(Sigma) ~= 0
                % Real endogenized shocks.
                This.NAnchReal(inx,Dates) = true;
                This.NWghtReal(inx,Dates) = abs(real(Sigma));
            end
            if imag(Sigma) ~= 0
                % Imaginary endogenized shocks.
                This.NAnchImag(inx,Dates) = true;
                This.NWghtImag(inx,Dates) = abs(imag(Sigma));
            end
        end
    else
        % Try to re-endogenize an endogenous variable.
        inx = strcmp(This.XList,List{i});
        if any(inx)
            This.XAnch(inx,Dates) = false;
        else
            % Neither worked.
            valid(i) = false;
        end
    end
end

% Report invalid names.
if any(~valid)
    utils.error('plan:endogenize', ...
        'Cannot endogenize this name: ''%s''.', ...
        List{~valid});
end

end
