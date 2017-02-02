function d = tsd2dbase(fname,varargin)
% <a href="matlab: edit utils/interface/tsd2dbase">TSD2DBASE</a>  Convert TSD databank file to IRIS database.
%
% Syntax
% =======
%
%     d = tsd2dbase(fname,...)
% Output arguments
% =================
%
% * `d` [ struct ] - <a href="databases.html">Database</a> built from TSD file.
% Input arguments
% ================
%
% * `fname` [ char ] - TSD filename.
% <a href="options.html">Optional input arguments:</a>
%     'endofline' [ char } ' // ' ] Replace ends of lines in multi-line headers with this string.
%     'merge' [ struct | <a href="default.html">empty</a> ] Merge output database with an existing database.
%     'name' [ 'capitalise' | 'lowercase' | <a href="default.html">'unchanged'</a> | 'uppercase' ] Format of output variable names.
%     'nan' [ numeric <a href="default.html">1e15</a> ] Numerical value for missing observations.
%     'replace' [ char | <a href="default.html">'_'</a> ] Replace other-than-word characters in time series names with this one.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% old syntax tsd2dbase(fname,d)
if ~isempty(varargin) && isstruct(varargin{1})
  options.merge = varargin{1};
  varargin(1) = [ ];
else
  options.merge = [ ];
end

default = {...
  'merge',options.merge,@(x) isempty(x) || isstruct(x),...
  'endofline',' // ',@ischar,...
  'nan',1e15,@(x) isnumeric(x) && length(x) == 1,...
  'name','unchanged',@(x) any(strcmpi(x,{'capitalise','capitalize','lower','lowercase','upper','uppercase','unchanged'})),...
  'replace','_',@ischar,...
};
options = passvalopt(default,varargin{:});

%**************************************************************************

if isstruct(options.merge) && ~isempty(options.merge)
  d = options.merge;
else 
  d = struct( );
end

fid = fopen(fname,'r');
if fid == -1
  return
end

freqlist = [1,2,4,6,12];
template = tseries( );
line = fgetl(fid);
count = 0;
invalidname = [ ];
invalidrange = { };
invalidfreq = { };
invalidlength = { };

% When EOF is reached, line == -1.
while ischar(line)
   count = count + 1;
   % Find first data line.
   header = { };
   data = { };
   while ischar(line) && ~isdataline_(line)
      header{end+1} = line;
      line = fgetl(fid);
   end
   if isempty(line)
      continue
   end
   while ischar(line) && isdataline_(line)
      data{end+1} = line;
      line = fgetl(fid);
   end
   % Adjust name.
   name = getname_(header{1}(1:15),options);
   if isempty(name)
      % Cannot read name.
      invalidname(end+1) = count;
      continue
   end
   d.(name) = template;
   d.(name) = stampMe(d.(name));
   % Fetch comments from Multi-line headers.
   comment = strtrim(header{1}(16:end));
   for i = 2 : length(header)-1
      comment = [comment,options.endofline,strtrim(header{i})];
   end
   info = regexp(header{end},'\d{21}[a-zA-Z]','match','once');
   if isempty(info)
      % Cannot determine range or frequency.
      invalidrange{end+1} = name;
      continue
   end
   freq = freqlist(upper(info(end)) == ['ASQBM']);
   if isempty(freq)
      % Cannot determine frequency.
      invalidfreq{end+1} = name;
      continue
   end
   startdate = ...
      datcode(freq,sscanf(info(4:9),'%g'),sscanf(info(10:11),'%g'));
   enddate = ...
      datcode(freq,sscanf(info(12:17),'%g'),sscanf(info(18:19),'%g'));
   data = sscanf([data{:}],'%f');
   data = data(:);
   if round(enddate - startdate) + 1 ~= length(data)
      % Length of range does not match number of observations.
      invalidlength{end+1} = name;
      continue
   end
   if ~isempty(data)
      d.(name) = replace(d.(name),data(:),startdate,{comment});
   end
end

fclose(fid);

if ~isempty(invalidname)
   warning_(1,sprintf(' #%g',invalidname));
end

if ~isempty(invalidrange)
   warning_(2,sprintf(' ''%s''',invalidrange{:}));
end

if ~isempty(invalidfreq)
   warning_(3,sprintf(' ''%s''',invalidfreq{:}));
end

if ~isempty(invalidlength)
   warning_(4,sprintf(' ''%s''',invalidlength{:}));
end

end


%**************************************************************************
%! Subfunction isdataline_( ).

function flag = isdataline_(x)
   flag = ~isempty(regexp(x,'^\s*(?:[ \-]\d\.\d{6}E[\+\-]\d{4}){1,5}\s*$','match','once'));
end
% End of subfunction isdataline_( ).

%**************************************************************************
%! Subfunction name_( ).

function x = getname_(x,options)
   x = strtrim(x);
   if isempty(x)
      return
   end
   % Upper or lower case conversion.
   if any(strcmpi(options.name,{'capitalise','capitalize'}))
      x = [upper(x(1)),lower(x(2:end))];
   elseif any(strcmpi(options.name,{'lower','lowercase'}))
      x = lower(x);
   elseif any(strcmpi(options.name,{'upper','uppercase'}))
      x = upper(x);
   end
   % Replace characters other than a-zA-Z0-9_ with options.replace.
   x = regexprep(x,'[^\w]',options.replace);
end
% End of subfunction name_( ).



function warning_(code,list,varargin)

if ~iswarning('exim')
    return
end

switch code
    
    case 1
        msg = 'Cannot determine name for TSD series%s.';
        
    case 2
        msg = 'Cannot determine time range for TSD series%s.';
        
    case 3
        msg = 'Invalid frequency identifier(s) for TSD series%s.';
        
    case 4
        msg = 'Length of range does not match number of observations for for TSD series%s.';
        
end

if nargin == 1
    list = { };
end

utils.warning('io',msg,list{:});

end
