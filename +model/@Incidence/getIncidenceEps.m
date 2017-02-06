function [epsCurrent, epsShifted] = getIncidenceEps(eqn, ixSelect)
% getIncidenceEps  List of EPS incidences in select equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int32;
FN_CELLSTR2NUM = @(x) sscanf( sprintf('%s,', x{:}), '%g,' ).';

%--------------------------------------------------------------------------

nEqn = length(eqn);
lsShifted = cell(1, nEqn);
lsCurrent = cell(1, nEqn);

% Convert equations that are function handles to char.
ixFunc = cellfun(@(x) isa(x, 'function_handle'), eqn);
ixConvert = ixFunc & ixSelect;
if any(ixConvert)
    eqn(ixConvert) = cellfun( ...
        @(x) func2str(x), ...
        eqn(ixConvert), ...
        'UniformOutput', false ...
        );
end

% Look for x(10,t).
lsCurrent(ixSelect) = regexp( ...
    eqn(ixSelect), ...
    '\<x\((\d+),t\)', ...
    'tokens' ...
    );

% EPS = [Equation; Position of Name; Shift]
epsCurrent = zeros(3, 0, 'int32');
for iEqn = find( ~cellfun(@isempty, lsCurrent) ) % 1/
    temp = FN_CELLSTR2NUM( [ lsCurrent{iEqn}{:} ] );
    n = length(temp);
    add = [repmat(PTR(iEqn), 1, n); PTR(temp); repmat(PTR(0), 1, n)];
    epsCurrent = [epsCurrent, add]; %#ok<AGROW>
end

% 1/ Steady equations may be completely empty and hence containing no
% current dated variable.

if nargout==1
    return
end

% Look for x(10,t-2) or x(10,t+2).
lsShifted(ixSelect) = regexp( ...
    eqn(ixSelect), ...
    '\<x\((\d+),t([+\-]\d+)\)', ...
    'tokens' ...
    );

epsShifted = zeros(3, 0, 'int32');
for iEqn = find( ~cellfun(@isempty, lsShifted) )
    temp = FN_CELLSTR2NUM( [ lsShifted{iEqn}{:} ] );
    n = length(temp)/2;
    add = [repmat(PTR(iEqn), 1, n); PTR(temp(1:2:end)); PTR(temp(2:2:end))];
    epsShifted = [epsShifted, add]; %#ok<AGROW>
end

end
