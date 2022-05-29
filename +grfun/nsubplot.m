function varargout = nsubplot(SubPlotOpt,NPanel)
% nsubplot  [Not a public function] Determin subplot division from option subplot=.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(SubPlotOpt,@auto)
    x = ceil(sqrt(NPanel));
    if x*(x-1) >= NPanel
        nRow = x;
        nCol = x-1;
    else
        nRow = x;
        nCol = x;
    end
elseif isnumeric(SubPlotOpt) && length(SubPlotOpt) == 2
    nRow = SubPlotOpt(1);
    nCol = SubPlotOpt(2);
elseif isnumeric(SubPlotOpt) && length(SubPlotOpt) == 1
    nRow = SubPlotOpt(1);
    nCol = SubPlotOpt(1);
else
    nRow = NaN;
    nCol = NaN;
end

if nRow <= 0 || nCol <= 0
    nRow = 0;
    nCol = 0;
end

if nargout <= 1
    varargout{1} = [nRow,nCol];
else
    varargout = {nRow,nCol};
end

end
