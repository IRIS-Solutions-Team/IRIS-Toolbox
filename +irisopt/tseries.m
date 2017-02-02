function def = tseries( )
% tseries  Default options for tseries class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

def.acf = { ...
    'demean',true,@islogicalscalar, ...
    'order',0,@isnumericscalar, ...
    'smallsample',true,@islogicalscalar, ...
    };

def.band = { ...
    'excludefromlegend',true,@islogicalscalar, ...
    'grid','top',@(x) ischar(x) && any(strcmpi(x,{'top','bottom'})), ...
    'relative',true,@islogicalscalar, ...
    'white',0.85,@(x) isnumeric(x) && all(x >= 0) && all(x <= 1), ...
    };

def.bpass = { ...
    'addtrend',true,@islogicalscalar, ...
    'detrend',true,@islogicalscalar, ...
    'log',false,@islogicalscalar, ...
    'method','cf',@(x) ischar(x) && any(strcmpi(x,{'cf','hwfsf'})), ...
    'unitroot',true,@islogicalscalar, ...
    'window','hamming',@(x) ischar(x) && any(strcmpi(x,{'hamming','hanning','none'})), ...
    };

def.chowlin = { ...
    'constant',true,@islogicalscalar, ...
    'log',false,@islogicalscalar, ...
    'ngrid',200,@(x) isnumericscalar(x) && x >= 1, ...
    'rho','estimate', ...
    @(x) any(strcmpi(x,{'auto','estimate','negative','positive'})) ...
    || (isnumericscalar(x) && x > -1 && x < 1), ...
    'timetrend',false,@islogicalscalar, ...
    };

convert = { ...
    'function',[ ],@(x) isempty(x) || isfunc(x) || ischar(x), ...
    'missing',NaN,@(x) (ischar(x) && any(strcmpi(x,{'last'}))) || isnumericscalar(x), ...
    'method',@mean,@(x) isfunc(x) || (ischar(x) && any(strcmpi(x, {'first', 'last'}))), ...
    'select',Inf,@(x) isnumeric(x), ...    
    'standinmonth',1,@(x) isnumericscalar(x) || isequal(x,'first') || isequal(x,'last'), ...
    };

def.convertaggregdaily = [convert,{ ...
    'ignorenan',true,@islogical, ...
    }];

def.convertaggreg = [convert,{ ...
    'ignorenan',false,@islogical, ...
    }];

def.convertinterp = [convert,{ ...
    'ignorenan',false,@islogical, ...
    'method','pchip',@(x) ischar(x), ...
    'position','centre',@(x) ischar(x) && any(strncmpi(x,{'c','s','e'},1)), ...
    }];

def.cumsumk = { ...
    'log',false,@islogicalscalar, ...
    };

def.errorbar = { ...
    'excludefromlegend',true,@islogicalscalar, ...
    'relative',true,@islogicalscalar, ...
    };

def.expsmooth = { ...
    'init',NaN,@isnumeric, ...
    'log',false,@islogicalscalar, ...
};

def.fft = { ...
    'full',false,@islogicalscalar, ...
    };

def.filter = { ...
    'change,growth',[ ],@(x) isempty(x) || istseries(x), ...
    'gamma',1,@(x) isa(x,'tseries') || (isnumericscalar(x) && x > 0), ...
    'cutoff',[ ],@(x) isempty(x) || (isnumeric(x) && all(x(:) > 0)), ...
    'cutoffyear',[ ],@(x) isempty(x) || (isnumeric(x) && all(x(:) > 0)), ...
    'drift',0,@(x) isnumeric(x) && length(x) == 1, ...
    'gap',[ ],@(x) isempty(x) || istseries(x), ...
    'infoset',2,@(x) isequal(x,1) || isequal(x,2), ...
    'lambda',@auto,@(x) isequal(x,@auto) || isempty(x) ...
    || (isnumeric(x) && all(x(:) > 0)) || (ischar(x) && strcmpi(x,'auto')), ...
    'level',[ ],@(x) isempty(x) || istseries(x), ...
    'log',false,@islogical, ...
    'swap',false,@islogical, ...
    'forecast',[ ],@(x) isnumeric(x) && length(x) <= 1, ...
    };

def.plot = { ...
    'dateformat',@config,@config, ...
    'freqletters,freqletter',@config,@config, ...
    'months,month',@config,@config, ...
    'standinmonth',@config,@config, ...
    'wwday',@config,@config, ...
    'datetick,dateticks',@auto,@(x) isequal(x,@auto) || isnumeric(x) ...
    || any(strcmpi(x,{'yearstart','yearend','yearly'})) ...
    || isfunc(x), ...
    'dateposition','c',@(x) ischar(x) && ~isempty(x) && any(x(1) == 'sec'), ...
    'function',[ ],@(x) isempty(x) || isfunc(x), ...
    'tight',false,@islogicalscalar, ...
    'xlimmargin',@auto,@(x) islogicalscalar(x) || isequal(x,@auto), ...
    }; %#ok<CCAT>

