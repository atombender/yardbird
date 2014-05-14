require_relative './endpoint'
require_relative './parser'
require_relative './writer'

require 'active_support/core_ext/object/blank'

module Yardbird
  class Generator

    attr_accessor :paths
    attr_accessor :options
    attr_accessor :section_level

    def initialize(options = {})
      @paths = []
    end

    def generate(stream)
      endpoints = Yarddown::Parser.parse(@paths)

      grouped_by_category = endpoints.group_by { |e| e.category }

      writer = Writer.new(stream, section_level: @section_level)

      writer.line "<section id='toc'>"
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
      writer.line "</section>"

      grouped_by_category.each do |category, eps|
        writer.heading category, anchor: category_anchor_name(category)
        writer.section do
          eps.each do |ep|
            writer.heading "`#{ep.method} #{ep.path}`", anchor: endpoint_anchor_name(ep)
            writer.section do
              writer.line ep.docstring
              if ep.params.any?
                writer.heading "Parameters"
                writer.section do
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
                writer.heading "Status Codes"
                writer.section do
                  ep.status.each do |s|
                    writer.line "**#{s[:code]}** — #{s[:doc]}"
                    writer.blank
                  end
                end
              end
              if ep.example.present?
                writer.heading "Example"
                writer.code_block do
                  writer.line "#{ep.method} #{ep.example} HTTP/1.1"
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
        category.downcase
      end

      def endpoint_anchor_name(endpoint)
        [endpoint.category, endpoint.method, endpoint.path.gsub(/[\/:]/, '-')].
          join('-').
          gsub(/-+/, '-').
          downcase
      end

  end
end
