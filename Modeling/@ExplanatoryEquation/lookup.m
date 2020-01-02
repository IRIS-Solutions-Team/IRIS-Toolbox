function [inx, output] = lookup(this, varargin)
% lookup  Look up equations by the LHS names or attributes
%{
% ## Syntax ##
%
%
%     [inx, output] = function(input [, lookFor])
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ ExplanatoryEquation ]
% >
% Input ExlanatoryEquation object or array from which a subset of equations
% will be extracted.
%
%
% __`lookFor`__ [ char | string ]
% >
% LHS name or attribute that will be searched for in the `input`
% ExplanatoryEquation object or array.
%
%
% ## Output Arguments ##
%
%
% __`inx`__ [ logical ]
% >
% Logical index of equations within the `input` ExplanatoryEquation object
% or array that have at least one of the LHS names or attributes specified
% as the second and further input arguments `lookFor`.
%
%
% __`output`__ [ ExplanatoryEquation ]
% >
% Output ExplanatoryEquation object or array with only those equations
% included that have at least one of the LHS names or attributes specified
% as the second and further input arguments `lookFor`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

inx = false(size(this));
lhsNames = reshape([this.LhsName], size(this));

for i = 1 : numel(varargin)
    identifier = string(varargin{i});
    if startsWith(identifier, ":")
        inx = inx | hasAttribute(this, identifier);
    else
        inx = inx | lhsNames==identifier;
    end
end

if nargout>=2
    output = this(inx);
end

end%

