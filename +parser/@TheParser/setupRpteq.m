function setupRpteq(this)
% setupRpteq  Set up main parser for rpteq objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

x = parser.theparser.Equation( );
x.Keyword = '!reporting_equations';
x.Type = TYPE(6);
this.Block{end+1} = x;

this.AltKeywordWarn = [ 
    this.AltKeywordWarn
    { 
    '!outside\>', '!reporting_equations'
    '!equations:reporting\>', '!reporting_equations'
    '!reporting\>', '!reporting_equations'
    } ];

end
