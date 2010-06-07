require "rubygems"
require "rio"
require "htree"


yaml_typs = rio("http://yaml.org/type/")
types = HTree(yaml_typs.read)

types.each_hyperlink do |e|
  if e.to_s =~ /\/type\/([^\/]+)\.html$/
    name = $1
    type = HTree(rio(e.to_s).read)
    type.traverse_element("{http://www.w3.org/1999/xhtml}pre") do |ee|
      if ee.fetch_attr("class") == "programlisting"
        out = rio("#{name}.yml")
        out < "# #{e.to_s}\n"
        out << ee.extract_text.to_s
      end
    end
  end
end