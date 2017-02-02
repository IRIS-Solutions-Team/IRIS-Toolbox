function sstatefile(inputfile,outputfile,varargin)

warning('iris:obsolete', ...
   'SSTATEFILE is an obsolete function and will be deprecated in the future. Use the SSTATE class instead.');
[compileoptions,varargin] = passvalopt('sstate.compile',varargin{:});
this = sstate(inputfile,varargin{:});
compile(this,outputfile,compileoptions);

end
