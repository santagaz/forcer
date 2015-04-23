require 'rspec'
require_relative "../../../lib/utilities/status_print_service"

describe 'Forcer::StatusPrintService' do
  before(:each) do
    @mock_status_response = double()
    @mock_deploy_lambda = double()
    @ids = {id: "some_id", session_id: "another_id"}
  end

  describe "#run_status_check" do
    before(:each) do
      @response_body =
          {:check_deploy_status_response =>
               {:result =>
                    {:check_only => true,
                     :created_by => @ids,
                     :created_by_name => "FirstName LastName",
                     :created_date => "some_date",
                     :details =>
                         {:run_test_result =>
                              {:num_failures => "0",
                               :num_tests_run => "0",
                               :total_time => "0.0"
                              }
                         },
                     :done => false,
                     :id => "0Af1a000001eqgLCAQ",
                     :ignore_warnings => false,
                     :last_modified_date => "some_date",
                     :number_component_errors => "0",
                     :number_components_deployed => "569",
                     :number_components_total => "762",
                     :number_test_errors => "0",
                     :number_tests_completed => "0",
                     :number_tests_total => "0",
                     :rollback_on_error => true,
                     :run_tests_enabled => false,
                     :start_date => "some_date",
                     :state_detail => "Processing Type:AddressSettings",
                     :status => "InProgress",
                     :success => false
                    }
               }
          }
    end

    context "in easy pass without threads" do
      before(:each) do
        @status_service = Forcer::StatusPrintService.new(true)
        expect(@mock_status_response).to receive(:body).and_return(@response_body)
        expect(@mock_deploy_lambda)
            .to receive(:call)
            .with(any_args)
            .at_least(:once)
            .and_return(@mock_status_response)
      end

      it "requests status" do
        @status_service.run_status_check(@ids, @mock_deploy_lambda)
      end

      it "prints status" do
        expect { @status_service.run_status_check(@ids, @mock_deploy_lambda) }.to output.to_stdout
      end

      it "run without errors" do
        expect { @status_service.run_status_check(@ids, @mock_deploy_lambda) }.to_not output.to_stderr
      end
    end

    context "regular pass with thread" do
      it "stops when deployment is done" do
        @status_service = Forcer::StatusPrintService.new(false)
        @response_body[:check_deploy_status_response][:result][:done] = true
        allow(@mock_status_response).to receive(:body).and_return(@response_body)
        expect(@mock_deploy_lambda)
            .to receive(:call)
            .with(any_args)
            .once
            .and_return(@mock_status_response)

        expect(@status_service.run_status_check(@ids, @mock_deploy_lambda).body[:check_deploy_status_response][:result][:done])
            .to be_truthy
      end
    end

  end # describe "#run_status_check"
end # unit test