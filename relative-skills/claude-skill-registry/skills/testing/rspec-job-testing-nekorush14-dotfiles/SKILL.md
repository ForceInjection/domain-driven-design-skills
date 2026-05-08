---
name: rspec-job-testing
description: Write RSpec tests for ActiveJob background jobs testing job execution, retry logic, and error handling. Use when testing background jobs, scheduled tasks, or asynchronous operations following TDD.
---

# RSpec Job Testing Specialist

Specialized in writing comprehensive specs for ActiveJob background jobs.

## When to Use This Skill

- Testing ActiveJob background jobs
- Testing job execution and side effects
- Testing retry and error handling logic
- Testing job enqueuing
- Testing scheduled jobs
- Creating job specs before implementation (TDD)

## Core Principles

- **Test First**: Write job specs before implementing jobs
- **Full Coverage**: Test execution, errors, and retries
- **Isolation**: Mock external dependencies
- **Job Enqueuing**: Verify jobs are queued correctly
- **Side Effects**: Test all job side effects

## Job Spec Structure

```ruby
# spec/jobs/report_generation_job_spec.rb
require 'rails_helper'

RSpec.describe ReportGenerationJob, type: :job do
    describe '#perform' do
        let(:report) { create(:report) }

        context 'with valid report' do
            # Success scenarios
        end

        context 'when generation fails' do
            # Error handling tests
        end

        context 'retry behavior' do
            # Retry logic tests
        end
    end

    describe 'job enqueuing' do
        # Enqueuing tests
    end
end
```

## Testing Job Execution

```ruby
describe '#perform' do
    let(:report) { create(:report, status: 'pending') }

    it 'generates report successfully' do
        expect {
            described_class.perform_now(report.id)
        }.to change { report.reload.status }.from('pending').to('completed')
    end

    it 'creates report file' do
        described_class.perform_now(report.id)

        expect(report.reload.file).to be_attached
    end

    it 'updates completion timestamp' do
        expect {
            described_class.perform_now(report.id)
        }.to change { report.reload.completed_at }.from(nil)
    end

    it 'sends notification email' do
        expect {
            described_class.perform_now(report.id)
        }.to have_enqueued_job(ReportNotificationJob).with(report.id)
    end
end
```

## Testing Error Handling

```ruby
describe 'error handling' do
    context 'when report not found' do
        it 'does not raise error' do
            expect {
                described_class.perform_now(99999)
            }.not_to raise_error
        end

        it 'logs error' do
            expect(Rails.logger).to receive(:error).with(/Report.*not found/)
            described_class.perform_now(99999)
        end
    end

    context 'when generation fails' do
        before do
            allow_any_instance_of(ReportGenerator).to receive(:generate!).and_raise(StandardError, 'Generation failed')
        end

        it 'marks report as failed' do
            described_class.perform_now(report.id) rescue nil

            expect(report.reload.status).to eq('failed')
        end

        it 'saves error message' do
            described_class.perform_now(report.id) rescue nil

            expect(report.reload.error_message).to include('Generation failed')
        end

        it 'logs error' do
            expect(Rails.logger).to receive(:error).with(/Generation failed/)
            described_class.perform_now(report.id) rescue nil
        end
    end
end
```

## Testing Retry Logic

```ruby
describe 'retry behavior' do
    it 'retries on StandardError' do
        allow_any_instance_of(ReportGenerator).to receive(:generate!).and_raise(StandardError)

        expect {
            described_class.perform_now(report.id)
        }.to have_enqueued_job(described_class)
    end

    it 'does not retry on RecordNotFound' do
        allow(Report).to receive(:find).and_raise(ActiveRecord::RecordNotFound)

        expect {
            described_class.perform_now(report.id)
        }.not_to have_enqueued_job(described_class)
    end

    it 'respects retry attempts configuration' do
        job = described_class.new(report.id)
        expect(job.class.retry_on_block_var).to eq(StandardError)
    end
end
```

## Testing Job Enqueuing

```ruby
describe 'job enqueuing' do
    it 'enqueues job' do
        expect {
            described_class.perform_later(report.id)
        }.to have_enqueued_job(described_class).with(report.id)
    end

    it 'enqueues on correct queue' do
        expect {
            described_class.perform_later(report.id)
        }.to have_enqueued_job(described_class).on_queue('reports')
    end

    it 'enqueues with delay' do
        expect {
            described_class.set(wait: 1.hour).perform_later(report.id)
        }.to have_enqueued_job(described_class)
             .with(report.id)
             .at(1.hour.from_now)
    end

    it 'enqueues at specific time' do
        time = Time.zone.local(2024, 1, 1, 9, 0, 0)

        expect {
            described_class.set(wait_until: time).perform_later(report.id)
        }.to have_enqueued_job(described_class)
             .with(report.id)
             .at(time)
    end
end
```

## Testing Job with Multiple Arguments

