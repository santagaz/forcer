# mock soap response
module Forcer
  class MockResponse

    def initialize(mode = :deploy) # by default deploy
      @mode = mode
    end

    public
    def body
      if @mode == :deploy
        return body_deploy
      elsif @mode == :list_metadata
        return body_list_metadata
      end

      return {}
    end

    private
    def body_deploy
      return {
        :deploy_response => {
          :result => {
            :state=> "Queued",
            :done=> "false"
          }
        }
      }
    end

    def body_list_metadata
      return {
      :list_metadata_response=>{
        :result=>
          [{
            :created_by_id=>"test_user_id",
            :created_by_name=>"test_user_firstname test_user_lastname",
            :created_date=>"#<DateTime: 2015-04-15T05:15:21+00:00>",
            :file_name=>"objects/TestSObject__c.object",
            :full_name=>"TestSObject__c",
            :id=>"test_sobject_id",
            :last_modified_by_id=>"test_user_id",
            :last_modified_by_name=>"test_user_firstname test_user_lastname",
            :last_modified_date=>"#<DateTime: 2015-04-15T05:30:01+00:00>",
            :manageable_state=>"unmanaged",
            :type=>"CustomObject"
          }]
       }
      }
    end
  end
end