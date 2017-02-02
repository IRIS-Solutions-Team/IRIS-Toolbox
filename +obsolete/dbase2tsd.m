function [saved,range] = dbase2tsd(d,fname,varargin)
%
% <a href="matlab: edit utils/interface/tsd2dbase">DBASE2TSD</a>  Convert IRIS database to TSD databank file.
%
% Syntax
% =======
%
%     [list,range] = tsd2dbase(d,fname)
% Output arguments
% =================
%
% * `list` [ cellstr ] - List actually saved database entries.
% * `range` [ numeric ] - Actually used Start-year and end-year.
% Input arguments
% ================
%
% * `d` [ struct ] - <a href="databases.html">Database</a> to be saved.
% * `fname` [ char ] - TSD filename.
% <a href="options.html">Optional input arguments:</a>
%     'nan' [ numeric <a href="default.html">1e15</a> ] Numerical value for missing observations.
%     'inf' [ numeric | <a href="default.html">realmax( )</a> ] Numerical value for Infs.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

default = {...
  'nan',1e15,@isnumericscalar, ...
  'inf',realmax( ),@isnumericscalar, ...
};
opt = passvalopt(default,varargin{:});

%--------------------------------------------------------------------------

fid = fopen(fname,'w+');
if fid == -1
  error('Unable to open %s for writing.',upper(fname));
end
fclose(fid);

flag = false;
newline = sprintf('\r\n');

file = '';
list = fieldnames(d);
saved = { };
range = [Inf,-Inf];
for i = 1 : length(list)
  % not a time series
  if ~istseries(d.(list{i}))
    continue
  end
  si = size(d.(list{i}));
  % multi-dimensional time series
  if any(si(2:end)) ~= 1
    continue
  end
  [from,to] = get(d.(list{i}),'start','end');
  range(1) = min([dat2ypf(from),range(1)]);
  range(2) = max([dat2ypf(to),range(2)]);
  freq = ['ASQBM'];
  freq = freq(datfreq(from) == [1,2,4,6,12]);
  % unsupported frequency
  if isempty(freq)
    continue
  end
  name = upper(list{i});
  if length(name) > 15
    name = name(1:15);
  end
  % duplicate names
  if any(strcmp(saved,name))
    continue
  end
  file = [file,strjust(sprintf('%15s',name),'left'),strtrim(comment(d.(list{i}))),newline];
  file = [file,sprintf('%32s',''),datestr(now,'mm/dd/yy'),sprintf('%4s',''),dat2char(from,'dateformat','YYYYPP  '),dat2char(to,'dateformat','YYYYPP  '),freq,newline];
  data = d.(list{i})(:);
  data(abs(data) < 1e-100) = 0; % AREMOS does not like small exponents
  data(isnan(data)) = opt.nan;
  data(isinf(data) & data > 0) = opt.inf;
  data(isinf(data) & data < 0) = -opt.inf;
  file = [file,sprintf('%+15.7e%+15.7e%+15.7e%+15.7e%+15.7e\r\n',data)];
  if file(end) ~= newline(end)
    file = [file,newline];
  end
  saved{end+1} = name;
end

char2file(file,fname);

end