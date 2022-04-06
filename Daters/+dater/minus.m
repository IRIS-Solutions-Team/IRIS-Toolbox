function output = minus(this, that)

this = double(this);
that = double(that);
output = (round(100*this) - round(100*that))/100;

end%

