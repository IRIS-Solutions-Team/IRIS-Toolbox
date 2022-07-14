function [measurementNames, exogenousNames, logNames] = getKalmanDataNames(this)

    measurementNames = textual.stringify(getNamesByType(this.Quantity, 1));
    exogenousNames = textual.stringify(getNamesByType(this.Quantity, 5));

    inxYG = getIndexByType(this.Quantity, 1, 5);
    inxLog = this.Quantity.InxLog;
    logNames = textual.stringify(this.Quantity.Name(inxYG & inxLog));

end%

