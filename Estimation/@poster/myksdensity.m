% myksdensity  [Not a public function] Return x- and y-coordinates for posterior distribution graph.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*CTCH>

function [X,Y] = myksdensity(Theta,Low,High,NPoints)

isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;

if isinf(High) && ~isinf(Low) && Low ~= 0
    if Low > 0
        Low = 0;
    else
        High = 1e10;
    end
elseif isinf(Low) && ~isinf(High) && High ~= 0
    if High < 0
        High = 0;
    else
        Low = -1e10;
    end
end

try
    if isintscalar(NPoints)
        npoints = NPoints;
    else
        npoints = 100;
    end
    [Y,X] = ksdensity(Theta,'support',[Low,High],'npoints',npoints);
catch 
    if isintscalar(NPoints)
        npoints = NPoints;
    else
        npoints = 2^10;
    end
    try
        [~,Y,X] = thirdparty.kde(Theta,npoints,Low,High);
    catch
        nTheta = length(Theta);
        npoints = max(2,round(nTheta/50));
        [Y,X] = hist(Theta,npoints);
        width = X(2) - X(1);
        Y = (Y/nTheta) / width;
    end
end

end
