#! /usr/bin/env ruby

ENV['GOOGLE_APPLICATION_CREDENTIALS'] = 'private/puffin-tours-secret-key.json'
ENV['FILE_TO_SIGN'] = 'yhyohn22hg4v7ctan09tgy12vt9g' # gs://puffin-tours-public/yhyohn22hg4v7ctan09tgy12vt9g
# https://github.com/googleapis/google-cloud-ruby/issues/13307
require "google/cloud/env"
require "google/cloud/storage"
require "google/apis/iamcredentials_v1"
#require "google/apis/iamcredentials_v2"

storage = Google::Cloud::Storage.new
gcp_env = Google::Cloud.env

puts '-' * 80
puts "BUCKET:   #{ ENV['BUCKET'] }"
puts "SA_EMAIL: #{ ENV['SA_EMAIL'] }"
puts "FILE_TO_SIGN: #{ ENV['FILE_TO_SIGN'] }"
puts '-' * 80
puts "Are we on GKE: #{gcp_env.kubernetes_engine?}"
puts "Are we on GCE: #{gcp_env.compute_engine? }"
puts "Are we on CRun/GCF: #{gcp_env.knative? }"
puts "Are we on GAE: #{gcp_env.app_engine?  }" # app_engine_service_id
# https://googleapis.dev/ruby/google-cloud-env/latest/Google/Cloud/Env.html#app_engine%3F-instance_method
puts '-' * 80

bucket = storage.bucket ENV['BUCKET']
IAMCredentials = Google::Apis::IamcredentialsV1
remote_file = bucket.file ENV['FILE_TO_SIGN'], skip_lookup: false # true
issuer = ENV['SA_EMAIL']

#  https://github.com/googleapis/google-cloud-ruby/issues/13307
def prova_bella_ma_non_va
  signer = lambda do |string_to_sign|
    #IAMCredentials = Google::Apis::IamcredentialsV1
    iam_client = IAMCredentials::IAMCredentialsService.new
    scopes = ["https://www.googleapis.com/auth/iam"]
    iam_client.authorization = Google::Auth.get_application_default scopes
    request = Google::Apis::IamcredentialsV1::SignBlobRequest.new(
      payload: string_to_sign
    )
    # forse devo metter prj id o numb ?
    resource = "projects/-/serviceAccounts/#{issuer}"
    response = iam_client.sign_service_account_blob resource, request
    response.signed_blob
  end
  signed_url = remote_file.signed_url method: "PUT", content_type: "application/json", issuer: issuer, signer: signer

  puts "signed_url: #{signed_url}"
end


# https://github.com/googleapis/google-cloud-ruby/issues/6268
def prova_piu_facile
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket( ENV['BUCKET'] )
  bucket.files.each_with_index do |f, ix|
    break if ix > 10
    puts("💾 #{f.name}")
  end
  #puts ix
  signed_url =  bucket.signed_url('test.txt', method: 'PUT', expires: 600)
  puts 'ok'
end

prova_piu_facile()

# https://github.com/googleapis/google-cloud-ruby/issues/6268 WOW
# require 'googleauth'
# require 'google/cloud/storage'
# require 'google/apis/iamcredentials_v1'

# IAMCredentials = Google::Apis::IamcredentialsV1 # Alias the module


# # The following is a hack to introduce IAMCredentialsService into the Storage library
# # without modifying the existing library as a proof of concept.
# class IAMSigner
#    def initialize(issuer)
#      @iam_credentials_client = IAMCredentials::IAMCredentialsService.new
#      # Get the environment configured authorization
#      scopes =  ['https://www.googleapis.com/auth/cloud-platform',
#                 'https://www.googleapis.com/auth/compute']
#      @iam_credentials_client.authorization = Google::Auth.get_application_default(scopes)
#      @issuer = issuer
#    end

#    def sign(digest, string_to_sign)
#       # Ignore digest
#       request = {
#             "payload": string_to_sign,
#       }
#       response = @iam_credentials_client.sign_service_account_blob(
#         "projects/-/serviceAccounts/#{@issuer}",
#         request,
#         {}
#       )
#       response.signed_blob
#    end
# end

# storage = Google::Cloud::Storage.new
# storage_expiry_time = 5 * 60 # 5 minutes
# bucket_name = "anima-frank"
# file_name = "unnamed.jpg"
# issuer = "workload-service-account@project-id.iam.gserviceaccount.com"
# signing_key = IAMSigner.new issuer

# url = storage.signed_url bucket_name, file_name, issuer: issuer,
#                          signing_key: signing_key,
#                          method: "GET", expires: storage_expiry_time,
#                          version: :v4

# puts url
