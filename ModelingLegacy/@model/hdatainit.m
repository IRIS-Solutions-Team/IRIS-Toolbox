function hdatainit(this, h)
% hdatainit  Initialize hdataobj for model
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

h.Id = this.Vector.Solution;
h.Name = this.Quantity.Name;
h.IxLog = this.Quantity.IxLog;
h.Label = this.Quantity.LabelOrName;

if isequal(h.Contributions, @shock)
    ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
    lsShock = this.Quantity.Name(ixe);
    lsExtra =  { this.CONTRIBUTION_INIT_CONST_DTREND, ...
                 this.CONTRIBUTION_NONLINEAR };
    h.Contributions = [lsShock, lsExtra];
elseif isequal(h.Contributions, @measurement)
    ixy = this.Quantity.Type==int8(1);
    h.Contributions = this.Quantity.Name(ixy);
end

end%

