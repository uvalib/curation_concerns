module CurationConcerns
  module SolrDocumentBehavior
    def title_or_label
      title || label
    end

    ##
    # Give our SolrDocument an ActiveModel::Naming appropriate route_key
    def route_key
      get(Solrizer.solr_name('has_model', :symbol)).downcase
    end

    def to_param
      id
    end

    def to_s
      title_or_label
    end

    ##
    # Offer the source (ActiveFedora-based) model to Rails for some of the
    # Rails methods (e.g. link_to).
    # @example
    #   link_to '...', SolrDocument(:id => 'bXXXXXX5').new => <a href="/dams_object/bXXXXXX5">...</a>
    def to_model
      @model ||= begin
        m = ActiveFedora::Base.load_instance_from_solr(id, self)
        m.class == ActiveFedora::Base ? self : m
      end
    end

    def collection?
      hydra_model == 'Collection'
    end

    # Method to return the ActiveFedora model
    def hydra_model
      self[Solrizer.solr_name('active_fedora_model', Solrizer::Descriptor.new(:string, :stored, :indexed))]
    end

    def human_readable_type
      Array(self[Solrizer.solr_name('human_readable_type', :stored_searchable)]).first
    end

    def representative
      Array(self[Solrizer.solr_name('representative', :stored_searchable)]).first
    end

    def date_uploaded
      field = self[Solrizer.solr_name('date_uploaded', :stored_sortable, type: :date)]
      return unless field.present?
      begin
        Date.parse(field).to_formatted_s(:standard)
      rescue
        Rails.logger.info "Unable to parse date: #{field.first.inspect} for #{self['id']}"
      end
    end

    def depositor(default = '')
      val = Array(self[Solrizer.solr_name('depositor')]).first
      val.present? ? val : default
    end

    def title
      Array(self[Solrizer.solr_name('title')]).first
    end

    def description
      Array(self[Solrizer.solr_name('description')]).first
    end

    def label
      Array(self[Solrizer.solr_name('label')]).first
    end

    def file_format
      Array(self[Solrizer.solr_name('file_format')]).first
    end

    def creator
      Array(self[Solrizer.solr_name('creator')]).first
    end

    def contributor
      Array(self[Solrizer.solr_name('contributor')]).first
    end

    def subject
      Array(self[Solrizer.solr_name('subject')]).first
    end

    def publisher
      Array(self[Solrizer.solr_name('publisher')]).first
    end

    def language
      Array(self[Solrizer.solr_name('language')]).first
    end

    def tags
      Array(self[Solrizer.solr_name('tag')])
    end

    def embargo_release_date
      self['embargo_release_date_dtsi']
    end

    def lease_expiration_date
      self['lease_expiration_date_dtsi']
    end

    def rights
      self[Solrizer.solr_name('rights')]
    end

    def resource_type
      Array(self[Solrizer.solr_name('resource_type')])
    end

    def mime_type
      Array(self[Solrizer.solr_name('mime_type')]).first
    end

    def read_groups
      Array(self[::Ability.read_group_field])
    end

    def edit_groups
      Array(self[::Ability.edit_group_field])
    end

    def edit_people
      Array(self[::Ability.edit_user_field])
    end

    def public?
      read_groups.include?('public')
    end

    def registered?
      read_groups.include?('registered')
    end

    def pdf?
      ['application/pdf'].include? mime_type
    end

    def image?
      ['image/png', 'image/jpeg', 'image/jpg', 'image/jp2', 'image/bmp', 'image/gif', 'image/tiff'].include? mime_type
    end

    def video?
      ['video/mpeg', 'video/mp4', 'video/webm', 'video/x-msvideo', 'video/avi', 'video/quicktime', 'application/mxf'].include? mime_type
    end

    def audio?
      # audio/x-wave is the mime type that fits 0.6.0 returns for a wav file.
      # audio/mpeg is the mime type that fits 0.6.0 returns for an mp3 file.
      ['audio/mp3', 'audio/mpeg', 'audio/x-wave', 'audio/x-wav', 'audio/ogg'].include? mime_type
    end
  end
end
