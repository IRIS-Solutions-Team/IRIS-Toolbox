function [H,HU,HQ] = ploteig(X,varargin)
% ploteig  Plot eigenvalues in complex plane.
%
% Syntax
% =======
%
%     [H,U,Q] = grfun.ploteig(Obj,...)
%     [H,U,Q] = ploteig(Obj,...)
%
% Input arguments
% ================
%
% * `Obj` [ model | VAR | SVAR | FAVAR | numeric ] - Vector of complex
% numbers or an object to which the function `eig` can be applied.
%
% Output arguments
% =================
%
% * `H` [ numeric ] - Handle to the eigenvalue plot.
%
% * `U` [ numeric ] - Handle to the unit circle.
%
% * `Q` [ numeric ] - Handle to quadrant lines.
%
% Options
% ========
%
% * `'unitCircle='` [ *`true`* | `false` ] - Draw a unit circle.
%
% * `'quadrants='` [ *`true`* | `false` ] - Draw horizontal and vertical
% lines to divide the unit circle into quadrants; only works with
% `'unitCircle=' true`.
%
% Any options valid for the `plot` function.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.


defaults = { 
    'ucircle, unitcircle', true, @(x) isequal(x, true) || isequal(x, false)
    'quadrants', true, @(x) isequal(x, true) || isequal(x, false)
};

[opt,varargin] = passvalopt(defaults, varargin{:});


plotSpec = [ ...
    {'marker','x','markersize',8,'linestyle','none','linewidth',1.5}, ...
    varargin{:}, ...
    ];

%--------------------------------------------------------------------------

if ~isnumeric(X) || ~isvector(X)
    X = eig(X);
end

H = plot(real(X),imag(X),plotSpec{:});

HU = [ ];
HQ = [ ];
if opt.ucircle
    ax = gca( );
    nextPlot = get(ax,'nextplot');
    set(ax,'nextPlot','add');
    HU = grfun.ucircle('color','black');
    grfun.excludefromlegend(HU);
    if opt.quadrants
        HQ(end+1) = plot([0,0],[-1,1],'color','black');
        HQ(end+1) = plot([-1,1],[0,0],'color','black');
        grfun.excludefromlegend(HQ);
    end
    grfun.movetobkg(ax,[HU(:).',HQ(:).']);
    set(ax,'nextPlot',nextPlot);
end

end
