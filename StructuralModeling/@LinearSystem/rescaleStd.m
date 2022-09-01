function this = rescaleStd(this, stdFactor)

    this.StdVectors{1} = this.StdVectors{1} * stdFactor;
    this.StdVectors{2} = this.StdVectors{2} * stdFactor;

    varFactor = stdFactor .^ 2;
    this.CovarianceMatrices{1} = this.CovarianceMatrices{1} * varFactor;
    this.CovarianceMatrices{2} = this.CovarianceMatrices{2} * varFactor;

end%

