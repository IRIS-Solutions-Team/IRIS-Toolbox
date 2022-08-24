% retrieveColumns  Create a new time series from columns of an existing
% time series
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = retrieveColumns(this, varargin)

this.Data = this.Data(:, varargin{:});
this.Comment = this.Comment(:, varargin{:});
this = trim(this);

end%

