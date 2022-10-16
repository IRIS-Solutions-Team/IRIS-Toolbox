% retrieve  Retrieve a subset of equations with selected attributes or LHS names
%{
% Syntax
%--------------------------------------------------------------------------
%
%     outputExpy = function(inputExpy, test1, test2, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputExpy`__ [ Explanatory ]
%
%>    Explanatory object or array from which a subset of equations will be
%>    retrieved, based on the attributes or LHS names in `test1`, `test2`,
%>    etc.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputExpy`__ [ Explanatory ]
%
%>    Output Explanatory object or array where only a subset of the
%>    equations from the `inputExpy` is included, based on the attributes
%>    or LHS names in `test1`, `test2`, etc.
%
%
% __`test`__ [ string ]
%
%>    An attribute or the name of an LHS variable; each equation that has
%>    at least one of the attributes specified or at least one of the LHS
%>    names specified will be included in `outputExpy`.
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
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function this = retrieve(this, varargin)

    inx = lookup(this, varargin{:});

    if all(inx)
        return
    end

    this = this(inx);

end%

