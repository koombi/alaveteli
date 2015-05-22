# == Schema Information
#
# Table name: raw_emails
#
#  id :integer          not null, primary key
#

# models/raw_email.rb:
# The fat part of models/incoming_message.rb
#
# Copyright (c) 2008 UK Citizens Online Democracy. All rights reserved.
# Email: hello@mysociety.org; WWW: http://www.mysociety.org/

class RawEmail < ActiveRecord::Base
    # deliberately don't strip_attributes, so keeps raw email properly

    has_one :incoming_message

    def directory
        request_id = self.incoming_message.info_request.id.to_s
        if request_id.empty?
            raise "Failed to find the id number of the associated request: has it been saved?"
        end

        if Rails.env.test?
            return File.join(Rails.root, 'files/raw_email_test')
        else
            return File.join(AlaveteliConfiguration::raw_emails_location,
                             request_id[0..2], request_id)
        end
    end

    def filepath
        incoming_message_id = self.incoming_message.id.to_s
        if incoming_message_id.empty?
            raise "Failed to find the id number of the associated incoming message: has it been saved?"
        end
        File.join(self.directory, incoming_message_id)
    end

    def data=(d)
        FileUtils.mkdir_p(directory) unless File.exists?(directory)
        File.atomic_write(filepath) do |file|
            file.binmode
            file.write(d)
        end
    end

    def data
        File.open(filepath, "rb").read
    end

    def data_as_text
        text = data
        if text.respond_to?(:encoding)
            text = text.encode("UTF-8", :invalid => :replace,
                                        :undef => :replace,
                                        :replace => "")
        else
            text = Iconv.conv('UTF-8//IGNORE', 'UTF-8', text)
        end
        text
    end

    def destroy_file_representation!
        File.delete(self.filepath)
    end

end


