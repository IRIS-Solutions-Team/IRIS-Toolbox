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

    if startsWith(query, ["initCond", "required"], "ignoreCase", true)
        if startsWith(query, "required", "ignoreCase", true)
            logStyle = "none";
        else
            logStyle = "log()";
        end
        idInit = getIdInitialConditions(this);
        response = printSolutionVector(this, idInit, logStyle);
        return
    end

    flag = false;
    %)
end%

