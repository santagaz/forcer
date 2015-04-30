
module Forcer
  class StatusPrintService
    MAX_NUMBER_RETRIES = 3 # todo move to common constants

    def initialize(suppress_periodic_requests = false)
      @suppress_periodic_requests = suppress_periodic_requests
    end

    public

    # run thread to check process status
    def run_status_check(ids, lambda_metadata)
      header = {
          "tns:SessionHeader" => {
              "tns:sessionId" => ids[:session_id]
          }
      }
      body = {
          asyncProcessId: ids[:id]
      }
      p "REQUESTING STATUS"

      response = {}
      number_retries = 0
      status_thread = Thread.new do
        begin
          response = lambda_metadata.call(header, body)
          response_details = response.body
          print_status(response_details)
          break if (response_details[:check_deploy_status_response][:result][:done] || @suppress_periodic_requests)
          sleep(5)
        rescue Exception => ex
          if number_retries < MAX_NUMBER_RETRIES
            p "==== exception => #{ex}"
            p "==== retrying"
            response = {}
            number_retries += 1
            sleep(4)
            retry
          else
            p "EXCEEDED MAX_NUMBER_RETRIES (#{MAX_NUMBER_RETRIES}). EXITING NOW."
            raise ex
          end
        end while(number_retries < MAX_NUMBER_RETRIES)
      end

      status_thread.join()

      return response
    end

    private
    def print_status(details)
      # status =  "DONE : #{details[:check_deploy_status_response][:result][:done]} | "
      status = "STATUS : #{details[:check_deploy_status_response][:result][:status]} | "
      status += "SUCCESS : #{details[:check_deploy_status_response][:result][:success]}"
      p status
      p "==============="
    end

  end
end