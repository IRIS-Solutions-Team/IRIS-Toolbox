% prepareSolve  Prepare model solution
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function opt = prepareSolve(this, opt)

arguments
    this %#ok<INUSA>

    opt.Run (1, 1) logical = true
    opt.Silent (1, 1) logical = false
    opt.Equations = ""
    opt.Normalize (1, 1) logical = true
    opt.PreferredSchur (1, 1) string {mustBeMember(opt.PreferredSchur, ["schur", "qz"])} = "qz"
    opt.ForceDiff (1, 1) logical = false
    opt.MatrixFormat = "plain"
    opt.Symbolic (1, 1) logical = true
    opt.Error (1, 1) logical = false
    opt.Progress (1, 1) logical = false
    opt.Warning (1, 1) logical = true
end
%}
% >=R2019b


% <=R2019a
%(
function opt = prepareSolve(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Run", true);
    addParameter(ip, "Silent", false);
    addParameter(ip, "Equations", "");
    addParameter(ip, "Normalize", true);
    addParameter(ip, "PreferredSchur", "qz");
    addParameter(ip, "ForceDiff", false);
    addParameter(ip, "MatrixFormat", "plain");
    addParameter(ip, "Symbolic", true);
    addParameter(ip, "Error", false);
    addParameter(ip, "Progress", false);
    addParameter(ip, "Warning", true);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


if opt.Silent
    opt.Progress = false;
    opt.Warning = false;
end

end%

