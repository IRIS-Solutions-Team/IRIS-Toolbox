function setupModel(this)
% setupModel  Set up main parser for model objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

x = parser.theparser.Quantity( );
x.Keyword = '!measurement_variables';
x.Type = TYPE(1);
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!transition_variables';
x.Type = TYPE(2);
x.IsEssential = true;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!measurement_shocks';
x.Type = TYPE(31);
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!transition_shocks';
x.Type = TYPE(32);
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!parameters';
x.Type = TYPE(4);
x.IsReservedPrefix = false;
this.Block{end+1} = x;

x = parser.theparser.Quantity( );
x.Keyword = '!exogenous_variables';
x.Type = TYPE(5);
this.Block{end+1} = x;

x = parser.theparser.Log( );
x.Keyword = '!log_variables';
x.TypeCanBeLog = { TYPE(1)
                   TYPE(2)
                   TYPE(5) };
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!measurement_equations';
x.Type = TYPE(1);
x.IsAppliedSteadyOnlyOpt = true;
this.Block{end+1} = x;

x = parser.theparser.Equation( );
x.Keyword = '!transition_equations';
x.Type = TYPE(2);
x.IsAppliedSteadyOnlyOpt = true;
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

x = parser.theparser.Equation( );
x.Keyword = '!revisions';
x.Type = TYPE(5);
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
    { '\$\<([a-zA-Z]\w*)\>(?!\$)',                '&$1' % Steady references
      '!allbut\>',                                '!all_but'
      '!all-but\>',                               '!all_but'
      '!equations\>',                             '!transition_equations'
      '!variables\>',                             '!transition_variables'
      '(?<=!\w+)-(?=equations|variables|shocks)', '_' % Use dashes instead of underscores
      '!shocks\>',                                '!transition_shocks'
      '\$\[',                                     '<' % Open interpolation
      '\]\$',                                     '>' % Close interpolation
      '!ttrend\>',                                'ttrend' 
      '!dynamic_autoexog',                        '!autoswaps-simulate'
      '!steady_autoexog',                         '!autoswaps-steady'          } ];


this.AltKeywordWarn = [ 
    this.AltKeywordWarn
    { '!equations:dtrends\>', '!dtrends'
      '!dtrends:measurement\>', '!dtrends'
      '!variables:transition\>', '!transition_variables'
      '!shocks:transition\>', '!transition_shocks'
      '!equations:transition\>', '!transition_equations'
      '!variables:measurement\>', '!measurement_variables'
      '!shocks:measurement\>', '!measurement_shocks'
      '!equations:measurement\>', '!measurement_equations'
      '!variables:log\>', '!log_variables'
      '!autoexogenise\>', '!autoswap-simulate'
      '!autoexogenize\>', '!autoswap-simulate' } ];

this.OtherKeyword = [ this.OtherKeyword, ...
                      { '!all_but', '!ttrend', '!min' } ];

this.AssignOrder = [ this.AssignOrder, ...
                     TYPE(4), ...
                     TYPE(5), ...
                     TYPE(2), ...
                     TYPE(1)                 ];

setupRpteq(this);

end%

