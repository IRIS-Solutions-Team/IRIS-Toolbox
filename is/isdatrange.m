function Flag = isdatrange(X)
% isdatrange  [Not a public function] True for date range.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isdatinp(X);

if Flag && ~isequal(X,Inf) && ~isequal(X,@all) ...
        && ~isinf(X(1)) && ~isinf(X(end))
    if ischar(X)
        X = textinp2dat(X);
    end
    Flag = all(freqcmp(X));
end

end
