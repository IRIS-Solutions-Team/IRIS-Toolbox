function Flag = isdatrangeproper(X)
% isdatrangeproper  [Not a public function] True for proper date range.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = true;

if ~isdatinp(X)
    Flag = false;
    return
end

if ischar(X)
    X = textinp2dat(X);
end

if isequal(X,@all) || isempty(X) || ( isnumeric(X) && all(isinf(X)) )
    Flag = false;
    return
end

if ~all(freqcmp(X))
    Flag = false;
    return
end

end
