module GiddyUp
  # Context that creates a test result
  class CreateTestResult
    def initialize
      @test_result = TestResult.new
    end

    def id
      @test_result.id ||= TestResult.next_id
    end

    def create_test_result(data)
      begin
        @test_result.test_id = data['test_id'] || data['id']
        @test_result.status = data['status']
        project = Project.find_by_name(data['project'])
        @test_result.scorecard = project.scorecards.find_or_create_by_name(data['version'])
        @test_result.save!
        create_log data['log']
        true
      rescue
        false
      end
    end

    def create_log(data)
      directory = S3.directories.get(LogBucket) || S3.directories.create(:key => LogBucket, :public => true)
      fname = "#{id}.log"
      file = directory.files.get(fname) || directory.files.new(:key => fname)
      file.public = true
      file.body = data
      file.content_type = "text/plain"
      file.save
    end
  end
end
