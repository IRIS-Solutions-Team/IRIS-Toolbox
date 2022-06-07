

% >=R2019b
%{
function varargout = radar(X, opt)

arguments
    X double

    opt.AxesHandle = @polaraxes
    opt.AxesSettings (1, :) cell = cell.empty(1, 0)
    opt.ColumnNames (1, :) string = string.empty(1, 0)
    opt.PlotSettings (1, :) cell = cell.empty(1, 0)
end
%}
% >=R2019b


% <=R2019a
%(
function varargout = radar(X, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();

    addParameter(ip, "AxesHandle", @polaraxes);
    addParameter(ip, "AxesSettings", cell.empty(1, 0));
    addParameter(ip, "ColumnNames", string.empty(1, 0));
    addParameter(ip, "PlotSettings", cell.empty(1, 0));
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


if isa(opt.AxesHandle, 'function_handle')
    opt.AxesHandle = opt.AxesHandle();
end

X = double(X);
numDirections = size(X, 1);
theta = linspace(0, 2*pi, numDirections+1);
grad = linspace(0, 360, numDirections+1);
rho = [X(:, :); X(1, :)]

nextPlot = get(opt.AxesHandle, "nextPlot");
set(opt.AxesHandle, "nextPlot", "add");
numColumns = size(rho, 2);
plotHandles = gobjects(1, numColumns);
for i = 1 : numColumns
    plotHandles(1, i) = polarplot(opt.AxesHandle, theta, rho(:, i), opt.PlotSettings{:});
end
set(opt.AxesHandle, "nextPlot", nextPlot);

set(opt.AxesHandle, "thetaTick", grad(1:end-1));
if ~isempty(opt.ColumnNames)
    set(opt.AxesHandle, "thetaTickLabels", opt.ColumnNames);
end
if ~isempty(opt.AxesSettings)
    set(opt.AxesHandle, opt.AxesSettings{:});
end

if nargout==0
    return
end

varargout = {plotHandles};

end%

