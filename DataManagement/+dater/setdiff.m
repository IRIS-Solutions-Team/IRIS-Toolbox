function output = setdiff(this, that)

this = double(this);
that = double(that);
output = setdiff(round(100*this), round(100*that)) / 100;

end%

