function setupRpteq(this)
% setupRpteq  Set up main parser for rpteq objects
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

x = parser.theparser.Equation( );
x.Keyword = '!reporting';
x.Type = 6;
this.Block{end+1} = x;


this.AltKeyword = [
    this.AltKeyword
    {
        '!equations:reporting',   '!reporting'
        '!reporting-equations',   '!reporting'
        '!reporting_equations',   '!reporting'
    }
];


this.AltKeywordWarn = [ 
    this.AltKeywordWarn
    { 
        '!outside',               '!reporting'
    } 
];

end%

