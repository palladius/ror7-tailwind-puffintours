module GcpHelper
  def gcp_keyfile_path(custom_fallback: nil)
    return Pathname.new(custom_fallback) if custom_fallback && File.exist?(custom_fallback)

    local_key = Rails.root.join("private/puffin-tours-secret-key.json")
    return local_key if File.exist?(local_key)

    tmp_key = Pathname.new("/tmp/gcp-sa.json")
    return tmp_key if File.exist?(tmp_key)

    nil
  end

  def gcp_credentials_available?
    gcp_keyfile_path.present? || ENV["K_SERVICE"].present?
  end

  def gcs_files
    return @gcs_files if defined?(@gcs_files)
    bucket_name = ENV.fetch("BUCKET", GcsBucket)
    unless gcp_credentials_available? && bucket_name.present?
      return @gcs_files = ["(GCS offline or running outside GCP)"]
    end

    @gcs_files = Rails.cache.fetch("gcs_files_#{bucket_name}", expires_in: 5.minutes) do
      require "google/cloud/storage"
      keyfile = gcp_keyfile_path
      storage_opts = {
        project_id: ENV.fetch("GCS_PROJECT_ID", "ric-cccwiki"),
        timeout: 3,
        retries: 0
      }
      storage_opts[:credentials] = keyfile.to_s if keyfile.present?
      storage = Google::Cloud::Storage.new(**storage_opts)
      bucket = storage.bucket(bucket_name, skip_lookup: true)
      bucket ? bucket.files(max: 200).first(200).map(&:name) : []
    end
  rescue StandardError => e
    @gcs_files = ["(GCS unavailable: #{e.class})"]
  end

  def gcs_key_exists?(key)
    return false if key.blank?

    files = gcs_files
    return false if files.first.to_s.start_with?("(GCS ")

    files.include?(key)
  end

  def gcs_bucket
    "gs://#{ENV.fetch('BUCKET', GcsBucket)}"
  end

  def render_blob(blob)
    ret = {}
    ret[:class] = blob.class
    ret[:tos] = blob.to_s
    metadata = {}
    blob_keys = %w[id key filename content_type metadata service_name byte_size checksum created_at]
    blob_keys.each do |k|
      metadata[k.to_sym] = blob.send(k)
    end
    ret[:metadata] = metadata
    ret[:url] = "https://storage.googleapis.com/#{GcsBucket}/#{blob.key}"
    ret[:is_image] = blob.image?
    ret[:signed_id] = blob.signed_id
    ret[:ricc_manhouse_url] = "/rails/active_storage/blobs/redirect/#{blob.signed_id}/#{blob.filename}"
    ret
  end
end
