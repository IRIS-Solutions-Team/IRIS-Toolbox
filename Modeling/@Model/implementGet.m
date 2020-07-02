% implementGet  Implement get method for Model objects
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [response, flag, query] = implementGet(this, query, varargin)

%--------------------------------------------------------------------------

[response, flag, query] = locallyGet(this, query, varargin{:});
if flag, return, end

[response, flag, query] = implementGet@model(this, query, varargin{:});

end%


%
% Local Functions
%


function [response, flag, query] = locallyGet(this, query, varargin)
    %(
    response = [ ];
    flag = true;
    isQuery = @(varargin) any(strcmpi(query, varargin));

    if isQuery('InitCond', 'Required') 
        idInit = getIdOfInitialConditions(this);
        response = printSolutionVector(this, idInit);
        return
    end

    flag = false;
    %)
end%

