module GcpHelper
  def gcp_credentials_available?
    File.exist?(Rails.root.join("private/puffin-tours-secret-key.json")) || ENV["K_SERVICE"].present?
  end

  def gcs_files
    return @gcs_files if defined?(@gcs_files)
    unless gcp_credentials_available? && ENV["BUCKET"].present?
      return @gcs_files = ["(GCS offline or running outside GCP)"]
    end

    require "google/cloud/storage"
    storage = Google::Cloud::Storage.new(timeout: 3, retries: 0)
    bucket = storage.bucket(ENV["BUCKET"])
    @gcs_files = bucket ? bucket.files.first(20).map(&:name) : []
  rescue StandardError => e
    @gcs_files = ["(GCS unavailable: #{e.class})"]
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
