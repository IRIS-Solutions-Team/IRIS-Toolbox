
function [c, n] = release( )

    c = iris.get('Release');
    if nargout>1
        n = sscanf(c, '%g', 1);
    end

end%

