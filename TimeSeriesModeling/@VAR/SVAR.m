% SVAR  Identify SVAR from reduced-form VAR
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [this, data, A0, B0, count] = SVAR(V, data, varargin)

    try
        data; %#ok<VUNUS>
    catch
        data = [];
    end

    % Parse required input arguments.
    persistent ip
    if isempty(ip)
        ip = inputParser();
        addParameter(ip, "MaxIter", 0, @(x) isnumeric(x) && isscalar(x) && x >= 0);
        addParameter(ip, "Method", "chol", @(x) any(strcmpi(x, ["chol", "qr", "svd", "householder"])));
        addParameter(ip, "NDraw", 0, @(x) isnumeric(x) && isscalar(x) && x >= 0);
        addParameter(ip, "Reorder", [ ], @(x) isempty(x) || isnumeric(x) || iscellstr(x) || isstring(x));
            addParameter(ip, "Ordering__Reorder", []);
        addParameter(ip, "Progress", false, @(x) isequal(x, true) || isequal(x, false));
        addParameter(ip, "BackorderResiduals", true, @(x) isequal(x, true) || isequal(x, false));
        addParameter(ip, "Rank", Inf);
        addParameter(ip, "Std", 1);
        addParameter(ip, "Test", "", @(x) ischar(x) || iscellstr(x) || isstring(x));
    end
    parse(ip, varargin{:});
    opt = iris.utils.resolveOptionAliases(ip.Results, [], false);


    ny = size(V.A, 1);
    nv = size(V.A, 3);

    % Create an empty SVAR object
    this = SVAR();
    this.B = nan(ny, ny, nv);
    this.B0 = nan(ny, ny, nv);
    this.A0 = nan(ny, ny, nv);
    this.Std = nan(1, nv);

    % Populate properties inherited from superclass VAR
    this = struct2obj(this, V);

    % Identify the VAR
    [this, data, A0, B0, count] = identify(this, data, opt);

    if nargin<2 || nargout<2 || isempty(data)
        return
    end

    % Convert reduced-form residuals to structural shocks
    data = red2struct(this, data, opt);

end%

