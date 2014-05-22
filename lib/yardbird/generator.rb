# encoding: utf-8

require_relative './endpoint'
require_relative './parser'
require_relative './writer'

require 'active_support/core_ext/object/blank'

module Yardbird
  class Generator

    attr_accessor :paths
    attr_accessor :section_level
    attr_accessor :table_of_contents
    attr_accessor :title
    attr_reader :yaml_headers

    def initialize(options = {})
      @paths = []
      @yaml_headers = {}
    end

    def generate(stream)
      endpoints = Yarddown::Parser.parse(@paths)

      grouped_by_category = endpoints.group_by { |e| e.category }

      if @yaml_headers.any?
        stream.puts "---"
        @yaml_headers.each do |k, v|
          stream.puts "#{k}: #{v}"
        end
        if @title and not @yaml_headers['title']
          stream.puts "title: #{@title}"
        end
        stream.puts "---"
      end

      writer = Writer.new(stream, section_level: @section_level)
      writer.section @title do
        if @table_of_contents
          writer.section "Table of Contents" do
            categories = grouped_by_category.keys.uniq.sort_by { |s| s.downcase }
            categories.each do |category|
              writer.bullet "[#{category}](##{category_anchor_name(category)})"
              writer.indent(2) do
                eps = grouped_by_category[category]
                eps.each do |ep|
                  writer.bullet "[`#{ep.method} #{ep.path}`](##{endpoint_anchor_name(ep)})"
                end
              end
            end
          end
        end

        grouped_by_category.each do |category, eps|
          writer.section category, anchor: category_anchor_name(category) do
            eps.each do |ep|
              writer.section "`#{ep.method} #{ep.path}`", anchor: endpoint_anchor_name(ep) do
                writer.line ep.docstring
                if ep.params.any?
                  writer.section "Parameters" do
                    ep.params.each do |param|
                      writer.line "`#{param[:name]}` (",
                        [param[:types]].flatten.join(', '),
                        param[:type] == 'required' ? ", **required**" : '',
                        ")<br/>#{param[:doc]}"
                      writer.blank
                    end
                  end
                end
                if ep.status.present?
                  writer.section "Status Codes" do
                    ep.status.each do |s|
                      writer.line "**#{s[:code]}** — #{s[:doc]}"
                      writer.blank
                    end
                  end
                end
                if ep.example.present?
                  writer.section "Example" do
                    writer.code_block do
                      writer.line "#{ep.method} #{ep.example} HTTP/1.1"
                    end
                  end
                end
              end
            end
          end
        end
      end
      writer.flush

      stream
    end

    private

      def category_anchor_name(category)
        if @table_of_contents
          category.downcase
        end
      end

      def endpoint_anchor_name(endpoint)
        if @endpoint_anchor_name
          [endpoint.category, endpoint.method, endpoint.path.gsub(/[\/:]/, '-')].
            join('-').
            gsub(/-+/, '-').
            downcase

        end
      end

  end
end
