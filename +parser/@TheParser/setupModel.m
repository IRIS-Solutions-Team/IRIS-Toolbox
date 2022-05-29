% setupModel  Set up main parser for model objects
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function setupModel(this)

x = parser.theparser.Quantity( );
x.Keyword = '!measurement-variables';
x.Type = 1;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!transition-variables';
x.Type = 2;
x.IsEssential = true;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!measurement-shocks';
x.Type = 31;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!transition-shocks';
x.Type = 32;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!parameters';
x.Type = 4;
x.IsReservedPrefix = false;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!exogenous-variables';
x.Type = 5;
this.Block{end+1} = x;

x = parser.theparser.Log( );
x.Keyword = '!log-variables';
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!measurement-equations';
x.Type = 1;
x.ApplyEquationSwitch = true;
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!transition-equations';
x.Type = 2;
x.ApplyEquationSwitch = true;
x.IsEssential = true;
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!measurement-trends';
x.Type = 3;
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!links';
x.Type = 4;
this.Block{end+1} = x;

% x = parser.theparser.Equation( );
% x.Keyword = '!revisions';
% x.Type = 5;
% this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!preprocessor';
x.Type = 11;
x.Parse = false;
x.Name = 'Preprocessor';
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!postprocessor';
x.Type = 12;
x.Parse = false;
x.Name = 'Postprocessor';
this.Block{end+1} = x;

x = parser.theparser.Pairing( );
x.Keyword = '!autoswaps-simulate';
x.Type = 1;
this.Block{end+1} = x;

x = parser.theparser.Pairing( );
x.Keyword = '!autoswaps-steady';
x.Type = 2;
this.Block{end+1} = x;


this.AltKeyword = [ 
    this.AltKeyword 
    { 
        '!allbut',           '!all-but'
        '!all_but',          '!all-but'
        '!equations',        '!transition-equations'
        '!variables',        '!transition-variables'
        '!shocks',           '!transition-shocks'
        '!transition_',      '!transition-'
        '!measurement_',     '!measurement-'
        '!exogenous_',       '!exogenous-'
        '!log_variables',    '!log-variables'
        '!ttrend',           'ttrend' 
        '!dynamic_autoexog', '!autoswaps-simulate'
        '!steady_autoexog',  '!autoswaps-steady'          
    } 
];


this.AltKeywordRegexp = [ 
    this.AltKeywordRegexp 
    { 
        '\$\<([a-zA-Z]\w*)\>(?!\$)',              '&$1' % Steady references
    } 
];


this.AltKeywordWarn = [ 
    this.AltKeywordWarn
    { 
        '!equations:dtrends',      '!measurement-trends'
        '!dtrends:measurement',    '!measurement-trends'
        '!dtrends',                '!measurement-trends'
        '!variables:transition',   '!transition-variables'
        '!shocks:transition',      '!transition-shocks'
        '!equations:transition',   '!transition-equations'
        '!variables:measurement',  '!measurement-variables'
        '!shocks:measurement',     '!measurement-shocks'
        '!equations:measurement',  '!measurement-equations'
        '!variables:log',          '!log-variables'
        '!autoexogenise',          '!autoswaps-simulate'
        '!autoexogenize',          '!autoswaps-simulate' 
    } 
];


this.OtherKeyword = [ this.OtherKeyword, ...
                      { '!all-but', '!ttrend', '!min' } ];


this.AssignOrder = [ 
    this.AssignOrder, ...
    4, ...
    5, ...
    2, ...
    1, ...
];


setupRpteq(this);

end%

