require "rubygems"
require "rio"

$depends = {}
$package = {}

def scan_deps_r(files)
  files.each do |file|
    unless $depends[lispfile(file)]
      r = scan_deps(lispfile(file)).reject{|e| e =~ /package/}.map {|e| lispfile(e)}
      $depends[lispfile(file)] = r
      $package[lispfile(file)] = scan_package(lispfile(file))
      scan_deps_r(r)
    end
  end
end

def scan_package(file)
  f = rio(file)
  if f.exist?
    f.read[/\(in-package\s+["':]?([^"\)\n]+)/, 1]
  else
    nil
  end
end

def scan_deps(file)
  f = rio(file)
  if f.exist?
    f.readlines.map{|e| e[/\(require\s+["']?([^"\)\n]+)/, 1]}.uniq.compact
  else
    []
  end
end

def lispfile(file)
  file += ".l" unless file =~ /\.l/
  file
end

def nonlispfile(file)
  file.sub(/\.l$/, "")
end

def print_deps_r(files, indent = 0)
  files.each do |f|
    puts "  " * indent + f
    print_deps_r($depends[lispfile(f)], indent + 1)
  end
end

def print_dot(files)
  puts 'digraph G {'
  puts '  node [shape = "ellipse"];'

  print_pakcage
  print_dot_r(files)

  puts "}"
end

def print_pakcage
  $package.values.uniq.compact.each_with_index do |pkg, i|
    puts "  subgraph cluster#{i} {"
    puts "    label = \"#{pkg}\";"
    $package.each_pair do |k,v|
      puts "    \"#{nonlispfile(k)}\";" if v == pkg
    end
    puts "  }"
  end
end

def print_dot_r(files, seen = {})
  files.each do |f|
    r = $depends[lispfile(f)]
    r.each do |e|
      unless seen[[f, e]]
        puts "  \"#{nonlispfile(f)}\" -> \"#{nonlispfile(e)}\";"
        seen[[f, e]] = true
      end
    end
    print_dot_r(r, seen)
  end
end

def capture
  defout = $stdout
  r = ""
  $stdout = StringIO.new(r)
  begin
    yield
    r
  ensure
    $stdout = defout
  end
end

top = ARGV.empty? ? ["yaml-syck.l"] : ARGV

tmp = rio("tmp.dot")
Dir.chdir("site-lisp") { scan_deps_r(top) }
tmp < capture { print_dot(top) }
unless system("dot -Tpng -o depends.png #{tmp.to_s}")
  puts tmp.read
end
tmp.delete

exit

require "pp"
pp $depends
pp $package
