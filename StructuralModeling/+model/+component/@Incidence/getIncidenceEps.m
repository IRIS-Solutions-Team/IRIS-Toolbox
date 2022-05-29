function [epsCurrent, epsShifted] = getIncidenceEps(equationStrings, inxEquations, letter)
% getIncidenceEps  List of EPS incidences in select equations
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

PTR = @int32;
STRING_TO_NUM = @(x) sscanf(join(string(x)), '%g');
CURRENT_VARIABLE = '\<x\((\d+),t\)';
SHIFTED_VARIABLE = '\<x\((\d+),t([+\-]\d+)\)';
if nargin<2 || isequal(inxEquations, @all)
    inxEquations = true(size(equationStrings));
end
if nargin>=3
    CURRENT_VARIABLE = replace(CURRENT_VARIABLE, 'x', letter);
    SHIFTED_VARIABLE = replace(SHIFTED_VARIABLE, 'x', letter);
end

%--------------------------------------------------------------------------

numEquations = numel(equationStrings);
listShifted = cell(1, numEquations); % [^1]
listCurrent = cell(1, numEquations); % [^2]
% [^1]: List of incidences with time index other than zero
% [^2]: List of incidences with time index zero

%
% Convert equations that are function handles to char
%
inxFunc = cellfun('isclass', equationStrings, 'function_handle');
inxConvert = reshape(inxFunc, 1, [ ]) & reshape(inxEquations, 1, [ ]);
for i = find(inxConvert)
    equationStrings{i} = func2str(equationStrings{i});
end

%
% Look up current variables x(10,t)
%
listCurrent(inxEquations) = regexp( ...
    equationStrings(inxEquations), CURRENT_VARIABLE, 'tokens' ...
);

% EPS = [Equation; Position of Name; Shift]
epsCurrent = zeros(3, 0, 'int32');
for i = find(~cellfun('isempty', listCurrent)) % [^1]
    pos = reshape(STRING_TO_NUM([listCurrent{i}{:}]), 1, [ ]);
    n = numel(pos);
    add = [repmat(PTR(i), 1, n); PTR(pos); repmat(PTR(0), 1, n)];
    epsCurrent = [epsCurrent, add]; %#ok<AGROW>
end
% [^1]: Steady equations may be completely empty and hence containing no
% current dated variable

if nargout==1
    return
end

%
% Look up shifted variables x(10,t-2) or x(10,t+2)
%
listShifted(inxEquations) = regexp( ...
    equationStrings(inxEquations), SHIFTED_VARIABLE , 'tokens' ...
);

epsShifted = zeros(3, 0, 'int32');
for i = find(~cellfun('isempty', listShifted))
    posShift = reshape(STRING_TO_NUM([listShifted{i}{:}]), 1, [ ]);
    n = numel(posShift)/2;
    add = [repmat(PTR(i), 1, n); PTR(posShift(1:2:end)); PTR(posShift(2:2:end))];
    epsShifted = [epsShifted, add]; %#ok<AGROW>
end

end%

