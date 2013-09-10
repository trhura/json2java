#! /usr/bin/env ruby

require "json"

def main
    stdin = ARGF.read
    begin
        json = JSON.parse(stdin)
    rescue JSON::ParserError
        puts "Parser Error. Are you sure you are passing valid JSON?"
        exit
    end

    puts json.to_java
end

class String
    # from ruby facets
    def camelcase(*separators)
        case separators.first
        when Symbol, TrueClass, FalseClass, NilClass
            first_letter = separators.shift
        end

        separators = ['_', '\s'] if separators.empty?
        str = self.dup
        separators.each do |s|
            str = str.gsub(/(?:#{s}+)([a-z])/){ $1.upcase }
        end

        case first_letter
        when :upper, true
            str = str.gsub(/(\A|\s)([a-z])/){ $1 + $2.upcase }
        when :lower, false
            str = str.gsub(/(\A|\s)([A-Z])/){ $1 + $2.downcase }
        end
        str
    end

    def java_type(key)
        "String"
    end
end

module Boolean
    def java_type(key)
        "Boolean"
    end
end

class FalseClass
    include Boolean
end

class TrueClass
    include Boolean
end

class Array
    def java_type(key)
        cls = self.first.java_type(key) || key.camelcase(:upper)
        "List<" + cls + ">"
    end

    def to_java(indent=0, step=4,clsname=nil)
        first = self.first
        if first.respond_to? :to_java
            first.to_java indent,step,clsname
        end
    end
end

class Fixnum
    def java_type(key)
        "int"
    end
end

class Hash
    def to_java (indent=0, step=4, clsname=nil)
        indented1 =  " " * indent
        indented2 =  " " * (indent+step)
        indented3 =  " " * (indent+step*2)
        clsname ||= "ChangeThisClassName"
        ret = "#{indented1}public class #{clsname} {\n"

        # generate attributes
        self.each do |key, value|
            serializename = "@SerializedName(\"#{key}\")"
            visibility = "private"
            type = value.java_type(key) || key.camelcase(:upper)
            variable = key.camelcase(:lower)
            ret += "#{indented2}#{serializename} #{visibility} #{type} #{variable};\n"
        end
        ret += "\n"

        # generate getters
        self.each do |key, value|
            visibility = "public"
            type = value.java_type(key) || key.camelcase(:upper)
            function = ( "get_" + key).camelcase(:lower)
            ret += "#{indented2}#{visibility} #{type} #{function} {\n"
            ret += "#{indented3}return this.#{key.camelcase(:lower)};\n"
            ret += "#{indented2}}\n\n"
        end

        # generate inner classes
        self.each do |key, value|
            if not value.is_a? Enumerable
                next
            end

            ret += value.to_java indent+step,step,key.camelcase(:upper)
        end

        ret += "#{indented1}}\n\n"
        ret
    end

    def java_type(key)
        nil
    end
end

main