def.interp = { ...
    'method','pchip',@ischar, ...
    };

def.moving = { ...
    'window',@auto,@(x) isnumeric(x) || isequal(x,@auto), ...
    'function',@mean,@isfunc, ...
    };

def.barcon = {
    'barwidth',0.8,@isnumericscalar, ...
    'colormap',[ ],@isnumeric, ...
    'evenlyspread',true,@islogicalscalar, ...
    'ordering','preserve',@(x) isanystri(x,{'descend','ascend','preserve'}) ...
    || isnumeric(x), ...
    };

def.normalise = { ...
    'mode','mult',@(x) any(strncmpi(x,{'add','mult'},3)), ...
    };

def.pct = { ...
    'outputfreq,freq',[ ],@(x) isempty(x) ...
    || (isnumericscalar(x) && any(x == [1,2,4,6,12])), ...
    };

def.plotcmp = { ...
    'compare',[-1;1],@isnumeric, ...
    'cmpcolor,diffcolor',[1,0.75,0.75],@(x) isnumeric(x) && length(x) == 3 && all(x >= 0) && all(x <= 1), ...
    'baseline',true,@islogicalscalar, ...
    'rhsplotfunc',[ ],@(x) isempty(x) || isanyfunc(x,{'bar','area'}), ...
    'cmpplotfunc,diffplotfunc',@bar,@(x) isanyfunc(x,{'bar','area'}), ...
    };

def.plotpred = { ...
    'connect',true,@islogicalscalar, ...
    'firstline',{ },@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'predlines',{ },@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'firstmarker,firstmarkers,startpoint,startpoints','.',@(x) ischar(x) ...
    && any(strcmpi(x,{'none','+','o','*','.','x','s','d','^','v','>','<','p','h'})), ...
    'shownanlines',true,@islogicalscalar, ...
};

def.plotyy = { ...
    def.plot{:}, ...
    'coincide,coincident',false,@islogicalscalar, ...
    'highlight',[ ],@isnumeric, ...
    'lhsplotfunc',@plot,@(x) ischar(x) || isfunc(x), ...
    'rhsplotfunc',@plot,@(x) ischar(x) || isfunc(x), ...
    'lhstight',false,@islogicalscalar, ...
    'rhstight',false,@islogicalscalar, ...
    }; %#ok<CCAT>

def.regress = {...
    'constant,const',false,@islogical, ...
    'weighting',[ ],@(x) (isnumeric(x) && isempty(x)) || istseries(x),...
    };

def.spy = { ...
    def.plot{:}, ...
    'ShowTrue', true, @islogicalscalar, ...
    'ShowFalse', false, @islogicalscalar, ...
    'names,name',{ },@iscellstr, ...
    'test',@isfinite,@(x) isfunc(x), ...    
    }; %#ok<CCAT>

def.trend = { ...
    'break',[ ],@isnumeric, ...
    'connect',true,@islogicalscalar, ...
    'diff',false,@islogicalscalar, ...
    'log',false,@islogicalscalar, ...
    'season',false,@(x) isempty(x) || islogicalscalar(x) || isnumericscalar(x), ...
    };

def.windex = { ...
    'log',false,@islogical, ...
    'method','simple',@(x) ischar(x) && any(strcmpi(x,{'simple','divisia'})), ...
    };

def.x12 = { ...
    'backcast,backcasts',0,@(x) isnumericscalar(x), ...
    'cleanup,deletetempfiles,deletetempfile,deletex12file,deletex12file,delete',true,@islogicalscalar, ...
    'dummy',[ ],@(x) isempty(x) || isa(x,'tseries'), ...
    'dummytype','holiday',@(x) ischar(x) && any(strcmpi(x,{'holiday','td','ao'})), ...
    'display',false,@islogicalscalar, ...
    'forecast,forecasts',0,@(x) isnumericscalar(x), ...
    'log',false,@islogicalscalar, ...
    'maxiter',1500,@(x) isintscalar(x) && x > 0, ...
    'maxorder',[2,1],@(x) isnumeric(x) && length(x) == 2 ...
    && any(x(1) == [1,2,3,4]) && any(x(2) == [1,2]), ...
    'missing',false,@islogicalscalar, ...
    'mode','auto',@(x) (isnumeric(x) && any(x == -1 : 3)) || any(strcmp(x,{'add','a','mult','m','auto','sign','pseudo','pseudoadd','p','log','logadd','l'})), ...
    'output','d11',@(x) ischar(x) || iscellstr(x), ...
    'saveas','',@ischar, ...
    'specfile','default',@(x) ischar(x) || isinf(x), ...
    'tdays,tday',false,@islogicalscalar, ...
    'tempdir','.',@(x) ischar(x) || isfunc(x), ...
    'tolerance',1e-5,@(x) isnumericscalar(x) && x > 0, ...
    };

end
