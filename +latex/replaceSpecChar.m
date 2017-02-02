function c = replaceSpecChar(c)
c = strrep(c, '\','\textbackslash ');
c = strrep(c, '_', '\_');
c = strrep(c, '%', '\%');
c = strrep(c, '$', '\$');
c = strrep(c, '#', '\#');
c = strrep(c, '&', '\&');
c = strrep(c, '<', '\ensuremath{<}');
c = strrep(c, '>', '\ensuremath{>}');
c = strrep(c, '~', '\ensuremath{\sim}');
c = strrep(c, '^', '\^{ }');
end