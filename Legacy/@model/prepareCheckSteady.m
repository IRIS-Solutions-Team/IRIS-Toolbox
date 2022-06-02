% prepareCheckSteady  Prepare stead state check
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function opt = prepareCheckSteady(this, opt)

arguments
    this %#ok<INUSA>

    opt.Run (1, 1) logical = true
    opt.Silent (1, 1) logical = false
    opt.EquationSwitch (1, 1) string {mustBeMember(opt.EquationSwitch, ["dynamic", "steady"])} = "dynamic"
    opt.Error (1, 1) logical = true
    opt.Warning (1, 1) logical = true
end
%}
% >=R2019b


% <=R2019a
%(
function opt = prepareCheckSteady(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Run", true);
    addParameter(ip, "Silent", false);
    addParameter(ip, "EquationSwitch", "dynamic");
    addParameter(ip, "Error", true);
    addParameter(ip, "Warning", true);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a

end%

