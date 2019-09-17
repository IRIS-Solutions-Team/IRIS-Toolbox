function varargout = size(this,varargin)
if ~isempty(this.A)
   nalt = size(this.A,3);
else
   nalt = 0;
end
temp = zeros(1,nalt);
[varargout{1:nargout}] = size(temp,varargin{:});
end
