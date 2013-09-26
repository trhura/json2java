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
    @flags_required = true

    def item_type(key)
        cls = self.first.java_type(key) || key.camelcase(:upper)
        cls
    end

    def java_type(key)
        "List<" + self.item_type(key) + ">"
    end

    def to_java(indent=0, step=4,clsname=nil)
        first = self.first
        if first.respond_to? :to_java
            first.to_java indent,step,clsname
        end
    end

    def parcel_type (key)
        "TypedList"
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
        indented4 =  " " * (indent+step*3)
        clsname ||= "ChangeThisClassName"

        ret = "#{indented1}public class #{clsname} implements Parcelable {\n\n"
        ret += "#{indented2}/* Autogenerated by `json2java` DO NOT EDIT */\n"

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
            ret += "#{indented2}#{visibility} #{type} #{function} () {\n"
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

        ## Parcelable Implmentation
        # Empty contstructor
        visibility = "public"
        ret += "#{indented2}#{visibility} #{clsname} () { /* Empty constructor */ }\n\n"

        # Parcelable Constructor
        ret += "#{indented2}#{visibility} #{clsname} (Parcel in) {\n"
        ret += "#{indented3}readFromParcel(in);\n"
        ret += "#{indented2}}\n\n"

        # describe contents
        ret += "#{indented2}@Override\n"
        ret += "#{indented2}#{visibility} int describeContents() {\n"
        ret+= "#{indented3}return 0;\n"
        ret += "#{indented2}}\n\n"


        ret += "#{indented2}#{visibility} static final Parcelable.Creator CREATOR = new Parcelable.Creator() {\n"
        ret += "#{indented3}#{visibility} #{clsname} createFromParcel(Parcel in) {\n"
        ret += "#{indented4}return new #{clsname}(in);\n"
        ret += "#{indented3}}\n\n"
        ret += "#{indented3}#{visibility} #{clsname}[] newArray(int size) {\n"
        ret += "#{indented4}return new #{clsname}[size];\n"
        ret += "#{indented3}}\n\n"
        ret += "#{indented2}};\n\n"

        # writeParcel Method
        ret += "#{indented2}@Override\n"
        parcel = "out"
        flags="flags"
        ret += "#{indented2}public void writeToParcel (Parcel #{parcel}, int #{flags}) { \n"

        # generate write statemets
        self.each do |key, value|
            attribute = key.camelcase(:lower)
            parcel_type = value.java_type(key).to_s.capitalize
            if value.respond_to? :parcel_type
                parcel_type = value.parcel_type(key)
            end

            write_method = "write" + parcel_type
            if value.respond_to? :parcel_write_flags
                ret += "#{indented3}#{parcel}.#{write_method}(this.#{attribute}, #{flags});\n"
            else
                ret += "#{indented3}#{parcel}.#{write_method}(this.#{attribute});\n"
            end
        end

        # close writePacel
        ret += "#{indented2}}\n\n"

        # readParcel Method
        parcel = "in"
        ret += "#{indented2}public void readFromParcel (Parcel #{parcel}) {\n"

        # generate read statemets
        self.each do |key, value|
            attribute = key.camelcase(:lower)
            parcel_type = value.java_type(key).to_s.capitalize
            if value.respond_to? :parcel_type
                parcel_type = value.parcel_type(key)
            end

            read_method = "read" + parcel_type
            # FIXME:
            if value.is_a? Array
                item_type = value.item_type(key)
                ret += "#{indented3}#{parcel}.#{read_method}(this.#{attribute}, #{item_type}.CREATOR);\n"
            elsif value.is_a? Hash
                cls = attribute.capitalize
                ret += "#{indented3}this.#{attribute} = #{parcel}.#{read_method}(#{cls}.class.getClassLoader());\n"
            else
                ret += "#{indented3}this.#{attribute} = #{parcel}.#{read_method} ();\n"
            end
        end

        # close readPacel
        ret += "#{indented2}}\n\n"

        ret += "#{indented2}/* Put your custom code below */\n"
        # Closing bracket
        ret += "#{indented1}}\n\n"
        ret
    end

    def java_type(key)
        nil
    end

    def parcel_type (key)
        "Parcelable"
    end

    def parcel_write_flags
    end
end

main
