function setupModel(this)
% setupModel  Set up main parser for model objects
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

x = parser.theparser.Quantity( );
x.Keyword = '!measurement-variables';
x.Type = TYPE(1);
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!transition-variables';
x.Type = TYPE(2);
x.IsEssential = true;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!measurement-shocks';
x.Type = TYPE(31);
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!transition-shocks';
x.Type = TYPE(32);
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!parameters';
x.Type = TYPE(4);
x.IsReservedPrefix = false;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!exogenous-variables';
x.Type = TYPE(5);
this.Block{end+1} = x;

x = parser.theparser.Log( );
x.Keyword = '!log-variables';
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!measurement-equations';
x.Type = TYPE(1);
x.ApplyEquationSwitch = true;
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!transition-equations';
x.Type = TYPE(2);
x.ApplyEquationSwitch = true;
x.IsEssential = true;
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!dtrends';
x.Type = TYPE(3);
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!links';
x.Type = TYPE(4);
this.Block{end+1} = x;

% x = parser.theparser.Equation( );
% x.Keyword = '!revisions';
% x.Type = TYPE(5);
% this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!preprocessor';
x.Type = TYPE(11);
x.Parse = false;
x.Name = 'Preprocessor';
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!postprocessor';
x.Type = TYPE(12);
x.Parse = false;
x.Name = 'Postprocessor';
this.Block{end+1} = x;

x = parser.theparser.Pairing( );
x.Keyword = '!autoswaps-simulate';
x.Type = TYPE(1);
this.Block{end+1} = x;

x = parser.theparser.Pairing( );
x.Keyword = '!autoswaps-steady';
x.Type = TYPE(2);
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
        '!equations:dtrends',      '!dtrends'
        '!dtrends:measurement',    '!dtrends'
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
    TYPE(4), ...
    TYPE(5), ...
    TYPE(2), ...
    TYPE(1), ...
];


setupRpteq(this);

end%

