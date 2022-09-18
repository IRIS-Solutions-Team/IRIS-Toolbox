
function [lx, rx] = chartyy(left, right, varargin)

    yyaxis left
    plot(left, varargin{:});

    yyaxis right
    plot(right, varargin{:});

end%

