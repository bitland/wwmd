#!/usr/bin/env ruby
=begin rdoc
:include:../sig.do

mixins for Hpricot
  Form
  Field
  FormArray
=end

module Hpricot
  # == original author of hpricot_form
  #
  #  Chew Choon Keat <choonkeat at gmail>
  #  http://blog.yanime.org/
  #  19 July 2006
  #
  # updated by mtracy at matasano.com for use with WWMD
  #
  class Form
    attr_accessor :hdoc
    attr_accessor :fields
    attr_accessor :formtag

    def initialize(doc)
      @hdoc = doc
      @formtag = @hdoc.search("//form")
    end

    def method_missing(*args)
      hdoc.send(*args)
    end

    alias_method :old_fields, :fields
    def fields
      @fields ||= (hdoc.search("//input[@name]") + hdoc.search("//select[@name]") + hdoc.search("//textarea")).map { |x| Field.new(x) }
    end

    def field_names
      fields.map { |x| x.get_attribute("name") }
    end

    def action
      return self.get_attribute("action")
    end

    def report
      puts "action = #{self.action}"
      self.fields.each { |field| puts field.to_text }
      return nil
    end

    alias_method :show, :report

    def to_form_array
      FormArray.new(self.fields)
    end

    def to_array
      self.to_form_array
    end
  end

  class Field < Form
    def value
      self._value.nil? ? self.get_attribute("value") : self._value
    end

    alias_method :get_value, :value #:nodoc:
    alias_method :fvalue, :value #:nodoc:

    def fname
      self.get_attribute('name')
    end

    def ftype
      self.get_attribute('type')
    end

    def _value
      # selection (array)
      ret = hdoc.search("//option[@selected]").collect { |x| x.get_attribute("value") }
      case ret.size
      when 0
        if name == "textarea"
          hdoc.innerHTML
        else
          hdoc.get_attribute("value") if (hdoc.get_attribute("checked") || !hdoc.get_attribute("type") =~ /radio|checkbox/)
        end
      when 1
        ret.first
      else
        ret
      end
    end

    def to_arr
      return [self.name, self.ftype, self.fname, self.fvalue]
    end

    def to_text
      return "tag=#{self.name} type=#{self.ftype} name=#{self.fname} value=#{self.fvalue}"
    end

  end
end
