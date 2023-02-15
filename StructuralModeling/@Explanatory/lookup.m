% lookup  Look up equations by the LHS names or attributes
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     [inx, output, lhsNames] = lookup(input [, lookFor])
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`input`__ [ Explanatory ]
%
%     Input Explanatory object or array from which a subset of equations
%     will be extracted.
%
%
% __`lookFor`__ [ string ]
%
%     LHS name or attribute that will be searched for in the `input`
%     Explanatory object or array.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`inx`__ [ logical ]
% 
%     Logical index of equations within the `input` Explanatory object or
%     array that have at least one of the LHS names or attributes specified
%     as the second and further input arguments `lookFor`.
%
%
% __`output`__ [ Explanatory ]
%
%     Output Explanatory object or array with only those equations included
%     that have at least one of the LHS names or attributes specified as
%     the second and further input arguments `lookFor`.
%
%
% __`lhsNames`__ [ string ]
%
%     List of LHS names for the equations included in the `output`.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [inx, this, lhsNames] = lookup(this, varargin)

    operator = @or;
    if ~isempty(varargin) && isa(varargin{1}, 'function_handle')
        operator = varargin{1};
        varargin(1) = [];
    end

    if isequal(operator, @or)
        inx = false(size(this));
    elseif isequal(operator, @and)
        inx = true(size(this));
    end

    lhsNames = reshape([this.LhsName], size(this));

    for v = varargin
        for identifier = reshape(strip(string(v{:})), 1, [])
            if startsWith(identifier, ":")
                inx = operator(inx, hasAttribute(this, identifier));
            else
                inx = operator(inx, lhsNames==identifier);
            end
        end
    end

    if nargout>=2
        this = reshape(this(inx), [], 1);
        if nargout>=3
            lhsNames = reshape(lhsNames(inx), 1, []);
        end
    end

end%

