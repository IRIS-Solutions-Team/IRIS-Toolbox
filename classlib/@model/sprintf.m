function c = sprintf(this, varargin)
% sprintf  Print model object to text.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

c = '';

% Quantities.
ixy = this.Quantity.Type==int8(1);
ixx = this.Quantity.Type==int8(2);
ixey = this.Quantity.Type==int8(31);
ixex = this.Quantity.Type==int8(32);
ixp = this.Quantity.Type==int8(4);

c = [c, printNames(this, '!measurement_variables', find(ixy))];
c = [c, printNames(this, '!transition_variables', find(ixx))];
c = [c, printNames(this, '!measurement_shocks', find(ixey), false)];
c = [c, printNames(this, '!transition_shocks', find(ixex), false)];
c = [c, printNames(this, '!parameters', find(ixp))];
c = [c, printNames(this, '!log_variables', find(this.Quantity.IxLog), false)];

% Equations.
ixm = this.Equation.Type==1;
ixt = this.Equation.Type==2;

c = [c, printEqtns(this, '!measurement_equations', find(ixm))];
c = [c, printEqtns(this, '!transition_equations', find(ixt))];

end




function c = printNames(this, heading, pos, isValue)
try
    isValue; %#ok<VUNUS>
catch
    isValue = true;
end
if isempty(pos)
    c = '';
    return
end
BR = sprintf('\n');
TAB = sprintf('\t');
c = [BR, heading, BR];
for i = pos
    c = [c, TAB, this.Quantity.Name{i}]; %#ok<AGROW>
    if isValue && ~isnan(this.Variant{1}.Quantity(i))
        assignReal = real(this.Variant{1}.Quantity(i));
        assignImag = imag(this.Variant{1}.Quantity(i));
        c = [c, sprintf('=%.16f', assignReal)]; %#ok<AGROW>
        if assignImag~=0
            c = [c, sprintf('%+.16fi', assignImag)]; %#ok<AGROW>
        end
    end
    c = [c, BR]; %#ok<AGROW>
end
end




function c = printEqtns(this, heading, pos)
if isempty(pos)
    c = '';
    return
end
br = sprintf('\n');
tab = sprintf('\t');
c = [br, heading, br];
for i = pos
    eqtn = this.Equation.Input{i};
    eqtn = strrep(eqtn, '=', ' = ');
    eqtn = strrep(eqtn, '= #', ' =# ');
    eqtn = strrep(eqtn, '!!', [' ...', br, tab, tab, '!! ']);
    c = [c, tab, eqtn]; %#ok<AGROW>
    c = [c, br, br]; %#ok<AGROW>
end
end
