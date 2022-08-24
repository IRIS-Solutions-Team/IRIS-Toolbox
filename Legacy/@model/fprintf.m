function C = fprintf(this, fileName, varargin)

C = sprintf(this, varargin{:});
textual.write(C, fileName);

end%

