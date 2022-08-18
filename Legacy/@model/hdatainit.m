function hdatainit(this, h)

h.Id = this.Vector.Solution;
h.Name = this.Quantity.Name;
h.IxLog = this.Quantity.IxLog;
h.Label = cellstr(getLabelsOrNames(this.Quantity));

if isequal(h.Contributions, @shock)
    ixe = this.Quantity.Type==31 | this.Quantity.Type==32;
    listShocks = this.Quantity.Name(ixe);
    listExtras =  { 
        this.CONTRIBUTION_INIT_CONST_DTREND, ...
        this.CONTRIBUTION_NONLINEAR 
    };
    h.Contributions = [listShocks, listExtras];
elseif isequal(h.Contributions, @measurement)
    ixy = this.Quantity.Type==1;
    h.Contributions = this.Quantity.Name(ixy);
end

end%

