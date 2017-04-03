module Reports
  class UploadTags < ::Post

    def readonly?
      true
    end

    module ApiMethods

      def as_json(options = {})
        options ||= {}
        options[:only] ||= [:id]
        super(options)
      end

      def to_xml(options = {}, &block)
        options ||= {}
        options[:only] ||= [:id, :uploader_id]
        super(options, &block)
      end

      def method_attributes
        [:uploader_tags, :added_tags, :removed_tags]
      end

    end

    include ApiMethods

    def uploader_tags_array
      @uploader_tags ||= begin
        uploader_versions = versions.select { |p| p.updater_id == uploader_id }
        added_tags = uploader_versions.flat_map do |version|
          version.changes[:added_tags]
        end
        removed_tags = uploader_versions.flat_map do |version|
          version.changes[:removed_tags]
        end
        (added_tags - removed_tags).uniq.sort
      end
    end

    def current_tags_array
      latest_tags = tag_array
      latest_tags << "rating:#{rating}" if rating.present?
      latest_tags << "parent:#{parent_id}" if parent_id.present?
      latest_tags << "source:#{source}" if source.present?
      latest_tags
    end

    def added_tags_array
      current_tags_array - uploader_tags_array
    end

    def removed_tags_array
      uploader_tags_array - current_tags_array
    end

    def uploader_tags
      uploader_tags_array.join(' ')
    end

    def added_tags
      added_tags_array.join(' ')
    end

    def removed_tags
      removed_tags_array.join(' ')
    end

  end
end
