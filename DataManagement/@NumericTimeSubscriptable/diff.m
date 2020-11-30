% diff  First difference
%{
% Syntax
%--------------------------------------------------------------------------
%
% Input arguments marked with a `~` sign may be omitted
%
%     this = diff(this, ~shift)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`this`__ [ NumericTimeSubscriptable ]
%
%>    Input time series.
%
% __`~shift`__ [ numeric ]
%
%>    Number of periods over which the first difference
%>    will be computed; `y=this-this{shift}`; `shift` is a negative number
%>    for the usual backward differencing; if omitted, `shift=-1`.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`this`__ [ NumericTimeSubscriptable ]
%
%>    First difference of the input time series.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = diff(this, varargin)

if isempty(this.Data)
    return
end

if ~isempty(varargin) && isnumeric(varargin{1}) && numel(varargin{1})>1
    for shift = reshape(varargin{1}, 1, [ ]);
        this = diff(this, shift, varargin{2:end});
    end
    return
end

[shift, power] = dater.resolveShift(getRangeAsNumeric(this), varargin{:});

if isempty(this.Data)
    return
end


%===========================================================================
this = unop(@series.change, this, 0, @minus, shift);
%===========================================================================


if power~=1
    this.Data = this.Data * power;
end

end%

