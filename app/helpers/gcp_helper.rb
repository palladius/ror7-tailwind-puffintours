module GcpHelper
  require "google/cloud/storage"

  def gcs_files
    storage = Google::Cloud::Storage.new
    bucket = storage.bucket( ENV['BUCKET'] )
    return bucket.files.map{|f| f.name}
    # bucket.files .each_with_index do |f, ix|
    #   break if ix > 10
    #   puts("💾 #{f.name}")
    # end
    #return [42,43, :todo]
  end

  def gcs_bucket
    "gs://#{ENV['BUCKET']}"
  end

  def render_blob(blob)
    ret = {}
    ret[:class] = blob.class
    ret[:tos] = blob.to_s
    metadata = {}
    blob_keys = %w{id key filename content_type metadata service_name byte_size checksum created_at }
    blob_keys.each{|k|
      #ret["METAKEY_#{k}"]
      metadata[k.to_sym] = blob.send k
    }
    ret[:metadata] = metadata
    ret[:url] = blob.url
    ret[:is_image] = blob.image?
    ret[:signed_id] = blob.signed_id # from https://edgeguides.rubyonrails.org/active_storage_overview.html#cross-origin-resource-sharing-cors-configuration
    # This forces creation, and i believe upload of 100x100 tn. Wow!
    thumbnail = blob.representation(resize_to_limit: [100, 100])
    ret[:repr100x100] = thumbnail.to_s
    #ret[:repr100x100_url] = thumbnail.processed.url rescue "GnaFa: #{$!}"
    # Lets try to create the link based on:
    # b.signed_id
    # b.url:
    # I want this: http://localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBZUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--39b76058719e14a44bc123ca2176f8b1b9767665/24dec%20PXL_20231224_125639041.jpeg
    ret[:ricc_manhouse_url] = "http://localhost:3000/rails/active_storage/blobs/redirect/#{blob.signed_id}/#{blob.filename}"

    return ret
  end
end
