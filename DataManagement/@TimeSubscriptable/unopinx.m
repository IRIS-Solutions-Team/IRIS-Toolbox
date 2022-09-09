function [x, varargout] = unopinx(func, this, dim, varargin)

[x, pos] = unop(func, this, dim, varargin{:});

if dim==1
    if pos==1
        pos = this.Start;
    else
        pos = round(this.Start + (pos - 1));
    end
    varargout{1} = pos;
else
    varargout{1} = fill(this, pos, this.Start, '', [ ]);
end

end%

