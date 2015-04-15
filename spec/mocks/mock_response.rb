# mock soap response
class MockResponse
  public
  def body
    return {
      :deploy_response => {
        :result => {
          :deploy_result => "Queued"
        }
      }
    }
  end
end