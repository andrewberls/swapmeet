Paperclip::Attachment.default_options[:storage] = :s3
Paperclip::Attachment.default_options[:s3_credentials] = "#{Rails.root}/config/aws.yml"
Paperclip::Attachment.default_options[:bucket] = "profiteers"
Paperclip::Attachment.default_options[:url] = ":s3_domain_url"
Paperclip::Attachment.default_options[:path] = "/:class/:attachment/:id_partition/:style/:filename"  # Workaround for a Paperclip bug
Paperclip::Attachment.default_options[:s3_protocol] = ""  # Protocol-relative URLs