```ruby
describe 'data import job' do
    let(:file_path) { '/tmp/import.csv' }
    let(:user_id) { 123 }

    it 'processes import with all arguments' do
        expect(DataImporter).to receive(:import).with(file_path, user_id)
        described_class.perform_now(file_path, user_id)
    end

    it 'enqueues with correct arguments' do
        expect {
            described_class.perform_later(file_path, user_id)
        }.to have_enqueued_job(described_class).with(file_path, user_id)
    end
end
```

## Testing Batch Processing Jobs

```ruby
describe 'batch processing' do
    let(:user_ids) { [1, 2, 3] }

    it 'processes all users' do
        user_ids.each do |id|
            expect(NotificationService).to receive(:notify).with(id)
        end

        described_class.perform_now(user_ids)
    end

    it 'continues processing after individual failures' do
        allow(NotificationService).to receive(:notify).and_raise(StandardError).once
        allow(NotificationService).to receive(:notify).and_return(true).twice

        expect {
            described_class.perform_now(user_ids)
        }.not_to raise_error
    end

    it 'logs failed user notifications' do
        allow(NotificationService).to receive(:notify).with(2).and_raise(StandardError)

        expect(Rails.logger).to receive(:error).with(/Failed to notify user 2/)
        described_class.perform_now(user_ids)
    end
end
```

## Testing Email Delivery Jobs

```ruby
# spec/mailers/user_mailer_spec.rb (Mailer testing)
RSpec.describe UserMailer, type: :mailer do
    describe 'welcome_email' do
        let(:user) { create(:user) }
        let(:mail) { described_class.welcome_email(user) }

        it 'renders the headers' do
            expect(mail.subject).to eq('Welcome to Our App')
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(['noreply@example.com'])
        end

        it 'renders the body' do
            expect(mail.body.encoded).to include(user.name)
            expect(mail.body.encoded).to include('Welcome')
        end

        it 'enqueues delivery job' do
            expect {
                mail.deliver_later
            }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
                 .with('UserMailer', 'welcome_email', 'deliver_now', { args: [user] })
        end
    end
end
```

## Testing Scheduled Jobs

```ruby
# spec/jobs/daily_cleanup_job_spec.rb
RSpec.describe DailyCleanupJob, type: :job do
    describe '#perform' do
        before do
            create(:old_record, created_at: 100.days.ago)
            create(:recent_record, created_at: 10.days.ago)
        end

        it 'deletes old records' do
            expect {
                described_class.perform_now
            }.to change(OldRecord, :count).by(-1)
        end

        it 'keeps recent records' do
            described_class.perform_now

            expect(RecentRecord.count).to eq(1)
        end

        it 'logs cleanup summary' do
            expect(Rails.logger).to receive(:info).with(/cleanup completed/)
            described_class.perform_now
        end
    end

    describe 'scheduling' do
        it 'is configured to run daily' do
            schedule = Sidekiq::Cron::Job.find('daily_cleanup')
            expect(schedule.cron).to eq('0 2 * * *')
        end
    end
end
```

## Testing Job Callbacks

```ruby
describe 'job callbacks' do
    it 'logs start before perform' do
        expect(Rails.logger).to receive(:info).with(/Starting/)
        described_class.perform_now(report.id)
    end

    it 'logs completion after perform' do
        expect(Rails.logger).to receive(:info).with(/Completed/)
        described_class.perform_now(report.id)
    end

    it 'measures execution time' do
        expect(Rails.logger).to receive(:info).with(/took.*seconds/)
        described_class.perform_now(report.id)
    end
end
```

## Tools to Use

- `Write`: Create job spec files
- `Edit`: Update job specs
- `Bash`: Run job specs
- `Read`: Read job implementation

### Bash Commands

```bash
# Run all job specs
bundle exec rspec spec/jobs

# Run specific job spec
bundle exec rspec spec/jobs/report_generation_job_spec.rb

# Run with queue adapter
QUEUE_ADAPTER=test bundle exec rspec spec/jobs
```

## Configuration

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
    config.include ActiveJob::TestHelper

    config.before(:each) do
        clear_enqueued_jobs
        clear_performed_jobs
    end
end
```

## Workflow

1. **Understand Job Requirements**: Clarify job behavior
2. **Write Failing Tests**: Create specs for execution and errors
3. **Run Tests**: Confirm tests fail
4. **Commit Tests**: Commit test code
5. **Implementation**: Use `rails-background-jobs` skill
6. **Verify**: Run tests and ensure they pass

## Related Skills

- `rails-background-jobs`: For job implementation
- `rails-error-handling`: For error handling logic
- `rails-service-objects`: For complex job logic

## RSpec Fundamentals

See [RSpec Testing Fundamentals](../_shared/rspec-testing-fundamentals.md)

## FactoryBot Guide

See [FactoryBot Guide](../_shared/factory-bot-guide.md)

## TDD Workflow

Follow [TDD Workflow](../_shared/rails-tdd-workflow.md)

## Key Reminders

- Test job execution and side effects
- Test error handling and retry logic
- Test job enqueuing (queue name, delay, arguments)
- Mock external dependencies
- Test both success and failure scenarios
- Verify logs and notifications
- Keep tests independent
- Use ActiveJob::TestHelper methods
- Test scheduled job configuration
