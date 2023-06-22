
function unitHandle = circle(varargin)

    persistent ip
    if isempty(ip)
        ip = inputParser();
        ip.addParameter("PlotSettings", cell.empty(1, 0));
        ip.addParameter("Radius", 1);
        ip.addParameter("NumPoints", 128);
    end
    parse(ip, varargin{:});
    opt = ip.Results;

    opt.PlotSettings = [{"lineWidth", 1, "color", 0.3*[1, 1, 1]}, opt.PlotSettings];

    n = opt.NumPoints;
    th = linspace(0, 2*pi, n+1);
    [x, y] = pol2cart(th, opt.Radius);

    unitHandle = plot(x, y, opt.PlotSettings{:});
    axis equal

end%

