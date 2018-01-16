function d = fromaremos(banks,names,varargin)
% <a href="matlab: edit utils/interface/fromaremos">FROMAREMOS</a>  Import time series from AREMOS databank(s).
%
% Syntax
% =======
%
%     d = fromaremos(banks,names,...)
% Arguments:
% * `d` [ struct ] - <a href="databases.html">Database</a> with imported series.
% * `banks` [ char | cellstr ] - List of AREMOS databanks to be opened.
% * `names` [ char | cellstr ] - List of AREMOS series to be imported.
% <a href="options.html">Optional input arguments:</a>
%     'cload' [ true | <a href="default.html">false</a> ] CLOAD databanks before opening.
%     'freq' [ char | <a href="default.html">'Q'</a> ] Set frequency (AREMOS syntax).
%     'merge' [ struct | <a href="default.html">empty</a> ] Merge output database with an existing database.
%     'nan' [ numeric | <a href="default.html">1e15</a> ] Numerical value for missing observations.
%     'name' [ 'capitalise' | 'lowercase' | <a href="default.html">'unchanged'</a> | 'uppercase' ] Format of output variable names.
%     'period' [ char | <a href="default.html">'1990 today'</a> ] Set period (AREMOS syntax).
%     'replace' [char | <a href="default.html">char(95)</a> ] Replace other-than-word characters in time series names.
%     'saveas' [ char | <a href="default.html">'fromaremos'</a> ] TSD and CMD file names (w/o extension).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

default = {...
  'cload',false,@islogical,...
  'freq','Q',@(x) any(strcmpi(x,{'A','S','Q','B','M'})),...
  'merge',[ ],@(x) isempty(x) || isstruct(x),...
  'nan',1e15,@(x) isnumeric(x) && length(x) == 1,...
  'name','unchanged',@(x) any(strcmpi(x,{'capitalise','capitalize','lower','lowercase','upper','uppercase','unchanged'})),...
  'period','1990 today',@ischar,...
  'replace','_',@ischar,...
  'saveas','fromaremos',@ischar,...
};
options = passvalopt(default,varargin{:});

if ischar(banks)
  banks = strtrim(banks);
  if strcmp(banks,'*')
    banks = 'act,exp,fix,int,lab,mon,nat,pri,qfi,rat,sta,tra,ifs,mei';
  end
elseif iscellstr(banks)
  banks = sprintf('%s,',banks{:});
  banks(end) = '';
end

if ischar(names)
  names = strtrim(names);
elseif iscellstr(names)
  names = sprintf('%s,',names{:});
  names(end) = '';
end

%**************************************************************************

if isempty(names)
  d = options.merge;
  return
end

[fpath,ftitle,fext] = fileparts(options.saveas);
fpath = 'c:/warem52/export';
fname = fullfile(fpath,ftitle);
fnamecmd = sprintf('%s.cmd',fname);
fnametsd = sprintf('%s.tsd',fname);

command = '';
newline = sprintf('\r\n');

if exist(fpath) ~= 7
  mkdir(fpath);
end

fid = fopen(fnamecmd,'w+');
if fid == -1
  error('Unable to open %s for writing.',upper(fnamecmd));
end
fclose(fid);

fid = fopen(fnametsd,'w+');
if fid == -1
  error('Unable to open %s for writing.',upper(fnametsd));
end
fclose(fid);

% Open databanks.
if ~isempty(banks)
  if options.cload
    command = [command,newline,sprintf('cload %s;',banks)];
  end
  command = [command,newline,sprintf('open %s;',banks)];  
end

% Set frequency.
if ~isempty(options.freq)
  command = [command,newline,sprintf('set freq %s;',options.freq)];
end

% Set period.
if ~isempty(options.period)
  command = [command,newline,sprintf('set per %s;',options.period)];
end

% List of variables names.
if ~isempty(names)
  command = [command,newline,sprintf('export <format=tsd> %s to %s;',names,fname)];
end

% Close all databanks.
command = [command,newline,'close *;'];

% Save CMD file.
char2file(command,fnamecmd);

% Call barem32 and execute CMD file.
system(sprintf('c:/warem52/barem32.exe %s',fnamecmd));

% Convert TSD file to matlab/iris database.
d = tsd2dbase(fnametsd,'merge',options.merge,'nan',options.nan,'replace',options.replace,'name',options.name);

end
