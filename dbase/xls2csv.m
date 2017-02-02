function xls2csv(InpFile,OutpFile,varargin)
% xls2csv  Convert XLS file to CSV file.
%
% Syntax
% =======
%
%     xls2csv(InpFile)
%     xls2csv(InpFile,OutpFile,...)
%
% Input arguments
% ================
%
% * `InpFile` [ char ] - Name of an XLS input file that will be converted
% to CSV.
%
% * `OutpFile` [ empty | char ] - Name of the CSV output file; if
% not supplied or empty, the CSV file name will be derived from the XLS
% input file name.
%
% Options
% ========
%
% * `'sheet='` [ numeric | char | *`1`* ] - Worksheet in the XLS file that
% will be saved; can be either the sheet number or the sheet name.
%
% Description
% ============
%
% This function calls a third-party JavaScript (courtesy of Christopher
% West). The script uses an MS Excel application on the background,
% and hence MS Excel must be installed on the computer.
%
% Only one worksheet at a time can be saved to CSV. By default, it is the
% first worksheet found in the input XLS file; use the option `'sheet='` to
% control which worksheet will be saved.
%
% See also $irisroot/+thirdparty/xls2csv.js for copyright information.
%
% Example
% ========
%
% Save the first worksheets of the following XLS files to CSV files.
%
%     xls2csv('myDataFile.xls');
%     xls2csv('C:\Data\myDataFile.xls');
%
% Example
% ========
%
% Save the worksheet named 'Sheet3' to a CSV file; the name of the CSV file
% will be `'myDataFile.csv'`.
%
%     xls2csv('myDataFile.xls',[ ],'sheet=','Sheet3');
%
% Example
% ========
%
% Save the second worksheet to a CSV file under the name
% `'myDataFile_2.csv'`.
%
%     xls2csv('myDataFile.xls','myDataFile_2.csv,'sheet=',2);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    OutpFile; %#ok<VUNUS>
catch %#ok<CTCH>
    OutpFile = [ ];
end

pp = inputParser( );
pp.addRequired('InpFile',@ischar);
pp.addRequired('OutpFile',@(x) ischar(x) || isempty(x));
pp.parse(InpFile,OutpFile);

opt = passvalopt('dbase.xls2csv',varargin{:});

%--------------------------------------------------------------------------

jsPath = fullfile(irisroot( ),'+thirdparty','xls2csv.js');
[inpDir,inpTitle,inpExt] = fileparts(InpFile);

if isempty(OutpFile)
    OutpFile = [inpTitle,'.csv'];
else
    [~,csvTitle,csvExt] = fileparts(OutpFile);
    OutpFile = [csvTitle,csvExt];
end

if isnumeric(opt.sheet)
    sheet = sprintf('%g',opt.sheet);
else
    sheet = sprintf('"%s"',opt.sheet);
end

c = file2char(jsPath);
c = strrep(c,'$inpFileTitle$',inpTitle);
c = strrep(c,'$inpFileExt$',inpExt);
c = strrep(c,'$sheet$',sheet);
c = strrep(c,'$outpFileName$',OutpFile);
char2file(c,fullfile(inpDir,'xls2csv.js'));

try %#ok<TRYNC>
    if ~isempty(inpDir)
        thisDir = pwd( );
        cd(inpDir);
    end
    system('xls2csv.js');
end

utils.delete('xls2csv.js');
if ~isempty(inpDir)
    cd(thisDir);
end

end