function implementDisp(this)

CONFIG = iris.get( );
TYPE = @int8;

n = [ nnz(this.Type==TYPE(1)), ...
      nnz(this.Type==TYPE(2)), ...
      nnz(this.Type==TYPE(3) & ~cellfun(@isempty, this.Input)), ...
      nnz(this.Type==TYPE(4)), ...
      nnz(this.Type==TYPE(5)) ];

fprintf(CONFIG.DispIndent);
fprintf('Number of Equations: [%g %g %g %g %g]\n', n);

end%
