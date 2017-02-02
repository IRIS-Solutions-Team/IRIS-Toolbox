function n = xpath(x, query, type)

persistent FACTORY XPATH;
if isempty(FACTORY) || isempty(XPATH)
   import javax.xml.xpath.*;
   FACTORY = XPathFactory.newInstance;
   XPATH = FACTORY.newXPath;
end

switch lower(type)
   case 'node'
      type = XPathConstants.NODE;
   case 'nodeset'
      type = XPathConstants.NODESET;
   case 'string'
      type = XPathConstants.STRING;
   otherwise
      error('Uknown output type.');
end

expression = XPATH.compile(query);
n = expression.evaluate(x, type);

end