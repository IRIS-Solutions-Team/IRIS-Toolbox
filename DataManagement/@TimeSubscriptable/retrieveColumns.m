function this = retrieveColumns(this, varargin)
% retrieveColumns  Create a new time series from columns of an existing
% time series
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

this.Data = this.Data(:, varargin{:});
this.Comment = this.Comment(:, varargin{:});
this = trim(this);

end%

