function varargout = llf(varargin)

% BWF, HPF, LLF

%#ok<*VUNUS>
%#ok<*CTCH>

%--------------------------------------------------------------------------

order = 1;
[varargout{1:nargout}] = implementFilter(order, varargin{:});

end%
