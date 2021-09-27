function implementDisp(this)

CONFIG = iris.get( );

n = [ nnz(this.Type==1), ...
      nnz(this.Type==2), ...
      nnz(this.Type==3 & ~cellfun(@isempty, this.Input)), ...
      nnz(this.Type==4), ...
      nnz(this.Type==5) ];

fprintf(CONFIG.DispIndent);
fprintf('Number of Equations: [%g %g %g %g %g]\n', n);

end%
