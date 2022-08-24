% fill  Populate incidence matrices
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, epsCurrent, epsShifted] = fill(this, qty, equationStrings, inxEquations, varargin)

PTR = @int32;

t0 = PTR(find(this.Shift==0)); %#ok<FNDSB>
numShifts = numel(this.Shift);
numEquations = numel(equationStrings);
numQuantities = numel(qty.Name);


matrix = full(this.Matrix);

%
% Reset incidence in inxEquations
%
matrix(inxEquations, :) = false;


%
% Get equation, position of name, shift
%
[epsCurrent, epsShifted] = model.Incidence.getIncidenceEps( ...
    equationStrings, inxEquations, varargin{:} ...
);


%
% Place current dated incidence in the incidence matrix
%
epsCurrent = locallyRemovePosBeyondNumQuantities(epsCurrent, numQuantities); % [^1]
ind = sub2ind( ...
    [numEquations, numQuantities, numShifts] ...
    , epsCurrent(1, :), epsCurrent(2, :), t0+epsCurrent(3, :) ...
);
matrix(ind) = true;


%
% Place time shifted incidence in the incidence matrix
%
epsShifted = locallyRemovePosBeyondNumQuantities(epsShifted, numQuantities); % [^1]
ind = sub2ind( ...
    [numEquations, numQuantities, numShifts] ...
    , epsShifted(1, :), epsShifted(2, :), t0+epsShifted(3, :) ...
);
matrix(ind) = true;

this.Matrix = sparse(matrix);

end%


%
% Local Functions
%


function eps = locallyRemovePosBeyondNumQuantities(eps, numQuantities) % [^1]
    inxToRemove = eps(2, :)>numQuantities;
    if any(inxToRemove)
        eps(:, inxToRemove) = [ ];
    end
end%

% [^1]: Incidence is sometimes also calculated for !links in which case
% there might be references to std or corr; these are excluded here.


