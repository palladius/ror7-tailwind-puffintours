Since JSOn doesnt support comments (damn idiots! fix it!),
I'm going to comment here.

Some possible caveats on my issue: CORS + ActiveStorage + GCP

Links:
* https://edgeguides.rubyonrails.org/active_storage_overview.html#cross-origin-resource-sharing-cors-configuration
* https://api.rubyonrails.org/classes/ActiveStorage/Blob.html
*
## Troubleshooting CORS with GCS

Great guide: https://cloud.google.com/storage/docs/using-cors#command-line

Click the Chrome menu (more_vert) on the browser toolbar.

Select More Tools > Developer Tools.

Click the Network tab.

From your application or command line, send the request.

In the pane displaying the network activity, locate the request.

In the Name column, click the name corresponding to the request.

Click the Headers tab to see the response headers, or the Response tab to see the content of the response.

## one possible solution

https://stackoverflow.com/questions/51488304/google-cloud-storage-cors-issue-with-rails-activestorage
[
  {
    "origin": ["https://www.example.com"],
    "method": ["PUT"],
    "responseHeader": ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"],
    "maxAgeSeconds": 3600
  }
]

Damn, i had done it already.

### Another possible solution (JS)

Well, since my PuffinTours works with normal upload but not with Trix upload, i believe the problem is not SS but clientside (JS!) so this triggers me. Unfortunately this solution  is from 2019 !!

Guy says:

It turns out that the version of the direct_uploads_controller.js file I had copied out of Rails had a number of issues with browser and service compatibility. I copied over all the files in this folder and installed the missing spark-md5 package and all is well now: https://github.com/rails/rails/tree/master/activestorage/app/javascript/activestorage

The commit I've tested is 372dda2a2950ad3ae5cf744ed8e3caa69a7ed44b.



### GO Nucklear

TODO PROVA https://stackoverflow.com/questions/66484795/cors-issue-with-gcp-signed-url

   [
            {
                "origin": ["*"],
                "method": ["*"],
                "maxAgeSeconds": 3600,
                "responseHeader": ["*"]
            }
        ]
