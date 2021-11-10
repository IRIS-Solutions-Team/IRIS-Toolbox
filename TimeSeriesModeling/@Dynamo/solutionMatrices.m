function output = solutionMatrices(this)

output = struct();
output.A = this.A;
output.B = this.B;
output.C = this.C;
output.Omega = this.Omega;
output.Sigma = this.Sigma;

output.Mean = this.Mean;
output.Std = this.Std;

end%

