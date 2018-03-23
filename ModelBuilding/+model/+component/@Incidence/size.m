function varargout = size(this, k)

nEqtn = size(this.Matrix, 1);
nsh = length(this.Shift);
nQuan = size(this.Matrix, 2) / nsh;

if nargin==1
    if nargout<=1
        varargout{1} = [nEqtn, nQuan, nsh];
    else
        varargout = {nEqtn, nQuan, nsh};
    end
else
    temp = [nEqtn, nQuan, nsh];
    varargout{1} = temp(k);
end

end
