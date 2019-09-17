function this = defineNamesInDatabank(this, dictionary)
% defineNamesInDatabank  Assign struct or Dictionary with mapping between model names and databank names
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('DatabankPipe.defineNamesInDatabank');
    addRequired(parser, 'DatabankPipe', @(x) isa(x, 'shared.DatabankPipe'));
    addRequired(parser, 'Dictionary', @validate.databank);
end
parse(parser, this, dictionary);

%--------------------------------------------------------------------------

this.NamesInDatabank = dictionary;

end%

