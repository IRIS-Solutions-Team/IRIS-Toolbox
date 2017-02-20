function varargout = size(this)

nEqtn = size(this.Matrix, 1);
nsh = length(this.Shift);
nQuan = size(this.Matrix, 2) / nsh;

if nargout<=1
    varargout{1} = [nEqtn, nQuan, nsh];
else
    varargout = {nEqtn, nQuan, nsh};
end

end
