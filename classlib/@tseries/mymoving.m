function X = mymoving(X,Win,Func)
% mymoving  [Not a public function] Function applied to moving window of observations.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Win = Win(:).';
if isempty(Win)
    utils.warning('tseries:mymoving', ...
        'The moving window is empty.');
    X(:) = NaN;
else
    for i = 1 : size(X,2)
        X(:,i) = feval(Func,tseries.myshift(X(:,i),Win),2);
    end
end

end
